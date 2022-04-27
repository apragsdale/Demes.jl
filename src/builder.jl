# Functions to iteratively build a graph
function buildGraph(data::Dict)
    # The input data is a dictionary, such as parsed from a YAML
    graph = Graph()
    validateGraphDefaults(data)
    if "defaults" ∈ keys(data)
        default_data = data["defaults"]
        # check for valid default values
        if "epoch" in keys(default_data)
            validateEpochData(default_data["epoch"])
        end
    else
        default_data = Dict()
    end
    # add graph-level properties
    validateGraphTopLevel(data)
    if "description" ∈ keys(data)
        graph.description = data["description"]
    end
    if "doi" ∈ keys(data)
        for doi ∈ data["doi"]
            push!(graph.doi, doi)
        end
    end
    graph.time_units = data["time_units"]
    if "generation_time" ∈ keys(data)
        graph.generation_time = data["generation_time"]
    end
    if "defaults" ∈ keys(data)
        graph.defaults = data["defaults"]
    end
    # add demes
    validateGraphDemes(data)
    for deme_data ∈ data["demes"]
        addDeme!(graph, deme_data, default_data)
    end
    # add migrations
    if "migrations" ∈ keys(data)
        validateGraphMigrations(data)
        for migration_data ∈ data["migrations"]
            addMigration!(graph, migration_data, default_data)
        end
    end
    # add pulses, validating as we go
    if "pulses" ∈ keys(data)
        validateGraphPulses(data)
        for pulse_data ∈ data["pulses"]
            addPulse!(graph, pulse_data, default_data)
        end
    end
    return graph
end

function addDeme!(graph::Graph, deme_data::Dict, default_data::Dict)
    # adds the deme to the graph and validates
    # the input deme against the existing model
    deme_intervals = getDemeIntervals(graph)
    validateDemeNameDescription(deme_data, deme_intervals)
    deme = Deme(name = deme_data["name"])
    if "description" ∈ keys(deme_data)
        deme.description = deme_data["description"]
    end
    # add ancestors
    if "ancestors" ∈ keys(deme_data)
        # no changes needed
    elseif "deme" ∈ keys(default_data) && "ancestors" ∈ keys(default_data["deme"])
        deme_data["ancestors"] = default_data["deme"]["ancestors"]
    else
        deme_data["ancestors"] = String[]
    end
    validateDemeAncestors(deme_data, deme_intervals)
    deme.ancestors = deme_data["ancestors"]
    # add proportions
    if "proportions" ∈ keys(deme_data)
        # no changes needed
    elseif "deme" ∈ keys(default_data) && "proportions" ∈ keys(default_data["deme"])
        deme_data["proportions"] = default_data["deme"]["proportions"]
    elseif length(deme_data["ancestors"]) == 1
        deme_data["proportions"] = [1]
    else
        deme_data["proportions"] = Number[]
    end
    validateDemeProportions(deme_data)
    deme.proportions = deme_data["proportions"]
    # add start time
    if "start_time" ∈ keys(deme_data)
        start_time = validateDemeStartTime(deme_data, deme_intervals)
        deme.start_time = start_time
    elseif "deme" ∈ keys(default_data) && "start_time" ∈ keys(default_data["deme"])
        deme_data["start_time"] = default_data["deme"]["start_time"]
        start_time = validateDemeStartTime(deme_data, deme_intervals)
        deme.start_time = start_time
    else
        if length(deme_data["ancestors"]) > 1
            throw(DemesError("start time required with multiple ancestors"))
        elseif length(deme_data["ancestors"]) == 1
            deme_data["start_time"] = deme_intervals[deme_data["ancestors"][1]][2]
            start_time = validateDemeStartTime(deme_data, deme_intervals)
            deme.start_time = start_time
        else
            deme.start_time = Inf
        end
    end
    # add epochs
    if "defaults" ∈ keys(deme_data)
        validateDemeDefaultsFields(deme_data["defaults"])
        if "epoch" ∈ keys(deme_data["defaults"])
            validateEpochData(deme_data["defaults"]["epoch"])
        end
    end
    if "epochs" ∉ keys(deme_data) || length(deme_data["epochs"]) == 0
        if "defaults" ∈ keys(deme_data) && "epoch" ∈ keys(deme_data["defaults"])
            epoch_data = deme_data["defaults"]["epoch"]
            addEpochDefaults!(epoch_data, default_data)
            addEpoch!(deme, epoch_data)
        elseif "epoch" ∉ keys(default_data)
            throw(DemesError("at least one epoch must be provided"))
        else
            epoch_data = default_data["epoch"]
            validateEpochData(epoch_data)
            validateEpochData(epoch_data)
            addEpoch!(deme, epoch_data)
        end
    else
        for epoch_data ∈ deme_data["epochs"]
            if "defaults" ∈ keys(deme_data) && "epoch" ∈ keys(deme_data["defaults"])
                addEpochDefaults!(epoch_data, deme_data["defaults"])
            end
            validateEpochData(epoch_data)
            addEpochDefaults!(epoch_data, default_data)
            validateEpochData(epoch_data)
            addEpoch!(deme, epoch_data)
        end
    end
    validateResolvedDeme(deme)
    push!(graph.demes, deme)
    return graph
