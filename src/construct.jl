_tofile(f::AbstractString) = h5open(f, "r+")
_tofile(f::DataFile) = f

HDF5Array(dset::HDF5Dataset) =
    HDF5Array{eltype(dset), ndims(dset), HDF5Dataset, Nothing}(dset)
HDF5Array(file::Union{AbstractString, DataFile}, path::AbstractString) =
    HDF5Array(_tofile(file)[path])

HDF5Array{T, N, D, Nothing}(data) where {T, N, D} = HDF5Array{T, N, D, Nothing}(data, nothing)

_make_dim_args(
    T::Type, dims::NTuple{N, Integer},
    max_dims::NTuple{N, Integer}, chunk::NTuple{N, Integer}
) where {N} = (T, (dims, max_dims), "chunk", chunk)

_make_dim_args(
    T::Type, dims::NTuple{N, Integer},
    max_dims::Nothing, chunk::Nothing
) where {N} = (datatype(T), dataspace(dims...))

_make_dim_args(
    T::Type, dims::NTuple{N, Integer},
    max_dims::Nothing, chunk::NTuple{N, Integer}
) where {N} = (datatype(T), dataspace(dims...), "chunk", chunk)

_convert_chunk_type(c::NTuple{N, Integer}) where {N} = NTuple{N, Int}(c)
_convert_chunk_type(::Nothing) = nothing

_make_filter_args(compress::Integer) = ("compress", compress)
_make_filter_args(::Nothing) = ()

function HDF5Array{T, N}(
    file::Union{AbstractString, DataFile}, path::AbstractString,
    ::UndefInitializer, dims::Vararg{Integer, N};
    chunk::Union{NTuple{N, Integer}, Nothing} = nothing,
    max_dims::Union{NTuple{N, Integer}, Nothing} = nothing,
    compress::Union{Integer, Nothing} = nothing
) where {T, N}
    c = _convert_chunk_type(chunk)
    return HDF5Array{T, N, HDF5Dataset, typeof(c)}(
        d_create(
            _tofile(file), path,
            _make_dim_args(T, dims, max_dims, chunk)...,
            _make_filter_args(compress)...
        ),
        c
    )
end
