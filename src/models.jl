module BatteryModels

using ..BatteryData: Data
using JuMP

function battery_model(data::Data, Optimizer)
    Q = data.Q
    Δᶜq = data.Δᶜq
    Δᵈq = data.Δᵈq
    γᵈ = data.γᵈ
    γᶜ = data.γᶜ
    p = data.p
    q₀ = data.q₀

    S = data.S
    K = data.K

    model = Model(Optimizer)

    @variable(model, 0 <= q[s = 1:S, k = 1:K] <= Q[k])
    @variable(model, 0 <= δᶜq[s = 1:S, k = 1:K] <= Δᶜq[k])
    @variable(model, 0 <= δᵈq[s = 1:S, k = 1:K] <= Δᵈq[k])

    @objective(model, Max, sum(p[s] * (γᵈ[k] * δᵈq[s, k] - δᶜq[s, k]) for s = 1:S, k = 1:K))

    @constraint(model, [s = 1:S-1, k = 1:K], q[s, k] == (s == 1 ? q₀[k] : q[s-1, k]) + γᶜ[k] * δᶜq[s, k] - δᵈq[s, k])

    model
end

end # Models module 