using Test
using BatteryMarket: Battery, TimeSeries, base_model

function main()
    src_path = joinpath("data", "battery.toml")
    out_path = joinpath("data", "battery-target.toml")

    list = read(src_path, Battery)

    write(out_path, list...)

    src_path = joinpath("data", "timeseries.csv")
    out_path = joinpath("data", "timeseries-target.csv")

    ts = read(src_path, TimeSeries)

    write(out_path, ts)
end

main() # Here we go!