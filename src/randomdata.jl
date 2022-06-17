function generate_energies(n::Integer, E::F, p::F) where {F <: Real}
    F[E * (rand() < p) * rand() for _ = 1:n]
end

function generate_prices(n::Integer, p₀::F) where {F <: Real}
    p = zeros(F, n)
    for i = 2:n
        p[i] = p[i-1] + (1.0 - 2.0 * rand())
    end
    p .+= (p₀ - minimum(p))

    return p
end