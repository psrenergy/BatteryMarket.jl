struct TimeSeries{F <: Real}
    p::Vector{F}                 # Price
    E::Union{Vector{F}, Nothing} # Available Energy

    function TimeSeries{F}(A::AbstractArray{<:Any, 2}) where {F <: Real}
        if size(A, 2) == 1
            TimeSeries{F}(A[:, 1])
        else
            TimeSeries{F}(A[:, 1], A[:, 2])
        end
    end

    function TimeSeries{F}(p::AbstractVector, E::AbstractVector) where {F <: Real}
        @assert length(p) == length(E)
        new{F}(convert.(F, p), convert.(F, E))
    end

    function TimeSeries{F}(p::AbstractVector) where {F <: Real}
        new{F}(convert.(F, p), nothing)
    end

    function TimeSeries(A::AbstractArray{<:Any, 2})
        TimeSeries{Float64}(A)
    end

    function TimeSeries(p::AbstractVector, E::AbstractVector)
        TimeSeries{Float64}(p, E)
    end

    function TimeSeries(p::AbstractVector)
        TimeSeries{Float64}(p)
    end
end

function Base.length(ts::TimeSeries)
    length(ts.p)
end

function Base.write(path::AbstractString, ts::TimeSeries)
    return open(path, "w") do io
        write(io, ts)
    end
end

function Base.write(io::IO, ts::TimeSeries)
    CSV.write(io, CSV.Tables.table([ts.p;;ts.E]; header=["p", "E"]))
end

function Base.read(path::AbstractString, TS::Type{<:TimeSeries})
    return open(path, "r") do io
        read(io, TS)
    end
end

function Base.read(io::IO, TS::Type{<:TimeSeries})
    TS(CSV.File(io) |> CSV.Tables.matrix)
end

function window(wi::Integer, ws::Integer, bs::Integer = ws)
    return (
        ws * (wi - 1) + 1,
        ws * wi,
        ws * (wi - 1) + 1,
        ws * (wi - 1) + bs,
    )
end

function window(ts::TimeSeries{F}, wi::Integer, ws::Integer, bs::Integer = ws) where {F <: Real}
    i, j, k, l = window(wi, ws, bs)

    if isnothing(ts.E)
        TimeSeries{F}(
            [ts.p[i:j];ts.p[k:l]],
        )
    else
        TimeSeries{F}(
            [ts.p[i:j];ts.p[k:l]],
            [ts.E[i:j];ts.E[k:l]],
        )
    end
end