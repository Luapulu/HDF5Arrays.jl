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

    g["c", "chunk", (5, 6, 7)] = rand(15, 8, 10)
    @test get_chunk(HDF5Array(g, "c")) == get_chunk(g["c"]) == (5, 6, 7)

    # Implementation detail
    @test HDF5Array(g, "c") isa HDF5Array{Float64, 3, HDF5Dataset, NTuple{3, Int}}

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
    @test arr[CartesianIndex(5, 5, 5)] == 12345.6
    @test dset[5, 5, 5] == 12345.6

    @inferred arr[5, 5, 5]

    arr[:, 1, 1] = 1:10
    @test arr[:, 1, 1] == 1:10
    @test all(arr[CartesianIndices((1:10, 1:1, 1:1))] .== 1:10)
    @test dset[:, 1, 1] == 1:10

    @test_broken @inferred arr[:, 1, 1]

    yarr = HDF5Array{Float64, 2}(path, "group/y", undef, 30, 5)
    ydset = h5open(path, "r+")["group/y"]
    ydset[1, 5] = 5432.1

    @test yarr[1, 5] == 5432.1

    yarr[:, 2] = 1:30
    @test yarr[:, 2] == 1:30
end

@testset "Iteration Interface" begin
    path = tempname() * ".h5"
    h5open(path, "w")["x", "chunk", (3, 2)] = Array(reshape(1:60, 15, 4))

    arr = HDF5Array(path, "x")

    x, s = iterate(arr)
    @test firstindex(arr) == CartesianIndex(1, 1)
    @test x == first(x) == 1

    x, s = iterate(arr, s) # 2
    x, s = iterate(arr, s) # 3
    x, s = iterate(arr, s) # next col => x = 16
    @test x == 16

    x, s = iterate(arr, s) # 17
    x, s = iterate(arr, s) # 18
    x, s = iterate(arr, s) # next chunk => x = 4
    @test x == 4

    c = collect(y for y in arr)
    @test length(c) == length(arr)
    @test lastindex(arr) == CartesianIndex(15, 4)
    @test last(c) == last(arr)
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
