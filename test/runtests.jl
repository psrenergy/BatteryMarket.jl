ENV["JULIA_DEBUG"] = true

using Test
using JuMP
using UnicodePlots
using BatteryMarket: Battery, TimeSeries, simulate_base_model, simulate_connected_model, simulate_rolling_model

const battery_path = joinpath("data", "battery.toml")
const timeseries_path = joinpath("data", "sudeste.csv")

UnicodePlots.default_size!(width=150)

function load_data()
    list = read(battery_path, Battery)
    ts = read(timeseries_path, TimeSeries)

    return (list, ts)
end

function plot(ts, q; title = "Model")
    p = ts.p
    n = length(p)
    t = collect(1:n)

    plt = lineplot(t, p[:]; name="price", title=title)

    plts = lineplot(t, zeros(Float64, n))

    for k = 1:size(q, 2)
        plts = lineplot!(plts, t, q[:, k]; name="charge $k")
    end

    println(plt)
    println(plts)

end

function main()
    list, ts = load_data()

    N = 24 * 365

    @assert N == length(ts)

    q = simulate_rolling_model(365, 24, 24, list, ts; model_kind = :base)

    plot(ts, q)
end

main() # Here we go!