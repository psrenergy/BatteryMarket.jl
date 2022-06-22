module BatteryMarket

using TOML
using CSV
using Glob
using JuMP
using HiGHS

function simulate_model end

# -*- Data & IO -*-
include("battery.jl")
include("timeseries.jl")
include("models\\models.jl")

function simulate(
        Optimizer = HiGHS.Optimizer;
        basepath::String = pwd(),
        infile::String = "data.csv",
        outfile::String = "results.csv",
    )

    bm = read_model(; basepath=basepath, infile = infile)
    ts = simulate_model(bm; Optimizer = Optimizer)

    open(joinpath(basepath, outfile), "w") do io
        write(io, ts)
    end
end

end # module
