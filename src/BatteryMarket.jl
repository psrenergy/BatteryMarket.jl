module BatteryMarket

using TOML
using JSON
using CSV
using Glob
using JuMP
using HiGHS

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

    s = hcat((ts[Symbol("operation_$(b.code)")] for b in bm.bs)...)

    open(joinpath(basepath, replace(outfile, ".csv" => ".json")), "w") do io
        JSON.print(io, Dict{String, Any}(
            "profit" => sum(s)
        ))
    end
end

end # module
