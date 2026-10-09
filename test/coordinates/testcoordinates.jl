using Test
using LinearAlgebra: norm, dot

#using ReferenceSystems.Frames:: ECI, ECEF
using ReferenceSystems.CoordinateSystems: Cartesian, Spherical, components, cartesian, ECI, ECEF


@testset "Coordinates" begin

    @testset "Cartesian constructors" begin
        # Floating-point inputs
        p = Cartesian{ECI}(1.0, 2.0, 3.0)

        @test p.x == 1.0
        @test p.y == 2.0
        @test p.z == 3.0
        @test typeof(p) === Cartesian{ECI,Float64}

        # Integer inputs
        p = Cartesian{ECI}(1, 2, 3)
        @test typeof(p) === Cartesian{ECI,Int}

        # Mixed numeric types: promotion
        p = Cartesian{ECI}(1, 2.0f0, 3.0)
        @test typeof(p) === Cartesian{ECI,Float64}

        # Vector constructor
        p = Cartesian{ECI}([1.0, 2.0, 3.0])
        @test components(p) == (1.0, 2.0, 3.0)

        # Invalid input lengths
        @test_throws DimensionMismatch Cartesian{ECI}([1, 2])
        @test_throws DimensionMismatch Cartesian{ECI}([1, 2, 3, 4])
    end

    @testset "Spherical constructors" begin
        s = Spherical{ECI}(7000e3, 0.5, 1.0)

        @test s.radius == 7000e3
        @test s.lat == 0.5
        @test s.lon == 1.0

        @test typeof(s) === Spherical{ECI,Float64,Float64}

        # Radius must be positive
        @test_throws DomainError Spherical{ECI}(-1.0, 0.0, 0.0)
        @test_throws DomainError Spherical{ECI}(0.0, 0.0, 0.0)

        # Mixed angle types
        s = Spherical{ECI}(1000, 0.5f0, 1.0)
        @test typeof(s) === Spherical{ECI,Int,Float64}
    end

    @testset "Components" begin
        p = Cartesian{ECI}(1.0, 2.0, 3.0)
        s = Spherical{ECI}(10.0, 0.5, 1.0)

        @test components(p) == (1.0, 2.0, 3.0)
        @test components(s) == (10.0, 0.5, 1.0)

        # Identity conversion
        @test cartesian(p) === p
    end

    @testset "Spherical to Cartesian" begin
        r = 7000e3

        # Equator, prime meridian
        s = Spherical{ECI}(r, 0.0, 0.0)
        p = cartesian(s)

        @test p.x ≈ r
        @test abs(p.y) < 1e-9
        @test abs(p.z) < 1e-9

        # Equator, 90° east
        s = Spherical{ECI}(r, 0.0, π/2)
        p = cartesian(s)

        @test abs(p.x) < 1e-9
        @test p.y ≈ r
        @test abs(p.z) < 1e-9

        # North pole
        s = Spherical{ECI}(r, π/2, 0.0)
        p = cartesian(s)

        @test abs(p.x) < 1e-9
        @test abs(p.y) < 1e-9
        @test p.z ≈ r

        # Frame preservation
        @test p isa Cartesian{ECI}
    end

    @testset "Cartesian arithmetic" begin
        a = Cartesian{ECI}(1.0, 2.0, 3.0)
        b = Cartesian{ECI}(4.0, 5.0, 6.0)

        @test components(a + b) == (5.0, 7.0, 9.0)
        @test components(a - b) == (-3.0, -3.0, -3.0)
        @test components(-a) == (-1.0, -2.0, -3.0)

        @test components(2*a) == (2.0, 4.0, 6.0)
        @test components(a*2) == (2.0, 4.0, 6.0)
        @test components(a/2) == (0.5, 1.0, 1.5)

        # Arithmetic preserves the frame
        @test (a + b) isa Cartesian{ECI}
    end

    @testset "Linear algebra" begin
        a = Cartesian{ECI}(3.0, 4.0, 0.0)
        b = Cartesian{ECI}(1.0, 2.0, 3.0)

        @test norm(a) ≈ 5.0
        @test norm(b) ≈ sqrt(14.0)

        @test dot(a, b) ≈ 11.0
        @test dot(a, a) ≈ norm(a)^2

        # Norm of spherical coordinates
        s = Spherical{ECI}(7000e3, 0.5, 1.0)
        @test norm(s) == 7000e3
    end

    @testset "Reference frame consistency" begin
        a = Cartesian{ECI}(1.0, 2.0, 3.0)
        b = Cartesian{ECEF}(4.0, 5.0, 6.0)

        # Operations across incompatible frames must fail
        @test_throws MethodError a + b
        @test_throws MethodError a - b
        @test_throws MethodError dot(a, b)

        # Independent operations remain valid
        @test norm(a) ≈ sqrt(14.0)
        @test norm(b) ≈ sqrt(77.0)
    end

end
