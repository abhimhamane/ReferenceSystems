using Test
using ReferenceSystems

@testset "MyPackage" begin
    @testset "TimeSystems" begin
        include("time/timetest.jl")
    end
end