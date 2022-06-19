module BatteryMarket

using TOML
using CSV
using JuMP
using HiGHS

# -*- Data & IO -*-
include("battery.jl")
include("timeseries.jl")

# -*- Models -*-
abstract type BatteryModel end

@doc raw"""
    simulate_model()
"""
function simulate_model end

include("models/base.jl")
include("models/connected.jl")
include("models/rolling.jl")

end # module
