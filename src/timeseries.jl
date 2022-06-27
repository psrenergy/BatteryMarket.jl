struct TimeSeries{F <: Real}
    A::Array{F, 2}
    h::Vector{Symbol}
    k::Dict{Symbol, Int}
    
    function TimeSeries{F}(A::AbstractArray{<:Any, 2}, h::Symbol...) where {F <: Real}
        TimeSeries{F}(A, collect(h))
    end

    function TimeSeries{F}(A::AbstractArray{<:Any, 2}, h::Vector{Symbol}) where {F <: Real}
        @assert length(h) == size(A, 2)
        k = Dict{Symbol, Int}(x => i for (i, x) in enumerate(h))
        new{F}(A, h, k)
    end

    function TimeSeries(args...)
        TimeSeries{Float64}(args...)
    end
end

function Base.show(io::IO, ts::TimeSeries)
    println(io, join(ts.h, "\t"))
    for i = 1:length(ts)
        println(io, join(round.(ts.A[i, :]; digits=2), "\t"))
    end
end

Base.length(ts::TimeSeries) = size(ts.A, 1)

function Base.getindex(ts::TimeSeries, k::Symbol)
    @view ts.A[:, ts.k[k]]
end

function Base.write(path::AbstractString, ts::TimeSeries)
    return open(path, "w") do io
        write(io, ts)
    end
end

function Base.write(io::IO, ts::TimeSeries)
    CSV.write(io, CSV.Tables.table(ts.A; header=ts.h))
end

function Base.read(path::AbstractString, TS::Type{<:TimeSeries})
    return open(path, "r") do io
        read(io, TS)
    end
end

function Base.read(io::IO, TS::Type{<:TimeSeries})
    CSV.File(io) |> (fp -> TS(CSV.Tables.matrix(fp), CSV.getnames(fp)))
end

# -*- Window -*- #
abstract type Window end

struct SliceWindow <: Window
    size::Int

    function SliceWindow(size::Integer)
        new(size)
    end
end

function (w::SliceWindow)(ts::TimeSeries{F}, i::Integer) where F
    TimeSeries{F}(ts.A[(w.size * (i - 1) + 1):(w.size * i), :], ts.h)
end

Base.length(w::SliceWindow) = w.size

# -*- Forecast -*- #
abstract type Forecast end

struct MirrorForecast <: Forecast
    size::Int

    function MirrorForecast(size::Integer)
        new(size)
    end
end

function (f::MirrorForecast)(ts::TimeSeries{F}, i::Integer) where F
    TimeSeries{F}(ts.A[(f.size * (i - 1) + 1):(f.size * i), :], ts.h)
end

function ⊕(t::TimeSeries{F}, s::TimeSeries{F}) where {F <: Real}
    @assert t.h == s.h
    TimeSeries{F}([t.A;s.A], t.h)
end