struct ConnectedModel{F} <: BatteryModel{F}
    bs::Vector{Battery{F}}
    ts::TimeSeries{F}

    function ConnectedModel{F}(bs::Vector{Battery{F}}, ts::TimeSeries{F}) where F
        new{F}(bs, ts)
    end
end

function build_model(
        bm::ConnectedModel;
        Optimizer=HiGHS.Optimizer,
        silent::Bool=true,
    )
    # -*- Load Data -*
    K = length(bm.bs)
    T = length(bm.ts)

    Q  = [item.Q  for item in bm.bs]
    q0 = [item.q  for item in bm.bs]
    C  = [item.C  for item in bm.bs]
    D  = [item.D  for item in bm.bs]
    γd = [item.γd for item in bm.bs]
    γc = [item.γc for item in bm.bs]

    p = bm.ts[:p]
    E = bm.ts[:E]

    # -*- Build Model -*
    model = Model(Optimizer)

    JuMP.set_optimizer_attribute(model, MOI.Silent(), silent)

    @variable(model, 0 <= q[t=1:T, k=1:K] <= Q[k])
    @variable(model, 0 <= c[t=1:T, k=1:K] <= C[k])
    @variable(model, 0 <= d[t=1:T, k=1:K] <= D[k])

    @objective(model, Max, sum(p[t] * (γd[k] * d[t, k] - c[t, k]) for t = 1:T, k = 1:K))

    @constraint(model, [t = 1:T, k = 1:K], q[t, k] == (t == 1 ? q0[k] : q[t-1, k]) + γc[k] * c[t, k] - d[t, k])
    @constraint(model, [t = 1:T], sum(c[t, k] for k = 1:K) <= E[t])
    @constraint(model, [t = 1:T], sum(d[t, k] for k = 1:K) <= (E[t] > 0.0 ? 0.0 : sum(D[k] for k = 1:K)))

    model
end