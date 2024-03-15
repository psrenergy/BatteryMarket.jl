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

function charge!(item::Battery{F}, q::Real) where {F <: Real}
    item.q = clamp(convert(F, q), zero(F), item.Q)
end