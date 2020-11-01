module HDF5Arrays

using HDF5: DataFile, HDF5Dataset, h5open, d_create, datatype, dataspace
using TiledIteration: TileIterator

import Base: size, getindex, setindex!, iterate, to_indices, firstindex, lastindex
import HDF5: get_chunk

export HDF5Array

struct HDF5Array{T, N, D, C<:Union{Nothing, NTuple{N, Int}}} <: AbstractArray{T, N}
    data::D
    chunk::C
end

const HDF5Vector{T, D, C} = HDF5Array{T, 1, D, C}

size(arr::HDF5Array) = size(arr.data)

getindex(arr::HDF5Array{T}, I::Integer...) where {T} = getindex(arr.data, I...)::T

getindex(arr::HDF5Array{T}, I::Union{Colon, Integer, AbstractRange}...) where {T} =
    getindex(arr.data, I...)::Array{T}

setindex!(arr::HDF5Array, v, I::Union{Colon, Integer, AbstractRange}...) =
    setindex!(arr.data, v, I...)

# Read in one operation, rather than iterating index by index
to_indices(arr::HDF5Array, I::Tuple{<:CartesianIndices}) = I[1].indices

function iterate(arr::HDF5Array{T, N, HDF5Dataset, NTuple{N, Int}}) where {T, N}
    # init chunk axes
    cax_itr = TileIterator(axes(arr), arr.chunk)

    @debug "Chunk axes itr: $(cax_itr)"

    nextcax = iterate(cax_itr)
    isnothing(nextcax) && return nothing
    cax, cax_s = nextcax

    @debug "First chunk axes: $(cax)"

    buf::Array{T, N} = arr[cax...]

    @debug "First buffer: $(buf)"

    nextb = iterate(buf)
    isnothing(nextb) && return nothing

    b, b_s = nextb

    return b, ((buf, b_s), (cax_itr, cax_s))
end

function iterate(arr::HDF5Array{T, N, HDF5Dataset, NTuple{N, Int}}, state) where {T, N}
    (buf, b_s), (cax_itr, cax_s) = state

    nextb = iterate(buf, b_s)

    if isnothing(nextb)
        # get next buffer
        nextcax = iterate(cax_itr, cax_s)
        isnothing(nextcax) && return nothing
        cax, cax_s = nextcax

        @debug "Next chunk axes: $(cax)"

        buf::Array{T, N} = arr[cax...]

        @debug "Next buffer: $(buf)"

        nextb = iterate(buf)
    end

    b, b_s = nextb

    return b, ((buf, b_s), (cax_itr, cax_s))
end

firstindex(arr::HDF5Array) = first(eachindex(arr))
lastindex(arr::HDF5Array) = last(eachindex(arr))

include("construct.jl")

end
