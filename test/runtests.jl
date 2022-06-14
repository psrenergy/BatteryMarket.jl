using Test
using BatteryMarket: Battery, TimeSeries, base_model, connected_model

function main()
    src_path = joinpath("data", "battery.toml")
    out_path = joinpath("data", "battery-target.toml")

    list = read(src_path, Battery)

    write(out_path, list...)

    src_path = joinpath("data", "timeseries.csv")
    out_path = joinpath("data", "timeseries-target.csv")

    ts = read(src_path, TimeSeries)

    write(out_path, ts)

    bmodel = base_model(list, ts)
    cmodel = connected_model(list, ts)

    println(bmodel)

    println(cmodel)
end

main() # Here we go!