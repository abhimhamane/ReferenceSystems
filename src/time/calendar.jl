_erfa_name(::UTC) = "UTC"
_erfa_name(::TAI) = "TAI"
_erfa_name(::TT)  = "TT"
_erfa_name(::GPS) = "GPS"
_erfa_name(::UT1) = "UT1"

function epoch(
    s::S,
    year::Integer,
    month::Integer,
    day::Integer,
    hour::Integer = 0,
    minute::Integer = 0,
    second::Real = 0.0,
) where {S<:AbstractTimeScale}

    d1, d2 = ERFA.dtf2d(
        _erfa_name(s),
        year,
        month,
        day,
        hour,
        minute,
        second,
    )

    return Epoch{S}(d1, d2)
end

function calendar(
    t::Epoch{S};
    digits::Integer = 9,
) where {S<:AbstractTimeScale}

    d1, d2 = jdparts(t)

    year, month, day, hmsf =
        ERFA.d2dtf(
            _erfa_name(S()),
            digits,
            d1,
            d2,
        )

    hour, minute, second, fraction = hmsf

    sec =
        second +
        fraction * 10.0^(-digits)

    return (
        year = year,
        month = month,
        day = day,
        hour = hour,
        minute = minute,
        second = sec,
    )
end