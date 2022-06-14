using Test
using JuMP
using GLPK
using UnicodePlots
using BatteryMarket

function main()
    data = BatteryMarket.BatteryData.battery_data(
        BatteryMarket.BatteryData.generate_prices(72)
    )

    model = BatteryMarket.BatteryModels.battery_model(
        data, GLPK.Optimizer
    )

    JuMP.optimize!(model)

    println(JuMP.solution_summary(model))

    p = data.p
    q = JuMP.value.(model[:q])

    plt = lineplot(1:data.S, p, title="Price vs. Charge")
    plt = lineplot!(plt, 1:data.S, q[:, 1])

    println(plt)
end

main() # Here we go!