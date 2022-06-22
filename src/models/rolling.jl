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

    q = Array{F, 2}[]

    for i = 1:rw.n
        ws = length(rw.w)
        ts = rw.w(ts, i) ⊕ rw.f(ts, i)
        bm = BM(bs, ts)
        qi = simulate_model(bm; Optimizer=Optimizer, silent=silent)

        # Update battery charges
        charge!.(bs, qi[ws, :])

        push!(q, qi)
    end

    vcat(q...)
end