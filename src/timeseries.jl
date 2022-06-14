struct TimeSeries{F <: Real}
    p::Vector{F} # price
    E::Vector{F} # Energy

    function TimeSeries{F}(p::Vector, E::Vector) where {F <: Real}
        @assert length(p) == length(E)
        
        new{F}(convert.(F, p), convert.(F, E))
    end

    function TimeSeries(p::Vector, E::Vector)
        TimeSeries{Float64}(p, E)
    end
end

function Base.length(ts::TimeSeries)
    length(ts.p)
end

function Base.write(path::AbstractString, ts::TimeSeries)
    open(path, "w") do io
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
    data = CSV.File(io) |> CSV.Tables.matrix

    TS(data[:, 1], data[:, 2])
end