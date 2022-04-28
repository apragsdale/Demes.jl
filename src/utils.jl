# Utility functions for working with demes data
function getDemeIntervals(graph::Graph)
    # Get the start and end times for each deme, returned as a dictionary
    deme_intervals = Dict{String,Array}()
    for deme in graph.demes
        deme_intervals[deme.name] = [deme.start_time, deme.epochs[end].end_time]
    end
    return deme_intervals
end

function getDiscreteDemographicEvents(graph::Graph)
    # Get discrete demographic events, including 
    # pulses, splits, branches, mergers, and admixtures
    # Returns a Dict with sorted lists of each event
    demographic_events = Dict{String,Vector}()
    demographic_events["pulses"] = graph.pulses
    demographic_events["splits"] = Split[]
    demographic_events["branches"] = Branch[]
    demographic_events["mergers"] = Merger[]
    demographic_events["admixtures"] = Admixture[]
    # add splits at the end, after collecting all child demes
    deme_intervals = getDemeIntervals(graph)
    splits = Dict{String,Set{String}}()
    for deme in graph.demes
        if length(deme.ancestors) == 1
            parent = deme.ancestors[1]
            if deme.start_time > deme_intervals[parent][2]
                # branch event
                push!(
                    demographic_events["branches"],
                    Branch(parent = parent, child = deme.name, time = deme.start_time),
                )
            else
                if parent in keys(splits)
                    push!(splits[parent], deme.name)
                else
                    splits[parent] = Set([deme.name])
                end
            end
        elseif length(deme.ancestors) > 1
            end_times = Number[]
            for anc in deme.ancestors
                push!(end_times, deme_intervals[anc][2])
            end
            if isless(end_times, [deme.start_time])
                push!(
                    demographic_events["admixtures"],
                    Admixture(
                        parents = deme.ancestors,
                        proportions = deme.proportions,
                        child = deme.name,
                        time = deme.start_time,
                    ),
                )
            else
                push!(
                    demographic_events["mergers"],
                    Merger(
                        parents = deme.ancestors,
                        proportions = deme.proportions,
                        child = deme.name,
                        time = deme.start_time,
                    ),
                )
            end
        end
    end
    for split in pairs(splits)
        push!(
            demographic_events["splits"],
            Split(
                parent = split[1],
                children = sort(collect(split[2])),
                time = deme_intervals[split[1]][2],
            ),
        )
    end
    # TODO: stably sort by times
    return demographic_events
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
mutable struct DemesError <: Exception
    msg::String
end

Base.showerror(io::IO, e::DemesError) = print(io, "DemesError: ", e.msg)
