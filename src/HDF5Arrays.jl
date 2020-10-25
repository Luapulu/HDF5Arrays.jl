module HDF5Arrays

using DiskArrays
using HDF5: HDF5Dataset

import Base: size
import DiskArrays: readblock!, writeblock!

export HDF5Array

include("HDF5Array.jl")

end
