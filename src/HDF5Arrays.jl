module HDF5Arrays

using DiskArrays: AbstractDiskArray, Unchunked, Chunked
using HDF5:
    DataFile, HDF5Dataset, h5open, d_create, datatype, dataspace,
    get_chunk
using ChainedArrays: ChainedVector

import Base: size
import DiskArrays: readblock!, writeblock!, haschunks, eachchunk

export HDF5Array

struct HDF5Array{T, N, D} <: AbstractDiskArray{T, N}
    data::D
    chunked::Bool
end

size(arr::HDF5Array) = size(arr.data)

readblock!(arr::HDF5Array, out, i::AbstractUnitRange...) = out .= arr.data[i...]
writeblock!(arr::HDF5Array, X, i::AbstractUnitRange...) = arr.data[i...] = X

haschunks(arr::HDF5Array{T, N, HDF5Dataset}) where {T, N} = arr.chunked ? Chunked() : Unchunked()

eachchunk(arr::HDF5Array) = eachchunk(arr, haschunks(arr))
eachchunk(arr::HDF5Array{<:Any, <:Any, HDF5Dataset}, ::Chunked) =
    GridChunks(arr.data, get_chunk(arr.data))

include("construct.jl")
include("chained.jl")

end
