module BatteryMarket

using TOML
using JSON
using CSV
using Glob
using JuMP
using HiGHS

function simulate_model end

# -*- Data & IO -*-
include("battery.jl")
include("timeseries.jl")
include(joinpath("models", "models.jl"))

function simulate(
        Optimizer = HiGHS.Optimizer;
        basepath::String = pwd(),
        infile::String = "data.csv",
        outfile::String = "results.csv",
    )

    bm = read_model(; basepath=basepath, infile = infile)

    @info """
    Model Type: $(typeof(bm))
    Batteries: $(length(bm.bs))
    Timespan: $(length(bm.ts)) hours
    """

    ts = simulate_model(bm; Optimizer = Optimizer)

    open(joinpath(basepath, outfile), "w") do io
        write(io, ts)
    end

    p = ts[:p]
    q = hcat((ts[Symbol(b.code)] for b in bm.bs)...)

    open(joinpath(basepath, replace(outfile, ".csv" => ".json")), "w") do io
        JSON.print(io, Dict{String, Any}(
            "profit" => sum(p[i-1] * -sum(q[i, :] .- q[i-1, :]) for i = 2:length(ts))
        ))
    end
end

end # module
