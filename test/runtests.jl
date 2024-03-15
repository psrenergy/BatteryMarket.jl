using Test
using JuMP
# using Plots; gr()
using BatteryMarket

function main()
    BatteryMarket.simulate(; basepath=joinpath(@__DIR__, "data"))

    run(`python $(joinpath(@__DIR__, "plot.py")`)
end

main() # Here we go!