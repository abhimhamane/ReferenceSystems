module TimeSystems

import ERFA

include("../time/scales.jl")
include("../time/earth_orientation_params.jl")
include("../time/calendar.jl")

export
    # scale values
    utc, tai, tt, gps, ut1,

    # main type
    Epoch,

    # representations
    jd,
    jdparts,
    mjd,
    mjd2000,
    gps_seconds,

    # arithmetic
    advance,
    elapsed_seconds,

    # conversions
    timescale,

    # calendar interface
    epoch,
    calendar,

    # eop
    read_eop_c04,
    DUT1Table,
    get_dut1
end