

function HDF5Array{T, N, D}(data) where {T, N, D<:HDF5Dataset}
    try
        get_chunk(data)
        return HDF5Array{T, N, D}(data, true)
    catch ErrorException
        return HDF5Array{T, N, D}(data, false)
    end
end

const HDF5Vector{T, D} = HDF5Array{T, 1, D}

_tofile(f::AbstractString) = h5open(f, "r+")
_tofile(f::DataFile) = f

HDF5Array(dset::HDF5Dataset) = HDF5Array{eltype(dset), ndims(dset), HDF5Dataset}(dset)
HDF5Array(file::Union{AbstractString, DataFile}, path::AbstractString) =
    HDF5Array(_tofile(file)[path])

function HDF5Array{T, N}(
    file::Union{AbstractString, DataFile}, path::AbstractString,
    ::UndefInitializer, dims::Vararg{Integer, N}
) where {T, N}
    HDF5Array{T, N, HDF5Dataset}(d_create(_tofile(file), path, datatype(T), dataspace(dims)), false)
end

const HDF5Chain{T, CN} = ChainedVector{T, CN, HDF5Array{T, 1, D}} where D

HDF5Array(chain::HDF5Chain{T}) where T = HDF5Vector{T, HDF5Chain{T}}(chain)
HDF5Array(h5chain, path::AbstractString) = HDF5Array(
    ChainedVector(map(f -> HDF5Array(f, path), h5chain)...)
)
