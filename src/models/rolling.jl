struct RollingModel{T <: BatteryModel} <: BatteryModel end

function simulate_model(
        ::RollingModel{BM},
        bs::Vector{Battery},
        ts::TimeSeries{F},
        w::Window,
        f::Forecast;
        Optimizer=HiGHS.Optimizer,
        silent::Bool = true,
    ) where {BM <: BatteryModel, F <: Real}

    q = Array{F, 2}(undef, length(ts), length(bs))

    for i in w
        qi = simulate_model(BM(), bs, ts[i]; Optimizer=Optimizer, silent=silent)

        # Update battery charges
        charge!.(bs, qi[ws, :])
        
        j, k, _ = window(wi, ws)
        q[j:k, :] .= qi[1:ws, :]
    end

    q
end