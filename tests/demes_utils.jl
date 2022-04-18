# Utility functions for working with demes data

function getDemeInterval(deme, data)
    if "start_time" in keys(deme)
        start_time = deme["start_time"]
    elseif "ancestors" in keys(deme)
        anc = deme["ancestors"][1]
        for deme2 in data["demes"]
            if deme2["name"] == anc
                start_time = deme2["epochs"][end]["end_time"]
            end
        end
    else
        start_time = Inf
    end
    if "end_time" in keys(deme["epochs"][end])
        end_time = deme["epochs"][end]["end_time"]
    else
        end_time = 0
    end
    return [start_time, end_time]
end

function getDemeIntervals(data)
    # Get the start and end times for each deme, returned as a dictionary
    deme_intervals = Dict{String, Array}()
    for deme in data["demes"]
        deme_intervals[deme["name"]] = getDemeInterval(deme, data)
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

function addDeme(data; name, epochs=Dict{Any, Any}[], start_time=nothing,
        description="", ancestors=String[], proportions=Float64[])
    new_deme = Dict(
                    "name" => name,
                    "description" => description,
                    "epochs" => epochs,
                    "start_time" => start_time,
                    "ancestors" => ancestors,
                    "proportions" => proportions
                   )
    # TODO: only add items that are specified
    push!(data["demes"], new_deme)
    return data
end

function addMigration(data)
    # TODO
end

function addPulse(data)
    # TODO
end
