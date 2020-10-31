module HDF5Arrays

using HDF5:
    DataFile, HDF5Dataset, h5open, d_create, datatype, dataspace,
    get_chunk

import Base: size, getindex, setindex!

export HDF5Array

struct HDF5Array{T, N, D} <: AbstractArray{T, N}
    data::D
end

const HDF5Vector{T, D} = HDF5Array{T, 1, D}

size(arr::HDF5Array) = size(arr.data)

getindex(arr::HDF5Array, I::Vararg{Integer, N}) where {N} =
    getindex(arr.data, I...)

setindex!(arr::HDF5Array, v, I::Vararg{Integer, N}) where {N} =
    setindex!(arr.data, v, I...)

include("construct.jl")
include("chained.jl")

end
