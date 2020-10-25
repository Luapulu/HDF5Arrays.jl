struct HDF5Array{T, N} <: AbstractDiskArray{T, N}
    dset::HDF5Dataset
end

function HDF5Array(dset::HDF5Dataset)
    return HDF5Array{eltype(dset), ndims(dset)}(dset)
end

size(arr::HDF5Array) = size(arr.dset)

readblock!(arr::HDF5Array, out, i::AbstractUnitRange...) = out .= arr.dset[i...]
