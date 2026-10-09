module CoordinateSystems

import LinearAlgebra: norm, dot, cross
import Base: +, -, *, /

include("../coordinates/types.jl")

export 
    Cartesian,
    Spherical,
    cartesian,
    norm,
    components, ECI, ECEF
end