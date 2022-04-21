# Functions to iteratively build a graph
function buildGraph(data::Dict)
    # The input data is a dictionary, such as parsed from a YAML
    graph = Graph()
    # add graph-level properties
    if "description" ∈ keys(data)
        graph.description = data["description"]
    end
    if "doi" ∈ keys(data)
        for doi ∈ data["doi"]
            push!(graph.doi, doi)
        end
    end
    if "time_units" ∈ keys(data)
        graph.time_units = data["time_units"]
    end
    if "generation_time" ∈ keys(data)
        graph.generation_time = data["generation_time"]
    end
    if "defaults" ∈ keys(data)
        graph.defaults = data["defaults"]
    end
    # add demes, validating as we go
    if "demes" ∉ keys(data)
        error("Input graph must have at least one deme")
    end
    for deme_data ∈ data["demes"]
        addDeme!(graph, deme_data)
    end
    # add migrations, validating as we go
    if "migrations" ∈ keys(data)
        for migration_data ∈ data["migrations"]
            addMigration!(graph, migration_data)
        end
    end
    # add pulses, validating as we go
    if "pulses" ∈ keys(data)
        for pulse_data ∈ data["pulses"]
            addPulse!(graph, pulse_data)
        end
    end
    return graph
end

function addEpoch!(deme::Deme, epoch_data::Dict)
    epoch = Epoch()
    # start time
    if "start_time" ∈ keys(epoch_data)
        if (length(deme.epochs) >= 1 &&
            epoch_data["start_time"] != deme.epochs[end].end_time)
            error("Epoch start time must match last epoch's end time")
        end
        epoch.start_time = epoch_data["start_time"]
    elseif length(deme.epochs) >= 1
        epoch.start_time = deme.epochs[end].end_time
    else
        epoch.start_time = deme.start_time
    end
    # end time
    if "end_time" ∈ keys(epoch_data)
        epoch.end_time = epoch_data["end_time"]
    else
        epoch.end_time = 0
    end
    # start size
    if "start_size" ∈ keys(epoch_data)
        epoch.start_size = epoch_data["start_size"]
    elseif length(deme.epochs) >= 1
        epoch.start_size = deme.epochs[end].end_size
    else
        error("Start size must be given for first epoch ∈ a deme")
    end
    # end size
    if "end_size" ∈ keys(epoch_data)
        epoch.end_size = epoch_data["end_size"]
    else
        epoch.end_size = epoch.start_size
    end
    # size function
    if "size_function" ∈ keys(epoch_data)
        epoch.size_function = epoch_data["size_function"]
    elseif epoch.start_size == epoch.end_size
        epoch.size_function = "constant"
    else
        epoch.size_function = "exponential"
    end
    # cloning rate
    if "cloning_rate" ∈ keys(epoch_data)
        epoch.cloning_rate = epoch_data["cloning_rate"]
    else
        epoch.cloning_rate = 0
    end
    # selfing rate
    if "selfing_rate" ∈ keys(epoch_data)
        epoch.selfing_rate = epoch_data["selfing_rate"]
    else
        epoch.selfing_rate = 0
    end
    push!(deme.epochs, epoch)
end

function addDeme!(graph::Graph, deme_data::Dict)
    # adds the deme to the graph and validates
    # the input deme against the existing model
    # TODO: work with defaults
    deme_intervals = getDemeIntervals(graph)
    validateDemeNameDescription(deme_data, deme_intervals)
    deme = Deme(name=deme_data["name"])
    if "description" ∈ keys(deme_data)
        deme.description = deme_data["description"]
    end
    # add start time
    if "start_time" ∈ keys(deme_data)
        validateDemeStartTime(deme_data, deme_intervals)
        deme.start_time = deme_data["start_time"]
    else
        # check start time is given for multiple ancestors
        if "ancestors" ∈ keys(deme_data)
            if length(deme_data["ancestors"]) > 1
                error("Start time must be given if deme has multiple ancestors")
            elseif length(deme_data["ancestors"]) == 1
                deme.start_time = deme_intervals[deme_data["ancestors"][1]][2]
            else
                deme.start_time = Inf
            end
        else
            deme.start_time = Inf
        end
    end
    # add ancestors and proportions
    if "ancestors" ∈ keys(deme_data)
        validateDemeAncestorsProportions(deme_data)
        if length(deme_data["ancestors"]) == 1
            deme.ancestors = deme_data["ancestors"]
            deme.proportions = [1]
        elseif length(deme_data["ancestors"]) > 1
            deme.ancestors = deme_data["ancestors"]
            deme.proportions = deme_data["proportions"]
        end
    end
    # add epochs
    if "epochs" ∉ keys(deme_data) || length(deme_data["epochs"]) == 0
        error("At least one epoch must be provided")
    end
    for epoch_data ∈ deme_data["epochs"]
        addEpoch!(deme, epoch_data)
    end
    if deme.start_time != deme.epochs[1].start_time
        error("Start time mismatch")
    end
    push!(graph.demes, deme)
    return graph
end

function getAsymmetricMigration(
        migration_data::Dict, source::String, dest::String, deme_intervals::Dict)
    start_time = validateMigrationStartTime(migration_data, source, dest, deme_intervals)
    end_time = validateMigrationEndTime(migration_data, source, dest, deme_intervals)
    if start_time <= end_time
        error("Migration start time must be larger than migration end time")
    end
    mig = Migration(
                    source=source,
                    dest=dest,
                    start_time=start_time,
                    end_time=end_time,
                    rate=migration_data["rate"]
                   )
    return mig
end

function addMigration!(graph::Graph, migration_data::Dict)
    # migrations are decomposed into asymmetric migrations
    deme_intervals = getDemeIntervals(graph)
    if "rate" ∉ keys(migration_data)
        error("Migration rate must be provided")
    end
    if "demes" ∈ keys(migration_data)
        if isa(migration_data["demes"], AbstractArray)
            for comb ∈ combinations(migration_data["demes"], 2)
                deme1 = comb[1]
                deme2 = comb[2]
                mig = getAsymmetricMigration(migration_data, deme1, deme2, deme_intervals)
                push!(graph.migrations, mig)
                mig = getAsymmetricMigration(migration_data, deme2, deme1, deme_intervals)
                push!(graph.migrations, mig) 
            end
        else
            error("Migration demes must be an Array")
        end
    else
        if "source" ∉ keys(migration_data) || "dest" ∉ keys(migration_data)
            error("Either demes or source and dest must be given")
        end
        mig = getAsymmetricMigration(migration_data, source, dest, deme_intervals)
        push!(graph.migrations, mig)
    end
end

function addPulse!(graph::Graph, pulse_data::Dict)
    deme_intervals = getDemeIntervals(graph)
    validatePulseFields(pulse_data)
    validatePulseDemes(pulse_data)
    validatePulseTiming(pulse_data)
    validatePulseProportions(pulse_data)
    pulse = Pulse(
                  sources=pulse_data["sources"],
                  dest=pulse_data["dest"],
                  proportions=pulse_data["proportions"],
                  time=pulse_data["time"]
                  )
    push!(graph.pulses, pulse)
end
