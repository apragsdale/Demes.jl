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

# Functions for checking equality of graph and graph components

function isGraphEqual(graph1::Graph, graph2::Graph; metadata::Bool = false)
    # check top-level attributes
    top_level_equal = isTopLevelEqual(graph1, graph2)
    if top_level_equal == false
        return false
    end
    # check demes equality
    demes_equal = isDemesEqual(graph1, graph2)
    if demes_equal == false
        return false
    end
    # check migrations equality
    migrations_equal = isMigrationsEqual(graph1, graph2)
    if migrations_equal == false
        return false
    end
    # check pulse equality (after a stable sort on time)
    pulses_equal = isPulsesEqual(graph1, graph2)
    if pulses_equal == false
        return false
    end
    # check metadata equality if specified
    if metadata && graph1.metadata != graph2.metadata
        return false
    end
    return true
end

function isTopLevelEqual(graph1::Graph, graph2::Graph)
    top_level_equal = true
    desc1 = graph1.description
    desc2 = graph2.description
    desc1 = replace(desc1, "\n" => " ")
    desc2 = replace(desc2, "\n" => " ")
    if desc1 != desc2 ||
       graph1.time_units != graph2.time_units ||
       graph1.generation_time != graph2.generation_time ||
       Set(graph1.doi) != Set(graph2.doi)
        top_level_equal = false
    end
    return top_level_equal
end

function isDemesEqual(graph1::Graph, graph2::Graph)
    # equal length of demes
    if length(graph1.demes) != length(graph2.demes)
        return false
    else
        demes2 = Dict{String,Deme}()
        for deme2 in graph2.demes
            demes2[deme2.name] = deme2
        end
        for deme1 ∈ graph1.demes
            if deme1.name ∉ keys(demes2)
                return false
            else
                deme2 = demes2[deme1.name]
                if isDemeEqual(deme1, deme2) == false
                    return false
                end
            end
        end
    end
end

function isDemeEqual(deme1::Deme, deme2::Deme)
    if deme1.description != deme2.description
        return false
    elseif Dict(zip(deme1.ancestors, deme1.proportions)) !=
           Dict(zip(deme2.ancestors, deme2.proportions))
        return false
    elseif deme1.start_time != deme2.start_time
        return false
    else
        if length(deme1.epochs) != length(deme2.epochs)
            return false
        else
            for epochs in zip(deme1.epochs, deme2.epochs)
                if isEpochEqual(epochs[1], epochs[2]) == false
                    return false
                end
            end
        end
    end
    return true
end

function isEpochEqual(epoch1::Epoch, epoch2::Epoch)
    if epoch1.start_time != epoch2.start_time
        return false
    elseif epoch1.end_time != epoch2.end_time
        return false
    elseif epoch1.start_size != epoch2.start_size
        return false
    elseif epoch1.end_size != epoch2.end_size
        return false
    elseif epoch1.size_function != epoch2.size_function
        return false
    elseif epoch1.cloning_rate != epoch2.cloning_rate
        return false
    elseif epoch1.selfing_rate != epoch2.selfing_rate
        return false
    else
        return true
    end
end

function isMigrationsEqual(graph1::Graph, graph2::Graph)
    migs1 = graph1.migrations
    migs2 = graph2.migrations
    if length(migs1) != length(migs2)
        return false
    else
        for mig1 ∈ migs1
            match_mig2 = false
            for mig2 ∈ migs2
                if isMigrationEqual(mig1, mig2) == true
                    match_mig2 = true
                end
            end
            if match_mig2 == false
                return false
            end
        end
        # should be unnecessary to test the reverse, but to be sure...
        for mig2 ∈ migs2
            match_mig1 = false
            for mig1 ∈ migs1
                if isMigrationEqual(mig1, mig2) == true
                    match_mig1 = true
                end
            end
            if match_mig1 == false
                return false
            end
        end
    end
end

function isMigrationEqual(mig1::Migration, mig2::Migration)
    if mig1.start_time != mig2.start_time
        return false
    elseif mig1.end_time != mig2.end_time
        return false
    elseif mig1.source != mig2.source
        return false
    elseif mig1.dest != mig2.dest
        return false
    elseif mig1.rate != mig2.rate
        return false
    else
        return true
    end
end

function isPulsesEqual(graph1::Graph, graph2::Graph)
    # stable sort of each pulse list
    pulses1 = sortPulses(graph1.pulses)
    pulses2 = sortPulses(graph2.pulses)
    # check pulse equality
    for ps ∈ zip(pulses1, pulses2)
        pulse1 = ps[1]
        pulse2 = ps[2]
        if isPulseEqual(pulse1, pulse2) == false
            return false
        end
    end
    return true
end

function sortPulses(pulses::Vector{Pulse})
    times = []
    sorted_pulses = []
    for pulse ∈ pulses
        push!(times, pulse.time)
    end
    perm = sortperm(times, alg = InsertionSort)[end:-1:1]
    for i ∈ perm
        push!(sorted_pulses, pulses[i])
    end
    return sorted_pulses
end

function isPulseEqual(pulse1::Pulse, pulse2::Pulse)
    if pulse1.time != pulse2.time
        return false
    elseif Dict(zip(pulse1.sources, pulse1.proportions)) !=
           Dict(zip(pulse2.sources, pulse2.proportions))
        return false
    elseif pulse1.dest != pulse2.dest
        return false
    else
        return true
    end
end
