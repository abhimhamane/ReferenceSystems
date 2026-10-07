abstract type AbstractTimeScale end
abstract type UniformTimeScale <: AbstractTimeScale end

struct UTC <: AbstractTimeScale end
struct UT1 <: AbstractTimeScale end

struct TAI <: UniformTimeScale end
struct GPS <: UniformTimeScale end
struct TT <: UniformTimeScale end

const utc = UTC()
const ut1 = UT1()
const tai = TAI()
const tt = TT()
const gps = GPS()


struct Epoch{S<:AbstractTimeScale,T<:AbstractFloat}
    whole::Int64
    fraction::T

    function Epoch{S,T}(
        whole::Int64,
        fraction::T,
    ) where {
        S<:AbstractTimeScale,
        T<:AbstractFloat
    }
        0 <= fraction < 1 ||
            throw(ArgumentError(
                "fraction must satisfy 0 ≤ fraction < 1"
            ))

        new{S,T}(whole, fraction)
    end
end

function Epoch{S}(d1::T, d2::T) where {
    S<:AbstractTimeScale,
    T<:AbstractFloat
}
    whole = floor(Int64, d1)
    frac = (d1 - whole) + d2

    carry = floor(Int64, frac)

    return Epoch{S,T}(
        whole + carry,
        frac - carry,
    )
end

scale(::Epoch{S}) where {S} = S()
jdparts(t::Epoch{S, T}) where{S,T} = (T(t.whole), t.fraction)

const MJD_OFFSET = 2400000.5
mjd(t::Epoch) = (t.whole - 2400000) + (t.fraction - 0.5)

const JD2000_OFFSET = 2451545
mjd2000(t::Epoch) = (t.whole - JD2000_OFFSET) + t.fraction

function mjdparts(t::Epoch{S,T}) where {S,T}
    half = T(0.5)

    if t.fraction < half
        return (
            t.whole - 2_400_001,
            t.fraction + half,
        )
    else
        return (
            t.whole - 2_400_000,
            t.fraction - half,
        )
    end
end
const SECONDS_PER_DAY = 86400.0

# Δt in seconds
function advance(t::Epoch{S, T}, Δt_seconds::T) where {S<:UniformTimeScale, T<:AbstractFloat}
    Δdays = T(Δt_seconds)/T(SECONDS_PER_DAY)
    return Epoch{S}(T(t.whole), t.fraction+Δdays)
end

function elapsed_seconds(tk::Epoch{S, Tk}, t0::Epoch{S, T0}) where {S<:UniformTimeScale, Tk, T0}
    Δdays = (tk.whole - t0.whole) + (tk.fraction - t0.fraction)
    return Δdays * SECONDS_PER_DAY
end

const GPS_REFERENCE_EPOCH = Epoch{GPS}(2444244.0, 0.5)

gps_seconds(t::Epoch{GPS}) = elappsed_seconds(t, GPS_REFERENCE_EPOCH)

timescale(::S, t::Epoch{S}) where {S<:AbstractTimeScale} = t

function timescale(::TAI, t::Epoch{UTC})
    utc1, utc2 = jdparts(t)
    tai1, tai2 = ERFA.utctai(utc1, utc2)
    return Epoch{TAI}(tai1, tai2)
end

function timescale(::UTC, t::Epoch{TAI})
    tai1, tai2 = jdparts(t)
    utc1, utc2 = ERFA.taiutc(tai1, tai2)
    return Epoch{UTC}(utc1, utc2)
end

function timescale(::TT, t::Epoch{TAI})
    tai1, tai2 = jdparts(t)
    tt1, tt2 = ERFA.taitt(tt1, tt2)
    return Epoch{TT}(tt1, tt2)
end

function timescale(::TAI, t::Epoch{TT})
    tt1, tt2 = jdparts(t)
    tai1, tai2 = ERFA.tttai(tt1, tt2)
    return Epoch{TAI}(tai1, tai2)
end

const TAI_MINUS_GPS_SECONDS = 19.0

function _epoch_offset(::D, t::Epoch{S, T}, Δt_seconds) where {
    D<:AbstractTimeScale, S<:AbstractTimeScale, T}

    Δdays = T(Δt_seconds)/T(SECONDS_PER_DAY)
    return Epoch{D}(t.whole, t.fraction+Δdays)
end

timescale(::TAI, t::Epoch{GPS}) =
    _epoch_offset(tai, t, +TAI_MINUS_GPS_SECONDS)

timescale(::GPS, t::Epoch{TAI}) =
    _epoch_offset(gps, t, -TAI_MINUS_GPS_SECONDS)


function timescale(
    ::UT1,
    t::Epoch{UTC},
    dUT1::Real,
)
    utc1, utc2 = jdparts(t)

    ut11, ut12 = ERFA.utcut1(
        utc1,
        utc2,
        dUT1,
    )

    return Epoch{UT1}(ut11, ut12)
end


function timescale(::UTC, t::Epoch{UT1}, dUT1)
    ut11, ut12 = jdparts(t)

    utc1, utc2 = ERFA.ut1utc(
        ut11,
        ut12,
        dUT1,
    )

    return Epoch{UTC}(utc1, utc2)
end



timescale(::TT, t::Epoch{UTC}) =
    timescale(tt, timescale(tai, t))

timescale(::UTC, t::Epoch{TT}) =
    timescale(utc, timescale(tai, t))


timescale(::GPS, t::Epoch{UTC}) =
    timescale(gps, timescale(tai, t))

timescale(::UTC, t::Epoch{GPS}) =
    timescale(utc, timescale(tai, t))


timescale(::TT, t::Epoch{GPS}) =
    timescale(tt, timescale(tai, t))

timescale(::GPS, t::Epoch{TT}) =
    timescale(gps, timescale(tai, t))

