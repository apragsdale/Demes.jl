# Functions to iteratively build a graph
function buildGraph(data::Dict)
    # The input data is a dictionary, such as parsed from a YAML
    graph = Graph()
    if "defaults" ∈ keys(data)
        default_data = data["defaults"]
    else
        default_data = Dict()
    end
    # add graph-level properties
    if "description" ∈ keys(data)
        graph.description = data["description"]
    end
    if "doi" ∈ keys(data)
        for doi ∈ data["doi"]
            push!(graph.doi, doi)
        end
    end
    if "time_units" ∉ keys(data)
        throw(GraphError("input graph must provide time units"))
    else
        graph.time_units = data["time_units"]
    end
    if "generation_time" ∈ keys(data)
        if data["time_units"] == "generations" && data["generation_time"] != 1
            throw(GraphError("generation time must be 1 when time units are generations"))
        end
        graph.generation_time = data["generation_time"]
    end
    if "defaults" ∈ keys(data)
        graph.defaults = data["defaults"]
    end
    # add demes, validating as we go
    if "demes" ∉ keys(data) || length(data["demes"]) == 0
        throw(GraphError("input graph must have at least one deme"))
    end
    for deme_data ∈ data["demes"]
        addDeme!(graph, deme_data, default_data)
    end
    # add migrations, validating as we go
    if "migrations" ∈ keys(data)
        for migration_data ∈ data["migrations"]
            addMigration!(graph, migration_data, default_data)
        end
    end
    # add pulses, validating as we go
    if "pulses" ∈ keys(data)
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
        ancestors = deme_data["ancestors"]
    elseif "deme" ∈ keys(default_data) && "ancestors" ∈ keys(default_data["deme"])
        ancestors = default_data["deme"]["ancestors"]
    else
        ancestors = String[]
    end
    deme.ancestors = ancestors
    # add proportions
    if "proportions" ∈ keys(deme_data)
        proportions = deme_data["proportions"]
    elseif "deme" ∈ keys(default_data) && "proportions" ∈ keys(default_data["deme"])
        proportions = default_data["deme"]["proportions"]
    elseif length(ancestors) == 1
        proportions = [1]
    else
        proportions = Number[]
    end
    validateDemeAncestorsProportions(ancestors, proportions, deme_data["name"])
    deme.proportions = proportions
    # add start time
    if "start_time" ∈ keys(deme_data)
        start_time = validateDemeStartTime(deme_data, deme_intervals)
        deme.start_time = start_time
    elseif "deme" ∈ keys(default_data) && "start_time" ∈ keys(default_data["deme"])
        deme_data["start_time"] = default_data["deme"]["start_time"]
        start_time = validateDemeStartTime(deme_data, deme_intervals)
        deme.start_time = start_time
    else
        if length(ancestors) > 1
            DemeError("Start time required with multiple ancestors")
        elseif length(ancestors) == 1
            deme.start_time = deme_intervals[deme_data["ancestors"][1]][2]
        else
            deme.start_time = Inf
        end
    end
    # add epochs
    if "epochs" ∉ keys(deme_data) || length(deme_data["epochs"]) == 0
        if "defaults" ∈ keys(deme_data) && "epoch" ∈ keys(deme_data["defaults"])
            epoch_data = deme_data["defaults"]["epoch"]
            addEpochDefaults!(epoch_data, default_data)
            addEpoch!(deme, epoch_data)
        elseif "epoch" ∉ keys(default_data)
            throw(DemeError(deme.name, "at least one epoch must be provided"))
        else
            epoch_data = default_data["epoch"]
            addEpoch!(deme, epoch_data)
        end
    else
        for epoch_data ∈ deme_data["epochs"]
            if "defaults" ∈ keys(deme_data) && "epoch" ∈ keys(deme_data["defaults"])
                addEpochDefaults!(epoch_data, deme_data["defaults"])
            end
            addEpochDefaults!(epoch_data, default_data)
            addEpoch!(deme, epoch_data)
        end
    end
    # check start times align
    if deme.start_time != deme.epochs[1].start_time
        throw(DemeError(deme.name, "start times mismatch"))
    end
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
            throw(EpochError("epoch start time must match previous epoch end time"))
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
        throw(EpochError("start or end size must be given for first epoch in a deme"))
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
        throw(MigrationError("migration start time must be larger than end time"))
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
    # this would be better that that long elseif stuff below
    # just need to be careful to not add each demes, source, and dest
end

function addMigration!(graph::Graph, migration_data::Dict, default_data::Dict)
    # migrations are decomposed into asymmetric migrations
    deme_intervals = getDemeIntervals(graph)
    if "rate" ∉ keys(migration_data)
        if "migration" ∈ keys(default_data) && "rate" ∈ keys(default_data["migration"])
            migration_data["rate"] = default_data["migration"]["rate"]
        else
            throw(MigrationError("migration rate must be provided"))
        end
    end
    if "demes" ∈ keys(migration_data)
        # add for symmetric migrations, given demes in the migration dict
        if "source" ∈ keys(migration_data) || "dest" ∈ keys(migration_data)
            throw(
                MigrationError("migration can have demes or source and dest but not both"),
            )
        end
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
            throw(MigrationError("migration demes must be an array"))
        end
    elseif "source" ∈ keys(migration_data)
        # add if source is given in migration dict
        if "dest" ∈ keys(migration_data)
            dest = migration_data["dest"]
        elseif "migration" ∈ keys(default_data) && "dest" ∈ keys(default_data["migration"])
            dest = default_data["migration"]["dest"]
        else
            throw(MigrationError("migration must have dest"))
        end
        mig = getAsymmetricMigration(
            migration_data,
            migration_data["source"],
            dest,
            deme_intervals,
        )
        push!(graph.migrations, mig)
    elseif "dest" ∈ keys(migration_data)
        # add if dest is given in migration dict
        if "migration" ∈ keys(default_data) && "source" ∈ keys(default_data["migration"])
            source = default_data["migration"]["source"]
        else
            throw(MigrationError("migration must have source"))
        end
        mig = getAsymmetricMigration(
            migration_data,
            source,
            migration_data["dest"],
            deme_intervals,
        )
        push!(graph.migrations, mig)
    elseif "migration" in keys(default_data)
        # add for default migration demes
        if "demes" in keys(default_data["migration"])
            # add for given default demes
            if isa(default_data["migration"]["demes"], AbstractArray)
                for comb ∈ combinations(default_data["migration"]["demes"], 2)
                    deme1 = comb[1]
                    deme2 = comb[2]
                    mig =
                        getAsymmetricMigration(migration_data, deme1, deme2, deme_intervals)
                    push!(graph.migrations, mig)
                    mig =
                        getAsymmetricMigration(migration_data, deme2, deme1, deme_intervals)
                    push!(graph.migrations, mig)
                end
            else
                throw(MigrationError("migration demes must be an array"))
            end
        elseif (
            "dest" ∈ keys(default_data["migration"]) &&
            "source" ∈ keys(default_data["migration"])
        )
            # add for given default dest and source
            source = default_data["migration"]["source"]
            dest = default_data["migration"]["dest"]
            mig = getAsymmetricMigration(migration_data, source, dest, deme_intervals)
            push!(graph.migrations, mig)
        else
            throw(MigrationError("either demes or source and dest must be given"))
        end
    else
        throw(MigrationError("either demes or source and dest must be given"))
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
