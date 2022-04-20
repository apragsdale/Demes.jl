# A demes model (a Graph) is defined as a struct, containing
# top-level information (description, doi, time units, generation times, and defaults)
# demes, migrations, and pulses.

import Base.@kwdef

@kwdef mutable struct Migration
    start_time::Number = Inf
    end_time::Number = 0
    source::String = ""
    dest::String = ""
    rate::Number = 0
end

@kwdef mutable struct Pulse
    time::Number = 0
    sources::Array{String} = []
    dest::String = ""
    proportions::Array{Number} = []
end

@kwdef mutable struct Epoch
    start_time::Number = Inf
    end_time::Number = 0
    start_size::Number = 1
    end_size::Number = 1
    size_function::String = ""
    selfing_rate::Number = 0
    cloning_rate::Number = 0
end

@kwdef mutable struct Deme
    name::String = ""
    description::String = ""
    start_time::Number = Inf
    epochs::Array{Epoch} = []
    ancestors::Array{String} = []
    proportions::Array{Number} = []
end

@kwdef mutable struct Graph
    description::String = ""
    time_units::String = "generations"
    generation_time::Number = 1
    doi::Array{String} = []
    demes::Array{Deme} = []
    migrations::Array{Migration} = []
    pulses::Array{Pulse} = []
    defaults::Dict{Any, Any} = Dict()
end
