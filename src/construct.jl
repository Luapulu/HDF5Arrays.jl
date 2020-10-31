_tofile(f::AbstractString) = h5open(f, "r+")
_tofile(f::DataFile) = f

HDF5Array(dset::HDF5Dataset) = HDF5Array{eltype(dset), ndims(dset), HDF5Dataset}(dset)
HDF5Array(file::Union{AbstractString, DataFile}, path::AbstractString) =
    HDF5Array(_tofile(file)[path])

function HDF5Array{T, N}(
    file::Union{AbstractString, DataFile}, path::AbstractString,
    ::UndefInitializer, dims::Vararg{Integer, N}
) where {T, N}
    HDF5Array{T, N, HDF5Dataset}(d_create(_tofile(file), path, datatype(T), dataspace(dims)))
end
