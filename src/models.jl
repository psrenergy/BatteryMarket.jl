function base_model(list::Vector{<:Battery}, ts::TimeSeries; Optimizer=HiGHS.Optimizer)
    # -*- Load Data -*
    K  = length(list)
    T  = length(ts)

    Q  = [item.Q  for item in list]
    q0 = [item.q0 for item in list]
    C  = [item.C  for item in list]
    D  = [item.D  for item in list]
    γd = [item.γd for item in list]
    γc = [item.γc for item in list]

    p  = ts.p

    # -*- Build Model -*
    model = Model(Optimizer)

    @variable(model, 0 <= q[t = 1:T, k = 1:K] <= Q[k])
    @variable(model, 0 <= c[t = 1:T, k = 1:K] <= C[k])
    @variable(model, 0 <= d[t = 1:T, k = 1:K] <= D[k])

    @objective(model, Max, sum(p[t] * (γd[k] * d[t, k] - c[t, k]) for t = 1:T, k = 1:K))

    @constraint(model, [t = 1:T, k = 1:K], q[t, k] == (t == 1 ? q0[k] : q[t-1, k]) + γc[k] * c[t, k] - d[t, k])

    model
end

function connected_model(list::Vector{<:Battery}, ts::TimeSeries; Optimizer=HiGHS.Optimizer)
    # -*- Load Data -*
    K  = length(list)
    T  = length(ts)

    Q  = [item.Q  for item in list]
    q0 = [item.q0 for item in list]
    C  = [item.C  for item in list]
    D  = [item.D  for item in list]
    γd = [item.γd for item in list]
    γc = [item.γc for item in list]

    p  = ts.p
    E  = ts.E

    # -*- Build Model -*
    model = Model(Optimizer)

    @variable(model, 0 <= q[t = 1:T, k = 1:K] <= Q[k])
    @variable(model, 0 <= c[t = 1:T, k = 1:K] <= C[k])
    @variable(model, 0 <= d[t = 1:T, k = 1:K] <= D[k])

    @objective(model, Max, sum(p[t] * (γd[k] * d[t, k] - c[t, k]) for t = 1:T, k = 1:K))

    @constraint(model, [t = 1:T, k = 1:K], q[t, k] == (t == 1 ? q0[k] : q[t-1, k]) + γc[k] * c[t, k] - d[t, k])
    @constraint(model, [t = 1:T], sum(c[t, k] for k = 1:K) <= E[t])
    @constraint(model, [t = 1:T], sum(d[t, k] for k = 1:K) <= (E[t] > 0.0 ? 0.0 : sum(D[k] for k = 1:K)))

    model
end