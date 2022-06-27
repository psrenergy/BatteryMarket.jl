using Test
using JuMP
# using Plots; gr()
using BatteryMarket

function main()
    BatteryMarket.simulate(; basepath=joinpath(@__DIR__, "data"))
end

main() # Here we go!