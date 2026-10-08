abstract type AbstractCoordinate end

struct Cartesian <: AbstractCoordinate end
struct Spherical <: AbstractCoordinate end
struct GeodeticCoordinate <: AbstractCoordinate end

