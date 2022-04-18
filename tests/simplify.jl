# Demes simplification into demographic model with minimal redundancy

include("demes_utils.jl")

function simplifyGraph(data::Dict)
    # Returns a simplified demographic model without redundancies or empty fields
    simplified = Dict()
    # Time units and generation time
    simplified["time_units"] = data["time_units"]
    if data["time_units"] != "generations"
        simplified["generation_time"] = data["generation_time"]
    end
    # simplify demes
    deme_intervals = getDemeIntervals(data)
    simplified["demes"] = simplifyDemes(data, deme_intervals)
    # simplify migrations
    if "migrations" in keys(data) && length(data["migrations"]) > 0
        simplified["migrations"] = simplifyMigrations(data, deme_intervals)
    end
    # simplify pulses
    if "pulses" in keys(data) && length(data["pulses"]) > 0
        simplified["pulses"] = data["pulses"]
    end
    # simplify graph-level items
    if "description" in keys(data) && length(data["description"]) > 0
        simplified["description"] = data["description"]
    end
    if "doi" in keys(data) && length(data["doi"]) > 0
        simplified["doi"] = data["doi"]
    end
    if "defaults" in keys(data) && length(data["defaults"]) > 0
        # TODO: do defaults need any extra simplification?
        # defaults will affect how we simplify demes...
        simplified["defaults"] = data["defaults"]
    end
    return simplified
end

function simplifyDemes(data, deme_intervals)
    # TODO
    demes = Dict{Any, Any}[]
    for deme in data["demes"]
        new_deme = Dict{Any, Any}()
        # the name is always present
        new_deme["name"] = deme["name"]
        # ancestors and proportions
        if "ancestors" in keys(deme)
            if length(deme["ancestors"]) > 0
                new_deme["ancestors"] = deme["ancestors"]
            end
            if "proportions" in keys(deme) && length(deme["proportions"]) > 1
                new_deme["proportions"] = deme["proportions"]
            end
        end
        # check if start time is needed
        if "start_time" in keys(deme)
            if "ancestors" in keys(deme)
                if length(deme["ancestors"]) > 1
                    new_deme["start_time"] = deme["start_time"]
                elseif (length(deme["ancestors"]) == 1 &&
                        deme_intervals[deme["ancestors"][1]][2] != deme["start_time"])
                    new_deme["start_time"] = deme["start_time"]
                end
            elseif deme["start_time"] != Inf
                new_deme["start_time"] = deme["start_time"]
            end
        end
        # epochs
        new_epochs = Dict{Any, Any}[]
        for epoch in deme["epochs"]
            new_epoch = Dict{Any, Any}()
            if "end_time" in keys(epoch) && epoch["end_time"] > 0
                new_epoch["end_time"] = epoch["end_time"]
            end
            # simplified graphs all have a start size
            if "start_size" in keys(epoch)
                new_epoch["start_size"] = epoch["start_size"]
            elseif "end_size" in keys(new_epochs[end])
                new_epoch["start_size"] = new_epochs[end]["end_size"]
            else
                new_epoch["start_size"] = new_epochs[end]["start_size"]
            end
            # set end size if it differs from the start size
            if "end_size" in keys(epoch)
                if new_epoch["start_size"] != epoch["end_size"]
                    new_epoch["end_size"] = epoch["end_size"]
                end
            end
            # size function if it isn't constant or exponential
            if "size_function" in keys(epoch)
                if epoch["size_function"] ∉ ["constant", "exponential"]
                    new_epoch["size_function"] = epoch["size_function"]
                end
            end
            # selfing and cloning rates
            if "cloning_rate" in keys(epoch) && epoch["cloning_rate"] != 0
                new_epoch["cloning_rate"] = epoch["cloning_rate"]
            end
            if "selfing_rate" in keys(epoch) && epoch["selfing_rate"] != 0
                new_epoch["selfing_rate"] = epoch["selfing_rate"]
            end
            # TODO: if cloning and selfing rates are in defaults, check there
            push!(new_epochs, new_epoch)
        end
        new_deme["epochs"] = new_epochs
        # description
        if "description" in keys(deme) && length(deme["description"]) > 0
            new_deme["description"] = deme["description"]
        end
        # append new deme to list of simplified demes
        push!(demes, new_deme)
    end
    return demes
end

function simplifyMigrations(data, deme_intervals)
    # TODO
    return data["migrations"]
end

