ENV["JULIA_DEBUG"] = true

using Test
using JuMP
using Plots; gr()
using BatteryMarket: Battery, TimeSeries, simulate_model, BaseModel, ConnectedModel, RollingModel

const battery_path    = joinpath("data", "battery.toml")
const timeseries_path = joinpath("data", "sudeste.csv")

function makeplot(ts::TimeSeries, q::AbstractArray)
    p = ts.p
    n = length(p)
    t = collect(1:n)

    plt = plot(title="Battery Market: Rolling Window Model")

    plot!(plt, t, p[:]; legend=:topleft)

    pltx = twinx()

    for k = 1:size(q, 2)
        plot!(pltx, t, q[:, k]; xticks=:none, legend=:topright)
    end

    savefig(plt, "plot.png")
end

function main()
    bs = read(battery_path, Battery)
    ts = read(timeseries_path, TimeSeries)

    N = 24 * 365

    @assert N == length(ts)

    q = simulate_model(BaseModel(), bs, ts; model_kind = :base)

    makeplot(ts, q)
end

main() # Here we go!