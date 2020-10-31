using HDF5Arrays, HDF5, Test

@testset "HDF5Arrays.jl" begin

cd(mktempdir())

@testset "Constructors" begin
    path = tempname() * ".h5"
    h5write(path, "group/x", rand(Int, 200, 50))
    f = h5open(path, "r+")
    g = f["group"]
    dset = g["x"]
    x = read(dset)

    @test HDF5Array(f, "group/x") == x
    @test HDF5Array(path, "group/x") == x
    @test HDF5Array(g, "x") == x
    @test HDF5Array(dset) == x

    y = HDF5Array{Float64, 2}(path, "group/y", undef, 100, 5)
    @test g["y"] isa HDF5Dataset
    @test eltype(g["y"]) == Float64
    @test size(g["y"]) == (100, 5)

    z = HDF5Array{Int32, 3}(g, "z", undef, 3, 5, 7, chunk=(3, 4, 5))
    @test g["z"] isa HDF5Dataset
    @test eltype(g["z"]) == Int32
    @test size(g["z"]) == (3, 5, 7)
    @test get_chunk(g["z"]) == (3, 4, 5)

    a = HDF5Array{Float32, 2}(g, "a", undef, 20, 7, chunk=(7, 7), max_dims=(-1, 14))
    @test g["a"] isa HDF5Dataset
    @test eltype(g["a"]) == Float32
    @test size(g["a"]) == (20, 7)
    @test get_chunk(g["a"]) == (7, 7)

    @test_throws ErrorException set_dims!(g["a"], (20, 15))

    set_dims!(g["a"], (1000, 14))
    @test size(a) == size(g["a"]) == (1000, 14)

    b = HDF5Array{Int, 4}(g, "b", undef, 6, 6, 6, 6, chunk=(3, 3, 3, 3), compress=5)
    @test g["b"] isa HDF5Dataset
    @test eltype(g["b"]) == Int
    @test size(g["b"]) == (6, 6, 6, 6)
    @test get_chunk(g["b"]) == (3, 3, 3, 3)
end

@testset "Read / Write" begin
    path = tempname() * ".h5"
    h5write(path, "group/x", rand(10, 15, 20))
    dset = h5open(path, "r+")["group/x"]
    x = read(dset)

    arr = HDF5Array(dset)

    @test all(arr .== x)

    @test arr[:, 2, 10:end] == x[:, 2, 10:end]

    arr[5, 5, 5] = 12345.6
    @test arr[5, 5, 5] == 12345.6
    @test dset[5, 5, 5] == 12345.6

    arr[:, 1, 1] = 1:10
    @test arr[:, 1, 1] == 1:10
    @test dset[:, 1, 1] == 1:10

    yarr = HDF5Array{Float64, 2}(path, "group/y", undef, 30, 5)
    ydset = h5open(path, "r+")["group/y"]
    ydset[1, 5] = 5432.1

    @test yarr[1, 5] == 5432.1

    yarr[:, 2] = 1:30
    @test yarr[:, 2] == 1:30
end

# @testset "Chained" begin
#     path1, path2, path3 = tempname() * ".h5", tempname() * ".h5", tempname() * ".h5"
#     h5write(path1, "group/x", rand(50))
#     h5write(path2, "group/x", rand(100))
#     h5write(path3, "group/x", rand(75))
#
#     x = vcat(
#         h5read(path1, "group/x"),
#         h5read(path2, "group/x"),
#         h5read(path3, "group/x")
#     )
#
#     arr = HDF5Array((path1, path2, path3), "group/x")
#     @test arr == x
#
#     arr[26:75] = 1:50
#     @test h5read(path1, "group/x")[26:50] == 1:25
#     @test h5read(path2, "group/x")[1:25] == 26:50
# end

end
