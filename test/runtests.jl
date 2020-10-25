using HDF5Arrays, HDF5, Test

@testset "HDF5Arrays.jl" begin
    path = tempname() * ".h5"
    h5write(path, "x", rand(100, 50, 25, 10), "compress", 3)
    x = h5read(path, "x")

    h5arr = HDF5Array(h5open(path)["x"])
    @test Array(h5arr) == x

    @test all(h5arr .== x)
end
