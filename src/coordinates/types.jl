abstract type AbstractCoordinate end
abstract type AbstractFrame end

struct ECI <: AbstractFrame end
struct ECEF <: AbstractFrame end

struct Cartesian{F<:AbstractFrame, T<:Real} <: AbstractCoordinate
    x::T
    y::T
    z::T
end

struct Spherical{F<:AbstractFrame, T<:Real, A<:Real} <: AbstractCoordinate
    radius::T
    lat::A # [rad]
    lon::A # [rad]
end

function Cartesian{F}(x::Real, y::Real, z::Real) where {F<:AbstractFrame}
    x, y, z = promote(x, y, z)
    return Cartesian{F, typeof(z)}(x, y, z)
end

function Cartesian{F}(v::AbstractVector) where {F<:AbstractFrame}
    length(v)==3 || throw(DimensionMismatch("Cartesian expects 3 components"))
    Cartesian{F}(v[1], v[2], v[3])
end

components(p::Cartesian) = (p.x, p.y, p.z)
components(p::Spherical) = (p.radius, p.lat, p.lon)

function Spherical{F}(r::Real, lat::Real, lon::Real) where {F<:AbstractFrame}
    r > 0 || throw(DomainError(r, "radius must be > 0"))
    lon, lat = promote(lon, lat)
    Spherical{F, typeof(r), typeof(lon)}(r, lat, lon)
end

cartesian(p::Cartesian) = p

function cartesian(p::Spherical{F}) where{F}
    sϕ, cϕ = sincos(p.lat)
    sλ, cλ = sincos(p.lon)
    return Cartesian{F}(p.radius*cϕ*cλ, p.radius*cϕ*sλ, p.radius*sϕ)
end

+(a::Cartesian{F}, b::Cartesian{F}) where {F} = Cartesian{F}(a.x+b.x, a.y+b.y, a.z+b.z)
-(a::Cartesian{F}, b::Cartesian{F}) where {F} = Cartesian{F}(a.x-b.x, a.y-b.y, a.z-b.z)
-(a::Cartesian{F}) where {F} = Cartesian{F}(-a.x, -a.y, -a.z)

*(α::Real, a::Cartesian{F}) where {F} = Cartesian{F}(α*a.x, α*a.y, α*a.z)
*(a::Cartesian{F}, α::Real) where {F} = α*a

/(a::Cartesian{F}, α::Real) where{F} = Cartesian{F}(a.x/α, a.y/α, a.z/α)

norm(p::Cartesian) = hypot(p.x, p.y, p.z)
norm(p::Spherical) = p.radius

function dot(a::Cartesian{F}, b::Cartesian{F}) where {F}
    return a.x*b.x + a.y*b.y + a.z*b.z
end
