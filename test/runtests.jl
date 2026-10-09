using Test
using ReferenceSystems

@testset "ReferenceSystems" begin
    #@testset "TimeSystems" begin
    #    include("time/timetest.jl")
    #end

    @testset "Coordinates" begin
        include("coordinates/testcoordinates.jl")
    end
end