abstract type AbstractTimeScales end
abstract type UniformTimeScales <: AbstractTimeScales end

struct UTC <: AbstractTimeScales end
struct UT1 <: AbstractTimeScales end

struct TAI <: UniformTimeScales end
struct GPS <: UniformTimeScales end
struct TT <: UniformTimeScales end

struct Epoch{S<:AbstractTimeScales, T<:AbstractFloat}
    jd1::T
    jd2::T
end
