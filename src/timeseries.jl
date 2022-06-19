struct TimeSeries{F <: Real}
    A::Array{F, 2}

    function TimeSeries{F}(A::AbstractArray{<:Any, 2}) where {F <: Real}
        new{F}(A)
    end

    function TimeSeries{F}(p::AbstractVector, E::AbstractVector) where {F <: Real}
        @assert length(p) == length(E)
        new{F}([p;;E])
    end

    function TimeSeries{F}(p::AbstractVector) where {F <: Real}
        new{F}(p)
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

function price(ts::TimeSeries)
    ts[:, 1]
end

function energy(ts::TimeSeries)
    ts[:, 2]
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
    if size(ts.A, 2) == 2     # price only
        CSV.write(io, CSV.Tables.table(ts.A; header=["p", "q"]))
    elseif size(ts.A, 2) == 3 # price and energy
        CSV.write(io, CSV.Tables.table(ts.A; header=["p", "E", "q"]))
    else
        error("Inconsistent data")
    end
end

function Base.read(path::AbstractString, TS::Type{<:TimeSeries})
    return open(path, "r") do io
        read(io, TS)
    end
end

function Base.read(io::IO, TS::Type{<:TimeSeries})
    TS(CSV.File(io) |> CSV.Tables.matrix)
end


# -*- Window -*- #
abstract type Window end

struct SliceWindow <: Window
    size::Int

    function SliceWindow(size::Integer)
        new(size)
    end
end

function window(ts::TimeSeries{F}, w::SliceWindow, i::Integer) where {F <: Real}
    ts.A[(w.size * (i - 1)):(w.size * i), :]
end

# -*- Forecast -*- #
abstract type Forecast end

struct MirrorForecast <: Forecast
    size::Int

    function MirrorForecast(size::Integer)
        new(size)
    end
end

function forecast(ts::TimeSeries, f::Forecast, i::Integer)

end