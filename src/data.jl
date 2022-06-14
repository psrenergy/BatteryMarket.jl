module BatteryData

using Random

struct Data{T <: Real}
    Q::Vector{T}
    Δᶜq::Vector{T}
    Δᵈq::Vector{T}
    γᶜ::Vector{T}
    γᵈ::Vector{T}
    p::Vector{T}
    q₀::Vector{T}
    S::Int
    K::Int
end

function battery_data(p::Vector{T}, Q::T=10.0, Δᶜq::T=0.1Q, Δᵈq::T=0.1Q, γᶜ::T=0.8, γᵈ::T=0.8, q₀::T = zero(T)) where {T <: Real}
    Data{T}(
        T[Q],
        T[Δᶜq],
        T[Δᵈq],
        T[γᶜ],
        T[γᵈ],
        p,
        T[q₀],
        length(p),
        1,
    )
end

function generate_prices(n::Integer, p₀::T) where {T <: Real}
    p = zeros(T, n)
    for i = 2:n
        p[i] = p[i-1] + (1.0 - 2.0 * rand())
    end
    p .+= (p₀ - minimum(p))

    p
end

function generate_prices(n::Integer)
    generate_prices(n, 1.0)
end

end # module