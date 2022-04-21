# Convert a Graph into a Dict

function asDict(graph::Graph)
    data = Dict()
    if length(graph.description) > 0
        data["description"] = graph.description
    end
    if length(graph.doi) > 0
        data["doi"] = graph.doi
    end
    data["time_units"] = graph.time_units
    if graph.time_units != "generations"
        data["generation_time"] = graph.generation_time
    end
    data["demes"] = Dict[]
    for deme in graph.demes
        deme_dict = Dict("name" => deme.name, "start_time" => deme.start_time)
        if length(deme.description) > 0
            deme_dict["description"] = deme.description
        end
        if length(deme.ancestors) > 0
            deme_dict["ancestors"] = deme.ancestors
        end
        if length(deme.ancestors) > 1
            deme_dict["proportions"] = deme.proportions
        end
        deme_dict["epochs"] = Dict[]
        for epoch in deme.epochs
            epoch_dict = Dict(
                              "start_time" => epoch.start_time,
                              "end_time" => epoch.end_time,
                              "start_size" => epoch.start_size,
                              "end_size" => epoch.end_size,
                              "size_function" => epoch.size_function
                             )
            if epoch.cloning_rate != 0
                epoch_dict["cloning_rate"] = epoch.cloning_rate
            end
            if epoch.selfing_rate != 0
                epoch_dict["selfing_rate"] = epoch.selfing_rate
            end
            push!(deme_dict["epochs"], epoch_dict)
        end
        push!(data["demes"], deme_dict)
    end
    if length(graph.migrations) > 0
        data["migrations"] = Dict[]
        for migration in graph.migrations
            mig_dict = Dict(
                            "start_time" => migration.start_time,
                            "end_time" => migration.end_time,
                            "source" => migration.source,
                            "dest" => migration.dest,
                            "rate" => migration.rate
                           )
            push!(data["migrations"], mig_dict)
        end
    end
    if length(graph.pulses) > 0
        data["pulses"] = Dict[]
        for pulse in graph.pulses
            pulse_dict = Dict(
                              "time" => pulse.time,
                              "sources" => pulse.sources,
                              "dest" => pulse.dest,
                              "proportions" => pulse.proportions
                             )
            push!(data["pulses"], pulse_dict)
        end
    end
    return data
end

function asDictSimplified(graph::Graph)
    deme_intervals = getDemeIntervals(graph)
    simplified = Dict{Any, Any}()
    simplified = Dict()
    if length(graph.description) > 0
        simplified["description"] = graph.description
    end
    if length(graph.doi) > 0
        simplified["doi"] = graph.doi
    end
    simplified["time_units"] = graph.time_units
    if graph.time_units != "generations"
        simplified["generation_time"] = graph.generation_time
    end
    simplified["demes"] = Dict[]
    for deme in graph.demes
        deme_dict = Dict{Any, Any}("name" => deme.name)
        if length(deme.description) > 0
            deme_dict["description"] = deme.description
        end
        if length(deme.ancestors) > 0
            deme_dict["ancestors"] = deme.ancestors
        end
        if length(deme.ancestors) > 1
            deme_dict["proportions"] = deme.proportions
        end
        if length(deme.ancestors) > 1
            deme_dict["start_time"] = deme.start_time
        elseif length(deme.ancestors) == 1
            if deme.start_time != deme_intervals[deme.ancestors[1]][2]
                deme_dict["start_time"] = deme.start_time
            end
        elseif deme.start_time != Inf
            deme_dict["start_time"] = deme.start_time
        end
        deme_dict["epochs"] = Dict[]
        for epoch in deme.epochs
            epoch_dict = Dict{Any, Any}(
                              "end_time" => epoch.end_time,
                              "start_size" => epoch.start_size,
                             )
            if epoch.end_size != epoch.start_size
                epoch_dict["end_size"] = epoch.end_size
                if epoch.size_function != "exponential"
                    epoch_dict["size_function"] = epoch.size_function
                end
            end
            if epoch.cloning_rate != 0
                epoch_dict["cloning_rate"] = epoch.cloning_rate
            end
            if epoch.selfing_rate != 0
                epoch_dict["selfing_rate"] = epoch.selfing_rate
            end
            push!(deme_dict["epochs"], epoch_dict)
        end
        push!(simplified["demes"], deme_dict)
    end
    return simplified
end
