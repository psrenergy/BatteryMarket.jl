struct BaseModel <: BatteryModel end

function build_model(
        ::BaseModel,
        bs::Vector{<:Battery},
        ts::TimeSeries;
        Optimizer=HiGHS.Optimizer,
        silent::Bool = true,
    )
    # -*- Load Data -*
    K  = length(bs)
    T  = length(ts)

    Q  = [item.Q  for item in bs]
    q0 = [item.q  for item in bs]
    C  = [item.C  for item in bs]
    D  = [item.D  for item in bs]
    γd = [item.γd for item in bs]
    γc = [item.γc for item in bs]

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

function simulate_model(
        ::BaseModel,
        bs::Vector{<:Battery},
        ts::TimeSeries;
        Optimizer=HiGHS.Optimizer,
        silent::Bool = true,
    )

    model = build_base_model(bs, ts; Optimizer=Optimizer, silent=silent)

    JuMP.optimize!(model)

    JuMP.value.(model[:q])
end