module HDF5Arrays

using HDF5:
    DataFile, HDF5Dataset, h5open, d_create, datatype, dataspace

import Base: size, getindex, setindex!, iterate

export HDF5Array

struct HDF5Array{T, N, D, C<:Union{Nothing, NTuple{N, Int}}} <: AbstractArray{T, N}
    data::D
    chunks::C
end

const HDF5Vector{T, D, C} = HDF5Array{T, 1, D, C}

size(arr::HDF5Array) = size(arr.data)

getindex(arr::HDF5Array, I::Union{Integer, AbstractUnitRange}...) =
    getindex(arr.data, I...)

setindex!(arr::HDF5Array, v, I::Union{Integer, AbstractUnitRange}...) =
    setindex!(arr.data, v, I...)

# function iterate(arr::HDF5Array) end

include("construct.jl")
include("chained.jl")

end
