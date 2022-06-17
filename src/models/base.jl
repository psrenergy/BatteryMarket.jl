function build_base_model(
        list::Vector{<:Battery},
        ts::TimeSeries;
        Optimizer=HiGHS.Optimizer,
        silent::Bool = true,
    )
    # -*- Load Data -*
    K  = length(list)
    T  = length(ts)

    Q  = [item.Q  for item in list]
    q0 = [item.q  for item in list]
    C  = [item.C  for item in list]
    D  = [item.D  for item in list]
    γd = [item.γd for item in list]
    γc = [item.γc for item in list]

    p  = ts.p

    # -*- Build Model -*
    model = Model(Optimizer)

    JuMP.set_optimizer_attribute(model, MOI.Silent(), silent)

    @variable(model, 0 <= q[t = 1:T, k = 1:K] <= Q[k])
    @variable(model, 0 <= c[t = 1:T, k = 1:K] <= C[k])
    @variable(model, 0 <= d[t = 1:T, k = 1:K] <= D[k])

    @objective(model, Max, sum(p[t] * (γd[k] * d[t, k] - c[t, k]) for t = 1:T, k = 1:K))

    @constraint(model, [t = 1:T, k = 1:K], q[t, k] == (t == 1 ? q0[k] : q[t-1, k]) + γc[k] * c[t, k] - d[t, k])

    model
end

function simulate_base_model(
        list::Vector{<:Battery},
        ts::TimeSeries;
        Optimizer=HiGHS.Optimizer,
        silent::Bool = true,
    )

    model = build_base_model(list, ts; Optimizer=Optimizer, silent=silent)

    JuMP.optimize!(model)

    JuMP.value.(model[:q])
end