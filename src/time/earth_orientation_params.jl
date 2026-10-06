struct DUT1Table{T}
    mjd0::Int
    dut1::Vector{T}
end

function read_eop_c04(filepath)
    mjds  = Int[]
    dut1s = Float64[]

    open(filepath, "r") do io
        for line in eachline(io)
            fields = split(line)

            length(fields) < 7 && continue

            mjd = tryparse(Int, fields[4])
            mjd === nothing && continue

            dut1 = tryparse(Float64, fields[7])
            dut1 === nothing && continue

            push!(mjds, mjd)
            push!(dut1s, dut1)
        end
    end

    isempty(mjds) &&
        throw(ArgumentError("No EOP records found in $filepath"))

    # Verify daily contiguous C04 data
    @inbounds for i in 2:length(mjds)
        mjds[i] == mjds[i-1] + 1 ||
            throw(ArgumentError(
                "EOP data are not contiguous at MJD $(mjds[i])"
            ))
    end

    return DUT1Table(
        first(mjds),
        dut1s,
    )
end

function get_dut1(
    t::Epoch{UTC},
    table::DUT1Table)

    mjd_day, fraction = mjdparts(t)

    i = mjd_day - table.mjd0 + 1

    1 <= i <= length(table.dut1) ||
        throw(DomainError(
            mjd_day,
            "Epoch outside EOP data range"
        ))

    iszero(fraction) &&
        return table.dut1[i]

    i < length(table.dut1) ||
        throw(DomainError(
            mjd_day,
            "Cannot interpolate beyond EOP data range"
        ))

    y0 = table.dut1[i]
    y1 = table.dut1[i + 1]

    return muladd(
        fraction,
        y1 - y0,
        y0,
    )
end

#eop_table = read_eop_c04("/home/abhi/Research/PhD/tools/RapidFGMSim/data/EOP_14_C04_IAU2000A_one_file_1962-now.txt")
#t = Epoch{UTC}(eop_table.mjd0+MJD_OFFSET, 3.0)
#get_dut1(t, eop_table)


function timescale(
    ::UT1,
    t::Epoch{UTC},
    eop_table::DUT1Table
)
    dUT1 = get_dut1(t, eop_table)

    return timescale(
        ut1,
        t,
        dUT1
    )
end

function timescale(::UTC, t::Epoch{UT1}, eop_table::DUT1Table)
    dUT1 = get_dut1(t, eop_table)

    return timescale(
        utc,
        t,
        dUT1,
    )

end