function simulate_rolling_model(
        wn::Integer, # Window Number
        ws::Integer, # Window Size
        bs::Integer, # Buffer Size
        list::Vector{Battery},
        ts::TimeSeries{F};
        Optimizer=HiGHS.Optimizer,
        model_kind::Symbol = :base,
        silent::Bool = true,
    ) where {F <: Real}

    q = Array{F, 2}(undef, length(ts), length(list))

    for wi = 1:wn
        qi = if model_kind === :base
            simulate_base_model(list, window(ts, wi, ws, bs); Optimizer=Optimizer, silent=silent)
        elseif model_kind === :connected
            simulate_connected_model(list, window(ts, wi, ws, bs); Optimizer=Optimizer, silent=silent)
        else
            error("Unknown model '$model'")
        end

        # Update battery charges
        charge!.(list, qi[ws, :])
        
        j, k, _ = window(wi, ws)
        q[j:k, :] .= qi[1:ws, :]
    end

    q
end