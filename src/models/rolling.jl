struct RollingWindowModel{F, BM <: BatteryModel} <: BatteryModel{F}
    bs::Vector{Battery{F}}
    ts::TimeSeries{F}
    w::Window
    f::Forecast
    n::Int

    function RollingWindowModel{F, BM}(
            bs::Vector{Battery{F}},
            ts::TimeSeries{F},
            w::Window,
            f::Forecast,
            n::Integer,
        ) where {F, BM}

        new{F, BM}(bs, ts, w, f, n)
    end
end

function simulate_model(
        rw::RollingWindowModel{F, BM};
        Optimizer=HiGHS.Optimizer,
        silent::Bool = true,
    ) where {F, BM}

    t = TimeSeries{F}[]

    for i = 1:rw.n
        ws = length(rw.w)
        ts = rw.w(rw.ts, i) ⊕ rw.f(rw.ts, i)
        bm = BM(rw.bs, ts)
        ti = simulate_model(bm; Optimizer=Optimizer, silent=silent)
        qi = [ti[Symbol("charge_$(b.code)")][ws] for b in rw.bs]

        # Update battery charges
        charge!.(rw.bs, qi)

        push!(
            t,
            TimeSeries{F}(ti.A[1:ws, :], ti.h)
        )
    end

    reduce(⊕, t)
end