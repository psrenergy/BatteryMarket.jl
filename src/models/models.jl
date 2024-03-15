# -*- Models -*-
abstract type BatteryModel{F <: Real} end

include("base.jl")
include("connected.jl")
include("rolling.jl")

function read_model(;
        basepath::AbstractString = pwd(),
        infile::String = "data.csv",
    )

    basepath = normpath(basepath)

    if !isdir(basepath)
        error("$(basepath) is not a directory")
    end

    md = Dict{String, Any}(
        "model_type" => "base",
    )
    bs = Battery{Float64}[]

    for path in glob("[!_]*.toml", basepath)
        data = TOML.parsefile(path)
        
        if haskey(data, "Model")
            md_data = data["Model"]
            
            if !(md_data isa Dict)
                error("Format Error: Model must be a dictionary i.e. a [Model] block")
            end

            merge!(md, md_data)
        end

        if haskey(data, "Battery")
            bs_data = data["Battery"]

            if !(bs_data isa Vector)
                error("Format Error: Battery must be a vector i.e. a [[Battery]] block")
            end

            for bs_item in bs_data
                for key in BATTERY_TOML_KEYS
                    if !haskey(bs_item, key)
                        error("Format Error: Missing key '$key' in [[Battery]] block")
                    end
                end
        
                push!(bs, Battery{Float64}(
                    bs_item["code"],
                    bs_item["max_storage"],
                    bs_item["initial_charge"],
                    bs_item["max_charge"],
                    bs_item["max_discharge"],
                    bs_item["charge_eff"],
                    bs_item["discharge_eff"],
                ))
            end
        end
    end

    # -*- Model Type -*-
    mt = md["model_type"]
    
    if !(mt isa String) || !(mt in ("base", "connected"))
        error("Format Error: 'model_type' must be 'base' or 'connected'")
    end

    # -*- Time Series -*-
    tspath = joinpath(basepath, infile)

    if !isfile(tspath)
        error("File Error: '$(tspath)' not found")
    end

    ts = open(tspath, "r") do io
        return read(io, TimeSeries{Float64})
    end

    if mt == "base" && !(:p in ts.h)
        error("Missing price column 'p' in time series")
    elseif mt == "connected"
        if !(:p in ts.h)
            error("Missing price column 'p' in time series")
        elseif !(:E in ts.h)
            error("Missing energy column 'E' in time series")
        end
    end

    MT = if mt == "base"
        BaseModel{Float64}
    elseif mt == "connected"
        ConnectedModel{Float64}
    end

    if isempty(bs)
        error("Format Error: Missing [[Battery]] blocks")
    end

    if haskey(md, "Window") # rolling window model
        if !(md["Window"] isa Dict)
            error("Format Error: window must be a dictionary i.e. a [Window] block")
        end

        wd = merge(
            Dict{String, Any}(
                "window_type"    => "slice",
                "forecast_type"  => "mirror",
                "forecast_size"  => 0,
            ),
            md["Window"],
        )

        if !haskey(wd, "num_windows") || !(wd["num_windows"] isa Integer)
            error("Format Error: Missing integer value for key 'num_windows'")
        end

        @assert (n = wd["num_windows"]::Integer) > 0

        if !haskey(wd, "window_size") || !(wd["window_size"] isa Integer)
            error("Format Error: Missing integer value for key 'window_size'")
        end

        # - window
        @assert (ws = wd["window_size"]::Integer) > 0

        if !haskey(wd, "window_type") || !(wd["window_type"] isa String)
            error("Format Error: Missing string value for key 'window_type'")
        end

        wt = wd["window_type"]::String

        w = if wt == "slice"
            SliceWindow(ws)
        else
            error("Format Error: Invalid window type '$wt'. Options are: 'slice'")
        end

        if !haskey(wd, "forecast_size") || !(wd["forecast_size"] isa Integer)
            error("Format Error: Missing integer value for key 'forecast_size'")
        end

        fs = wd["forecast_size"]::Integer

        if !haskey(wd, "forecast_type") || !(wd["forecast_type"] isa String)
            error("Format Error: Missing string value for key 'forecast_type'")
        end

        ft = wd["forecast_type"]::String

        f = if ft == "mirror"
            MirrorForecast(fs)
        else
            error("Format Error: Invalid forecast type '$wt'. Options are: 'slice'")
        end

        RollingWindowModel{Float64, MT}(bs, ts, w, f, n)
    else
        MT(bs, ts)
    end
end