const BATTERY_TOML_KEYS = [
    "code",
    "max_storage",
    "max_charge",
    "max_discharge",
    "charge_eff",
    "discharge_eff",
    "initial_charge",
]

mutable struct Battery{F <: Real}
    code::Int
    Q::F  # Maximum Charge Capacity
    q::F  # Charge
    C::F  # Maximum Charging rate
    D::F  # Maximum Discharging rate
    γc::F # Charging Efficiency
    γd::F # Discharging Efficiency
    
    function Battery{F}(code::Integer, Q::Real, q::Real, C::Real, D::Real, γc::Real, γd::Real) where {F <: Real}
        new{F}(
            code,
            convert(F, Q),
            convert(F, q),
            convert(F, C),
            convert(F, D),
            convert(F, γc),
            convert(F, γd),
        )
    end

    function Battery(code::Integer, Q, q, C, D, γc, γd)
        Battery{Float64}(code, Q, q, C, D, γc, γd)
    end
end

function to_toml(item::Battery)
    Dict{String, Any}(
        "code"           => item.code,
        "max_storage"    => item.Q,
        "initial_charge" => item.q,
        "max_charge"     => item.C,
        "max_discharge"  => item.D,
        "charge_eff"     => item.γc,
        "discharge_eff"  => item.γd,
    )
end

function Base.write(path::AbstractString, list::Battery...)
    return open(path, "w") do io
        write(io, list...)
    end
end

function Base.write(io::IO, list::Battery...)
    data = Dict{String, Any}("Battery" => Any[to_toml(item) for item in list])

    TOML.print(io, data)
end

function Base.read(path::AbstractString, B::Type{<:Battery})
    return open(path, "r") do io
        read(io, B)
    end
end

function Base.read(io::IO, B::Type{<:Battery})
    data = TOML.parse(read(io, String))

    if !haskey(data, "Battery") || !(data["Battery"] isa Vector)
        error("Bad format: No '[[Battery]]' block")
    end

    list = B[]

    for item in data["Battery"]
        if !(item isa Dict)
            error("Bad format: No key-value pairs")
        end

        for key in BATTERY_TOML_KEYS
            if !haskey(item, key)
                error("Bad format: Missing key '$key'")
            end
        end

        push!(list, B(
            item["code"],
            item["max_storage"],
            item["initial_charge"],
            item["max_charge"],
            item["max_discharge"],
            item["charge_eff"],
            item["discharge_eff"],
        ))
    end

    list
end

function charge!(item::Battery{F}, q::Real) where {F <: Real}
    item.q = clamp(convert(F, q), zero(F), item.Q)
end