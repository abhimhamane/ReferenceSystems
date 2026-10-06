using Test

using ReferenceSystems.TimeSystems:
    Epoch,
    TT,
    GPS,
    UTC,
    tt,
    gps,
    utc,
    jdparts,
    mjdparts,
    advance,
    elapsed_seconds,
    epoch,
    timescale,
    tai

@testset "Epoch construction" begin
    t = Epoch{TT}(2451545.0, 0.25)

    @test t.whole == 2451545
    @test t.fraction == 0.25
end

@testset "Epoch normalization" begin
    t = Epoch{TT}(2451545.0, 1.25)

    @test t.whole == 2451546
    @test t.fraction ≈ 0.25

    t = Epoch{TT}(2451545.0, -0.25)

    @test t.whole == 2451544
    @test t.fraction ≈ 0.75
end

@testset "Equivalent JD decompositions" begin
    t1 = Epoch{TT}(2451545.0, 0.25)
    t2 = Epoch{TT}(2400000.5, 51544.75)

    @test t1.whole == t2.whole
    @test t1.fraction ≈ t2.fraction
end

@testset "MJD representation" begin
    # JD 2451545.0 = MJD 51544.5
    t = Epoch{TT}(2451545.0, 0.0)

    d, f = mjdparts(t)

    @test d == 51544
    @test f ≈ 0.5
end

@testset "Epoch advance" begin
    t0 = Epoch{TT}(2451545.0, 0.25)

    t1 = advance(t0, 10.0)

    @test elapsed_seconds(t1, t0) ≈ 10.0
end

@testset "Advance across day boundary" begin
    t0 = Epoch{TT}(2451545.0, 0.9)

    t1 = advance(t0, 0.2 * 86400)

    @test t1.whole == 2451546
    @test t1.fraction ≈ 0.1
end

@testset "Large propagation intervals" begin
    t0 = Epoch{TT}(2451545.0, 0.25)

    Δt = 10 * 86400 + 123.456

    t1 = advance(t0, Δt)

    @test elapsed_seconds(t1, t0) ≈ Δt
end

@testset "UTC ↔ TAI round trip" begin
    t0 = epoch(
        utc,
        2026, 1, 1,
        12, 30, 15.0,
    )

    t1 = timescale(tai, t0)
    t2 = timescale(utc, t1)

    # Better than comparing a collapsed JD.
    d10, d20 = jdparts(t0)
    d12, d22 = jdparts(t2)

    @test d10 == d12
    @test d20 ≈ d22 atol=1e-14
end


@testset "DUT1 interpolation" begin
    # exactly at MJD 60000
    t0 = Epoch{UTC}(2400000.5, 60000.0)

    @test dut1(table, t0) ≈ 0.1

    # halfway between 60000 and 60001
    t1 = Epoch{UTC}(2400000.5, 60000.5)

    @test dut1(table, t1) ≈ 0.15

    # halfway between 60001 and 60002
    t2 = Epoch{UTC}(2400000.5, 60001.5)

    @test dut1(table, t2) ≈ 0.3
end

