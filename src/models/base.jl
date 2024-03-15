struct BaseModel{F} <: BatteryModel{F}
    bs::Vector{Battery{F}}
    ts::TimeSeries{F}

    function BaseModel{F}(bs::Vector{Battery{F}}, ts::TimeSeries{F}) where F
        new{F}(bs, ts)
    end
end

function build_model(
        bm::BaseModel;
        Optimizer = HiGHS.Optimizer,
        silent::Bool = true,
    )
    # -*- Load Data -*
    K  = length(bm.bs)
    T  = length(bm.ts)

    Q  = [item.Q  for item in bm.bs]
    q0 = [item.q  for item in bm.bs]
    C  = [item.C  for item in bm.bs]
    D  = [item.D  for item in bm.bs]
    γd = [item.γd for item in bm.bs]
    γc = [item.γc for item in bm.bs]

    p  = bm.ts[:p]

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
        bm::BatteryModel{F};
        Optimizer = HiGHS.Optimizer,
        silent::Bool = true,
    ) where F

    model = build_model(bm; Optimizer=Optimizer, silent=silent)

    JuMP.optimize!(model)

    p = bm.ts[:p]
    γd = [item.γd for item in bm.bs]
    q = JuMP.value.(model[:q])
    c = JuMP.value.(model[:c])
    d = JuMP.value.(model[:d])
    K = length(bm.bs)
    T = length(bm.ts)
    Δq = F[(c[t, k] - γd[k] * d[t, k]) for t = 1:T, k = 1:K]
    op = F[-p[t] * Δq[t, k] for t = 1:T, k = 1:K]

    TimeSeries{F}(
        [
            bm.ts.A;;
            q;;
            Δq;;
            op
        ],
        [
            bm.ts.h;
            Symbol.(["charge_$(b.code)" for b in bm.bs]);
            Symbol.(["charge_delta_$(b.code)" for b in bm.bs]);
            Symbol.(["operation_$(b.code)" for b in bm.bs])
        ]
    )
end