# Utility functions for working with demes data
function getDemeIntervals(data::Graph)
    # Get the start and end times for each deme, returned as a dictionary
    deme_intervals = Dict{String,Array}()
    for deme in data.demes
        deme_intervals[deme.name] = [deme.start_time, deme.epochs[end].end_time]
    end
    return deme_intervals
end

function sliceGraph(data, time)
    # Takes an input demographic model and returns two demographic models, one
    # above and one below the slice time
    # TODO
end

function pruneGraph(data, focal_demes)
    # Takes an input demographic model and set of demes, and removes other demes
    # that do not affect the ancestry of any possible sample from the focal demes.
    # TODO
end

# Custom errors
mutable struct DemeError <: Exception
    deme::String
    msg::String
end

Base.showerror(io::IO, e::DemeError) = print(io, "in deme ", e.deme, " -- ", e.msg)

mutable struct GraphError <: Exception
    msg::String
end

Base.showerror(io::IO, e::GraphError) = print(io, e.msg)

mutable struct PulseError <: Exception
    msg::String
end

Base.showerror(io::IO, e::PulseError) = print(io, e.msg)

mutable struct MigrationError <: Exception
    msg::String
end

Base.showerror(io::IO, e::MigrationError) = print(io, e.msg)

mutable struct EpochError <: Exception
    msg::String
end

Base.showerror(io::IO, e::EpochError) = print(io, e.msg)
