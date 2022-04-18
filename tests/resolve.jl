# Demes resolution into fully redundant model

include("demes_utils.jl")

function fillDeme(deme, deme_intervals, data)
    # Fill in all fields of a deme
    # Returns a new deme dict
    # TODO: work with default values
    full_deme = Dict{Any, Any}()
    full_deme["name"] = deme["name"]
    if "description" in keys(deme)
        full_deme["description"] = deme["description"]
    else
        full_deme["description"] = nothing
    end
    if "ancestors" in keys(deme)
        full_deme["ancestors"] = deme["ancestors"]
    else
        full_deme["ancestors"] = []
    end
    if "proportions" in keys(deme)
        full_deme["proportions"] = deme["proportions"]
    elseif "ancestors" in keys(deme)
        if length(deme["ancestors"]) == 1
            full_deme["proportions"] = [1.0]
        end
    else
        full_deme["proportions"] = []
    end
    if "start_time" in keys(deme)
        full_deme["start_time"] = deme["start_time"]
    elseif "ancestors" in keys(deme)
        if length(deme["ancestors"]) == 1
            full_deme["start_time"] = deme_intervals[deme["ancestors"][1]][2]
        else
            error("Too many ancestors!")
        end
    else
        full_deme["start_time"] = Inf
    end
    full_deme["epochs"] = Dict{Any, Any}[]
    for epoch in deme["epochs"]
        full_epoch = Dict{Any, Any}()
        # end time
        if "end_time" in keys(epoch)
            full_epoch["end_time"] = epoch["end_time"]
        else
            full_epoch["end_time"] = 0
        end
        # start size
        if "start_size" in keys(epoch)
            full_epoch["start_size"] = epoch["start_size"]
        else
            full_epoch["start_size"] = full_deme["epochs"][end]["end_time"]
        end
        # end size
        if "end_size" in keys(epoch)
            full_epoch["end_size"] = epoch["end_size"]
        else
            full_epoch["end_size"] = full_epoch["start_size"]
        end
        # size function
        if "size_function" in keys(epoch)
            full_epoch["size_function"] = epoch["size_function"]
        elseif full_epoch["start_size"] == full_epoch["end_size"]
            full_epoch["size_function"] = "constant"
        else
            full_epoch["size_function"] = "exponential"
        end
        # selfing rate
        if "selfing_rate" in keys(epoch)
            full_epoch["selfing_rate"] = epoch["selfing_rate"]
        else
            full_epoch["selfing_rate"] = 0
        end
        # cloning rate
        if "cloning_rate" in keys(epoch)
            full_epoch["cloning_rate"] = epoch["cloning_rate"]
        else
            full_epoch["cloning_rate"] = 0
        end
        push!(full_deme["epochs"], full_epoch)
    end
    return full_deme
end

function fillGraph(data::Dict)
    # Fill in all fields of a graph
    # Returns a new demes graph as a Dict
    validateGraph(data)
    filled = Dict{Any, Any}()
    # add defaults
    if "defaults" ∉ keys(data)
        filled["defaults"] = Dict{Any, Any}()
    else
        filled["defaults"] = data["defaults"]
    end
    # add demes
    deme_intervals = getDemeIntervals(data)
    filled["demes"] = Dict{Any, Any}[]
    for deme in data["demes"]
        full_deme = fillDeme(deme, deme_intervals, data)
        push!(filled["demes"], full_deme)
    end
    # add description
    if "description" ∉ keys(data)
        filled["description"] = ""
    else
        filled["description"] = data["description"]
    end
    # add doi
    if "doi" ∉ keys(data)
        filled["doi"] = String[]
    else
        filled["doi"] = data["doi"]
    end
    # add generation time
    if "generation_time" ∉ keys(data)
        filled["generation_time"] = nothing
    else
        filled["generation_time"] = data["generation_time"]
    end
    # add migrations
    if "migrations" ∉ keys(data)
        filled["migrations"] = Dict{Any, Any}[]
    else
        filled["migrations"] = data["migrations"]
    end
    # add pulses
    if "pulses" ∉ keys(data)
        filled["pulses"] = Dict{Any, Any}[]
    else
        filled["pulses"] = data["pulses"]
    end
    # add time units
    filled["time_units"] = data["time_units"]
    return filled
end

