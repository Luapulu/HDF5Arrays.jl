module HDF5Arrays

using DiskArrays, HDF5

import Base: size, getindex, _reshape, Array
import DiskArrays: eachchunk, haschunks, readblock!, writeblock!, GridChunks, Chunked, Unchunked

export HDF5Array

include("HDF5Array.jl")

end