end

function addEpoch!(deme::Deme, epoch_data::Dict)
    epoch = Epoch()
    # start time
    if "start_time" ∈ keys(epoch_data)
        if (
            length(deme.epochs) >= 1 &&
            epoch_data["start_time"] != deme.epochs[end].end_time
        )
            throw(DemesError("epoch start time must match previous epoch end time"))
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
    elseif "end_size" ∈ keys(epoch_data)
        epoch.start_size = epoch_data["end_size"]
    else
        throw(DemesError("start or end size must be given for first epoch in a deme"))
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
        validateEpochCloningRate(epoch_data)
        epoch.cloning_rate = epoch_data["cloning_rate"]
    else
        epoch.cloning_rate = 0
    end
    # selfing rate
    if "selfing_rate" ∈ keys(epoch_data)
        validateEpochSelfingRate(epoch_data)
        epoch.selfing_rate = epoch_data["selfing_rate"]
    else
        epoch.selfing_rate = 0
    end
    push!(deme.epochs, epoch)
end

function addEpochDefaults!(epoch_data::Dict, default_data::Dict)
    # add default data to epoch
    if "epoch" ∈ keys(default_data)
        for k in [
            "start_time",
            "end_time",
            "start_size",
            "end_size",
            "size_function",
            "cloning_rate",
            "selfing_rate",
        ]
            if k ∉ keys(epoch_data) && k ∈ keys(default_data["epoch"])
                epoch_data[k] = default_data["epoch"][k]
            end
        end
    end
end

function getAsymmetricMigration(
    migration_data::Dict,
    source::String,
    dest::String,
    deme_intervals::Dict,
)
    start_time = validateMigrationStartTime(migration_data, source, dest, deme_intervals)
    end_time = validateMigrationEndTime(migration_data, source, dest, deme_intervals)
    if start_time <= end_time
        throw(DemesError("migration start time must be larger than end time"))
    end
    mig = Migration(
        source = source,
        dest = dest,
        start_time = start_time,
        end_time = end_time,
        rate = migration_data["rate"],
    )
    return mig
end

function addMigrationDefaults!(migration_data::Dict, default_data::Dict)
    if "migration" ∈ keys(default_data)
        if "rate" ∉ keys(migration_data)
            if "rate" ∈ keys(default_data["migration"])
                migration_data["rate"] = default_data["migration"]["rate"]
            end
        end
        if "demes" ∉ keys(migration_data)
            if "source" ∉ keys(migration_data) && "dest" ∉ keys(migration_data)
                if "demes" ∈ keys(default_data["migration"])
                    migration_data["demes"] = default_data["migration"]["demes"]
                end
            end
            if "source" ∉ keys(migration_data) && "source" ∈ keys(default_data["migration"])
                migration_data["source"] = default_data["migration"]["source"]
            end
            if "dest" ∉ keys(migration_data) && "dest" ∈ keys(default_data["migration"])
                migration_data["dest"] = default_data["migration"]["dest"]
            end
        end
    end
end

function addMigration!(graph::Graph, migration_data::Dict, default_data::Dict)
    # migrations are decomposed into asymmetric migrations
    deme_intervals = getDemeIntervals(graph)
    addMigrationDefaults!(migration_data, default_data)
    validateMigrationData(migration_data)
    if "demes" ∈ keys(migration_data)
        # add for symmetric migrations, given demes in the migration dict
        for comb ∈ combinations(migration_data["demes"], 2)
            deme1 = comb[1]
            deme2 = comb[2]
            mig = getAsymmetricMigration(migration_data, deme1, deme2, deme_intervals)
            push!(graph.migrations, mig)
            mig = getAsymmetricMigration(migration_data, deme2, deme1, deme_intervals)
            push!(graph.migrations, mig)
        end
    else
        mig = getAsymmetricMigration(
            migration_data,
            migration_data["source"],
            migration_data["dest"],
            deme_intervals,
        )
        push!(graph.migrations, mig)
    end
end

function addPulseDefaults!(pulse_data::Dict, default_data::Dict)
    # add default data to pulse
    if "pulse" ∈ keys(default_data)
        for k in ["time", "sources", "dest", "proportions"]
            if k ∉ keys(pulse_data) && k ∈ keys(default_data["pulse"])
                pulse_data[k] = default_data["pulse"][k]
            end
        end
    end
end

function addPulse!(graph::Graph, pulse_data::Dict, default_data::Dict)
    deme_intervals = getDemeIntervals(graph)
    addPulseDefaults!(pulse_data, default_data)
    validatePulseFields(pulse_data)
    validatePulseDemes(pulse_data)
    validatePulseTiming(pulse_data, deme_intervals)
    validatePulseProportions(pulse_data)
    pulse = Pulse(
        sources = pulse_data["sources"],
        dest = pulse_data["dest"],
        proportions = pulse_data["proportions"],
        time = pulse_data["time"],
    )
    push!(graph.pulses, pulse)
end
