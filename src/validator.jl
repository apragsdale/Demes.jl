function validateGraphTopLevel(data::Dict)
    for k in keys(data)
        if k ∉ [
            "description",
            "time_units",
            "generation_time",
            "doi",
            "demes",
            "pulses",
            "migrations",
            "defaults",
            "metadata",
        ]
            throw(DemesError("unexpected field in graph data"))
        end
    end
    if "description" in keys(data) && isa(data["description"], String) == false
        throw(DemesError("graph description must be a string"))
    end
    if "doi" in keys(data)
        if (typeof(data["doi"]) <: Vector) == false
            throw(DemesError("graph doi must be an array"))
        end
        for doi in data["doi"]
            if isa(doi, String) == false
                throw(DemesError("graph doi must be an array of strings"))
            end
        end
    end
    if "time_units" ∉ keys(data)
        throw(DemesError("input graph must provide time units"))
    elseif data["time_units"] ∉ ["generations", "years"]
        throw(DemesError("graph time units must be generations or years"))
    else
        if data["time_units"] != "generations" && "generation_time" ∉ keys(data)
            throw(DemesError("generation_time required when time units is not years"))
        end
    end
    if "generation_time" ∈ keys(data)
        if isa(data["generation_time"], Number) == false
            throw(DemesError("generation time must be a number"))
        elseif data["generation_time"] <= 0 || data["generation_time"] == Inf
            throw(DemesError("generation time must be a finite positive number"))
        elseif data["time_units"] == "generations" && data["generation_time"] != 1
            throw(DemesError("generation time must be 1 when time units are generations"))
        end
    end
    if "metadata" ∈ keys(data)
        if isa(data["metadata"], Dict) == false
            throw(DemesError("graph metadata must be a dict"))
        end
    end
end

function validateGraphDefaults(data::Dict)
    if "defaults" ∈ keys(data)
        if isa(data["defaults"], Dict) == false
            throw(DemesError("graph defaults must be a dict"))
        end
        for k in keys(data["defaults"])
            if k ∉ ["pulse", "migration", "deme", "epoch"]
                throw(DemesError("unexpected field in graph defaults"))
            end
        end
        if "pulse" in keys(data["defaults"])
            if isa(data["defaults"]["pulse"], Dict) == false
                throw(DemesError("pulse defaults must be a dict"))
            end
            for k in keys(data["defaults"]["pulse"])
                if k ∉ ["time", "proportions", "sources", "dest"]
                    throw(DemesError("unexpected field in graph pulse defaults"))
                end
            end
            if "time" in keys(data["defaults"]["pulse"])
                if isa(data["defaults"]["pulse"]["time"], Number) == false
                    throw(DemesError("pulse default time must be a number"))
                elseif data["defaults"]["pulse"]["time"] < 0 ||
                       data["defaults"]["pulse"]["time"] == Inf
                    throw(
                        DemesError(
                            "pulse default time must be between positive and finite",
                        ),
                    )
                end
            end
            if "dest" in keys(data["defaults"]["pulse"])
                if isa(data["defaults"]["pulse"]["dest"], String) == false
                    throw(DemesError("pulse default dest must be a deme name string"))
                end
            end
            if "sources" in keys(data["defaults"]["pulse"])
                if isa(data["defaults"]["pulse"]["sources"], Vector) == false
                    throw(DemesError("pulse default sources must be an array"))
                elseif length(data["defaults"]["pulse"]["sources"]) == 0
                    throw(DemesError("pulse default sources must contain one deme"))
                else
                    for s in data["defaults"]["pulse"]["sources"]
                        if isa(s, String) == false
                            throw(
                                DemesError(
                                    "pulse default source must be a deme name string",
                                ),
                            )
                        end
                    end
                end
            end
            if "proportions" in keys(data["defaults"]["pulse"])
                if isa(data["defaults"]["pulse"]["proportions"], Vector) == false
                    throw(DemesError("pulse default proportions must be an array"))
                elseif length(data["defaults"]["pulse"]["proportions"]) == 0
                    throw(DemesError("pulse default proportions must contain one deme"))
                else
                    for p in data["defaults"]["pulse"]["proportions"]
                        if isa(p, Number) == false
                            throw(DemesError("pulse default proportion must be a number"))
                        elseif p < 0 || p > 1
                            throw(
                                DemesError(
                                    "pulse default proportion must be between 0 and 1",
                                ),
                            )
                        end
                    end
                    if sum(data["defaults"]["pulse"]["proportions"]) > 1
                        throw(DemesError("pulse default proportions must sum to 1 or less"))
                    end
                end
            end
        end
        if "migration" in keys(data["defaults"])
            if isa(data["defaults"]["migration"], Dict) == false
                throw(DemesError("migration defaults must be a dict"))
            end
            for k in keys(data["defaults"]["migration"])
                if k ∉ ["start_time", "end_time", "rate", "source", "dest", "demes"]
                    throw(DemesError("unexpected field in graph migration defaults"))
                end
            end
            if "end_time" in keys(data["defaults"]["migration"])
                if isa(data["defaults"]["migration"]["end_time"], Number) == false
                    throw(DemesError("default migration end time must be a number"))
                elseif data["defaults"]["migration"]["end_time"] < 0
                    throw(DemesError("default migration end time must be nonnegative"))
                elseif data["defaults"]["migration"]["end_time"] == Inf
                    throw(DemesError("default migration end time must be finite"))
                end
            end
            if "start_time" in keys(data["defaults"]["migration"])
                if isa(data["defaults"]["migration"]["start_time"], Number) == false &&
                   data["defaults"]["migration"]["start_time"] != "Infinity"
                    throw(DemesError("default migration start time must be a number"))
                elseif isa(data["defaults"]["migration"]["start_time"], Number) &&
                       data["defaults"]["migration"]["start_time"] <= 0
                    throw(DemesError("default migration end time must be nonnegative"))
                end
            end
            if "rate" in keys(data["defaults"]["migration"])
                if isa(data["defaults"]["migration"]["rate"], Number) == false
                    throw(DemesError("default migration rate must be a number"))
                elseif data["defaults"]["migration"]["rate"] < 0 ||
                       data["defaults"]["migration"]["rate"] > 1
                    throw(DemesError("default migration rate must be between 0 and 1"))
                end
            end
            if "source" in keys(data["defaults"]["migration"])
                if isa(data["defaults"]["migration"]["source"], String) == false
                    throw(DemesError("default migration source must be a deme name string"))
                end
            end
            if "dest" in keys(data["defaults"]["migration"])
                if isa(data["defaults"]["migration"]["dest"], String) == false
                    throw(DemesError("default migration dest must be a deme name string"))
                end
            end
            if "demes" in keys(data["defaults"]["migration"])
                if isa(data["defaults"]["migration"]["demes"], Vector) == false
                    throw(DemesError("default migration demes must be an array"))
                end
                for d in data["defaults"]["migration"]["demes"]
                    if isa(d, String) == false
                        throw(
                            DemesError("default migration demes must be deme name strings"),
                        )
                    end
                end
            end
        end
        if "deme" in keys(data["defaults"])
            if isa(data["defaults"]["deme"], Dict) == false
                throw(DemesError("deme defaults must be a dict"))
            end
            for k in keys(data["defaults"]["deme"])
                if k ∉ ["description", "start_time", "ancestors", "proportions"]
                    throw(DemesError("unexpected field in graph deme defaults"))
                end
            end
            if "description" in keys(data["defaults"]["deme"]) &&
               isa(data["defaults"]["deme"]["description"], String) == false
                throw(DemesError("default deme description must be a string"))
            end
        end
        if "epoch" in keys(data["defaults"])
            if isa(data["defaults"]["epoch"], Dict) == false
                throw(DemesError("epoch defaults must be a dict"))
            end
            for k in keys(data["defaults"]["epoch"])
                if k ∉ [
                    "start_time",
                    "end_time",
                    "start_size",
                    "end_size",
                    "size_function",
                    "cloning_rate",
                    "selfing_rate",
                ]
                    throw(DemesError("unexpected field in graph epoch defaults"))
                end
            end
        end

    end
end

function validateGraphDemes(data::Dict)
    if "demes" ∉ keys(data)
        throw(DemesError("input graph must specify demes"))
    elseif (typeof(data["demes"]) <: Vector) == false
        throw(DemesError("input demes must be an array of dicts"))
    elseif length(data["demes"]) == 0
        throw(DemesError("input graph must have at least one deme"))
    else
        for d in data["demes"]
            if isa(d, Dict) == false
                throw(DemesError("input demes must be an array of dicts"))
            end
            if "epochs" ∈ keys(d) && isnothing(d["epochs"])
                throw(DemesError("deme epochs cannot be null"))
            end
        end
    end
end

function validateGraphMigrations(data::Dict)
    if isa(data["migrations"], Vector) == false
        throw(DemesError("migrations must be an array"))
    end
    for migration_data ∈ data["migrations"]
        if isa(migration_data, Dict) == false
            throw(DemesError("migration data must be a dict"))
        end
    end
end

function validateGraphPulses(data::Dict)
    if isa(data["pulses"], Vector) == false
        throw(DemesError("migrations must be an array"))
    end
    for pulse_data in data["pulses"]
        if isa(pulse_data, Dict) == false
            throw(DemesError("pulse data must be a dict"))
        end
    end
end

function validateDemeNameDescription(deme_data::Dict, deme_intervals::Dict)
    if "name" ∉ keys(deme_data)
        throw(DemesError("no deme name given"))
    end
    if isa(deme_data["name"], String) == false
        throw(DemesError("deme name must be a string"))
    elseif length(deme_data["name"]) == 0
        throw(DemesError("deme name must not be an empty string"))
    else
        # TODO: check for valid deme names
        #name = deme_data["name"]
        #if (isuppercase(name[1]) || islowercase(name[1]) || name[1] == "_") == false
        #    throw(DemesError("invalid deme name"))
        #end
        #for char in name
        #    if (
        #        isuppercase(char) ||
        #        islowercase(char) ||
        #        isdigit(char) ||
        #        isequal(char, "_")
        #    ) == false
        #        throw(DemesError("invalid deme name"))
        #    end
        #end
    end
    if deme_data["name"] ∈ keys(deme_intervals)
        throw(DemesError("deme name must be unique"))
    end
    if "description" ∈ keys(deme_data)
        if isa(deme_data["description"], String) == false
            throw(DemesError("deme description must be a string"))
        end
    end
end

function validateDemeStartTime(deme_data::Dict, deme_intervals::Dict)
    # convert string Infinity to Inf
    start_time = deme_data["start_time"]
    if start_time == "Infinity"
        start_time = Inf
    end
    if isa(start_time, Number) == false
        throw(DemesError("start time must be a number"))
    end
    # check for valid start time
    if start_time <= 0
        throw(DemesError("start time must be positive"))
    end
    if start_time < Inf
        if "ancestors" ∉ keys(deme_data) || length(deme_data["ancestors"]) == 0
            throw(DemesError("ancestors required for deme with finite start time"))
        end
    end
    # check start time is valid with respect to ancestors
    if "ancestors" ∈ keys(deme_data)
        for ancestor ∈ deme_data["ancestors"]
            if start_time < deme_intervals[ancestor][2] ||
               start_time >= deme_intervals[ancestor][1]
                throw(DemesError("start time must be in ancestor existence times"))
            end
        end
    end
    return start_time
end

function validateDemeAncestors(deme_data::Dict, deme_intervals::Dict)
    if (typeof(deme_data["ancestors"]) <: Vector) == false
        throw(DemesError("deme ancestors must be an array"))
    end
    if length(deme_data["ancestors"]) > 0 &&
       typeof(deme_data["ancestors"]) != Vector{String}
        throw(DemesError("deme ancestors must be an array of deme name strings"))
    end
    if length(Set(deme_data["ancestors"])) != length(deme_data["ancestors"])
        throw(DemesError("cannot repeat deme ancestors"))
    end
    if deme_data["name"] ∈ deme_data["ancestors"]
        throw(DemesError("ancestors cannot contain deme name"))
    end
    for anc ∈ deme_data["ancestors"]
        if anc ∉ keys(deme_intervals)
            throw(DemesError("all ancestors must already exist in the graph"))
        end
    end
end

function validateDemeProportions(deme_data::Dict)
    if (typeof(deme_data["proportions"]) <: Vector) == false
        throw(DemesError("deme proportions must be an array"))
    end
    if length(deme_data["proportions"]) > 0 &&
       all(isa.(deme_data["proportions"], Number)) == false
        throw(DemesError("deme proportions must be an array of numbers"))
    end
    if length(deme_data["ancestors"]) != length(deme_data["proportions"])
        throw(DemesError("ancestors and proportions must have equal length"))
    elseif length(deme_data["ancestors"]) > 0
        if sum(deme_data["proportions"]) != 1
            throw(DemesError("ancestor proportions must sum to 1"))
        elseif any(<(0), deme_data["proportions"])
            throw(DemesError("ancestor proportions cannot be negative"))
        end
    end
end

function validateMigrationData(migration_data::Dict)
    for k in keys(migration_data)
        if k ∉ ["rate", "source", "dest", "demes", "start_time", "end_time"]
            throw(DemesError("migration data has invalid field"))
        end
    end
    if "rate" ∉ keys(migration_data)
        throw(DemesError("migration rate must be provided"))
    elseif isa(migration_data["rate"], Number) == false
        throw(DemesError("migration rate must be a number"))
    elseif migration_data["rate"] < 0 || migration_data["rate"] > 1
        throw(DemesError("migration rate must be between 0 and 1"))
    end
    if "demes" ∈ keys(migration_data)
        # add for symmetric migrations, given demes in the migration dict
        if "source" ∈ keys(migration_data) || "dest" ∈ keys(migration_data)
            throw(DemesError("migration can have demes or source and dest but not both"))
        end
        if (typeof(migration_data["demes"]) <: Vector) == false
            throw(DemesError("migration demes must be a vector"))
        elseif length(migration_data["demes"]) < 2
            throw(DemesError("migration demes must contain at least two deme names"))
        end
        if length(Set(migration_data["demes"])) != length(migration_data["demes"])
            throw(DemesError("migration demes cannot be repeated"))
        end
        for d in migration_data["demes"]
            if isa(d, String) == false
                throw(DemesError("migration deme names just be strings"))
            end
        end
    elseif "source" ∉ keys(migration_data) || "dest" ∉ keys(migration_data)
        throw(DemesError("migration must provide demes or source and dest"))
    elseif migration_data["source"] == migration_data["dest"]
        throw(DemesError("migration source and dest must be unique"))
    elseif isa(migration_data["source"], String) == false
        throw(DemesError("migration source must be a deme name string"))
    elseif isa(migration_data["dest"], String) == false
        throw(DemesError("migration dest must be a deme name string"))
    end
end

function validateMigrationStartTime(
    migration_data::Dict,
    source::String,
    dest::String,
    deme_intervals::Dict,
)
    if source ∉ keys(deme_intervals) || dest ∉ keys(deme_intervals)
        throw(DemesError("source and dest must be present in graph"))
    end
    if "start_time" ∈ keys(migration_data)
        start_time = migration_data["start_time"]
        if start_time == "Infinity"
            start_time = Inf
        end
        if isa(start_time, Number) == false
            throw(DemesError("migration start time must be a number"))
        elseif start_time <= 0
            throw(DemesError("migration start time must be positive"))
        end
        if start_time > deme_intervals[source][1]
            throw(DemesError("migration start time greater than source start time"))
        elseif start_time > deme_intervals[dest][1]
            throw(DemesError("migration start time greater than dest start time"))
        end
    else
        start_time = min(deme_intervals[source][1], deme_intervals[dest][1])
    end
    return start_time
end

function validateMigrationEndTime(
    migration_data::Dict,
    source::String,
    dest::String,
    deme_intervals::Dict,
)
    if source ∉ keys(deme_intervals) || dest ∉ keys(deme_intervals)
        throw(DemesError("source and dest must be present in graph"))
    end
    if "end_time" ∈ keys(migration_data)
        end_time = migration_data["end_time"]
        if isa(end_time, Number) == false
            throw(DemesError("migration end time must be a number"))
        elseif end_time < 0
            throw(DemesError("migration end time must be positive"))
        end
        if end_time < deme_intervals[source][2]
            throw(DemesError("migration end time less than source end time"))
        elseif end_time < deme_intervals[dest][2]
            throw(DemesError("migration end time greater than dest end time"))
        end
    else
        end_time = max(deme_intervals[source][2], deme_intervals[dest][2])
    end
    return end_time
end

function validatePulseFields(pulse_data::Dict)
    # check all fields are provided
    for k in keys(pulse_data)
        if k ∉ ["time", "dest", "sources", "proportions"]
            throw(DemesError("invalid field in pulse data"))
        end
    end
    if "time" ∉ keys(pulse_data)
        throw(DemesError("pulse must have time provided"))
    end
    if "dest" ∉ keys(pulse_data)
        throw(DemesError("pulse must have dest provided"))
    end
    if "sources" ∉ keys(pulse_data)
        throw(DemesError("pulse must have sources provided"))
    elseif isa(pulse_data["sources"], AbstractArray) == false
        throw(DemesError("pulse sources must be an array"))
    end
    if "proportions" ∉ keys(pulse_data)
        throw(DemesError("pulse must have proportions"))
    elseif isa(pulse_data["proportions"], AbstractArray) == false
        throw(DemesError("pulse proportions must be an array"))
    elseif length(pulse_data["proportions"]) != length(pulse_data["sources"])
        throw(DemesError("pulse proportions and sources must have matching lengths"))
    end
end

function validatePulseDemes(pulse_data::Dict)
    # check valid sources and dests
    if isa(pulse_data["dest"], String) == false
        throw(DemesError("pulse dest must be a deme name string"))
    end
    if isa(pulse_data["sources"], Vector) == false
        throw(DemesError("pulse sources must be an array"))
    else
        for s ∈ pulse_data["sources"]
            if isa(s, String) == false
                throw(DemesError("pulse sources must be deme name strings"))
            end
        end
    end
    if pulse_data["dest"] ∈ pulse_data["sources"]
        throw(DemesError("pulses cannot have same dest and source"))
    end
    if length(pulse_data["sources"]) != length(Set(pulse_data["sources"]))
        throw(DemesError("pulse has repeated sources"))
    end
end

function validatePulseTiming(pulse_data::Dict, deme_intervals::Dict)
    # check timing of pulse
    if isa(pulse_data["time"], Number) == false
        throw(DemesError("pulse time must be a number"))
    end
    if pulse_data["dest"] ∉ keys(deme_intervals)
        throw(DemesError("pulse dest not present in graph"))
    end
    for s in pulse_data["sources"]
        if s ∉ keys(deme_intervals)
            throw(DemesError("pulse source not present in graph"))
        end
    end
    if pulse_data["time"] >= deme_intervals[pulse_data["dest"]][1]
        throw(DemesError("pulse time greater than destination existence interval"))
    elseif pulse_data["time"] < deme_intervals[pulse_data["dest"]][2]
        throw(DemesError("pulse time less than destination existence interval"))
    end
    for source ∈ pulse_data["sources"]
        if pulse_data["time"] >= deme_intervals[source][1]
            throw(DemesError("pulse time greater than source existence interval"))
        elseif pulse_data["time"] < deme_intervals[source][2]
            throw(DemesError("pulse time less than source existence interval"))
        end
    end
end

function validatePulseProportions(pulse_data::Dict)
    # check proportions are <= 1
    if isa(pulse_data["proportions"], Vector) == false
        throw(DemesError("pulse proportions must be an array"))
    end
    for prop ∈ pulse_data["proportions"]
        if isa(prop, Number) == false
            throw(DemesError("pulse proportions must be numbers"))
        elseif prop < 0 || prop > 1
            throw(DemesError("pulse proportions must be between 0 and 1"))
        end
    end
    if sum(pulse_data["proportions"]) > 1
        throw(DemesError("pulse proportions must sum to 1 or less"))
    end
end

function validateDemeDefaultsFields(default_data)
    if isa(default_data, Dict) == false
        throw(DemesError("deme defaults must be a dict with default epoch data"))
    else
        for k in keys(default_data)
            if k ∉ ["epoch"]
                throw(DemesError("deme defaults can only contain epoch data"))
            end
        end
    end
end

function validateEpochData(epoch_data)
    if isa(epoch_data, Dict) == false
        throw(DemesError("epoch data must be a dictionary"))
    end
    validateEpochFields(epoch_data)
    validateEpochCloningRate(epoch_data)
    validateEpochSelfingRate(epoch_data)
    validateEpochSizesTimes(epoch_data)
end

function validateEpochFields(epoch_data::Dict)
    for k ∈ keys(epoch_data)
        if k ∉ [
            "start_time",
            "end_time",
            "start_size",
            "end_size",
            "size_function",
            "cloning_rate",
            "selfing_rate",
        ]
            throw(DemesError("unexpected field in epoch data"))
        end
    end
end

function validateEpochCloningRate(epoch_data::Dict)
    if "cloning_rate" ∈ keys(epoch_data)
        c = epoch_data["cloning_rate"]
        if (typeof(c) <: Number) == false
            throw(DemesError("cloning rate must be a number"))
        elseif c < 0 || c > 1
            throw(DemesError("cloning rate must be between 0 and 1"))
        end
    end
end

function validateEpochSelfingRate(epoch_data::Dict)
    if "selfing_rate" ∈ keys(epoch_data)
        s = epoch_data["selfing_rate"]
        if (typeof(s) <: Number) == false
            throw(DemesError("epoch selfing rate must be a number"))
        elseif s < 0 || s > 1
            throw(DemesError("epoch selfing rate must be between 0 and 1"))
        end
    end
end

function validateEpochSizesTimes(epoch_data::Dict)
    if "end_time" ∈ keys(epoch_data)
        if (typeof(epoch_data["end_time"]) <: Number) == false
            throw(DemesError("epoch end time must be a number"))
        elseif epoch_data["end_time"] < 0
            throw(DemesError("epoch end time must be nonnegative"))
        elseif epoch_data["end_time"] == Inf
            throw(DemesError("epoch end time must be finite"))
        end
    end
    if "start_time" ∈ keys(epoch_data)
        if (typeof(epoch_data["start_time"]) <: Number) == false
            throw(DemesError("epoch start time must be a number"))
        elseif epoch_data["start_time"] <= 0
            throw(DemesError("epoch start time must be positive"))
        end
        if "end_time" ∈ keys(epoch_data)
            if epoch_data["end_time"] >= epoch_data["start_time"]
                throw(DemesError("epoch end time must be less than epoch start time"))
            end
        end
    end
    if "end_size" ∈ keys(epoch_data)
        if (typeof(epoch_data["end_size"]) <: Number) == false
            throw(DemesError("epoch end size must be a number"))
        elseif epoch_data["end_size"] <= 0
            throw(DemesError("epoch end size must be positive"))
        elseif epoch_data["end_size"] == Inf
            throw(DemesError("epoch end size must be finite"))
        end
    end
    if "start_size" ∈ keys(epoch_data)
        if (typeof(epoch_data["start_size"]) <: Number) == false
            throw(DemesError("epoch start size must be a number"))
        elseif epoch_data["start_size"] <= 0
            throw(DemesError("epoch start size must be positive"))
        elseif epoch_data["start_size"] == Inf
            throw(DemesError("epoch start size must be finite"))
        end
    end
    if "size_function" ∈ keys(epoch_data)
        if isa(epoch_data["size_function"], String) == false
            throw(DemesError("size function must be a string"))
        elseif epoch_data["size_function"] ∉ ["constant", "exponential", "linear"]
            throw(
                DemesError("size function must be one of constant, exponential, or linear"),
            )
        elseif epoch_data["size_function"] == "constant"
            if "start_size" ∈ keys(epoch_data) &&
               "end_size" ∈ keys(epoch_data) &&
               epoch_data["end_size"] != epoch_data["start_size"]
                throw(
                    DemesError(
                        "constant epoch size function requires equal start and end sizes",
                    ),
                )
            end
        end
    end
end

function validateResolvedDeme(deme::Deme)
    # check start times align
    if deme.start_time != deme.epochs[1].start_time
        throw(DemesError("start times mismatch"))
    end
    # valid epochs
    start_time = deme.start_time
    for e in deme.epochs
        if e.start_time == Inf && e.size_function != "constant"
            throw(DemesError("epoch with Inf start time must have constant size function"))
        end
        if e.end_time >= e.start_time
            throw(DemesError("epoch start time must be greater than epoch end time"))
        end
    end
end

function validateResolvedGraph(graph::Graph)
    # check that migrations do not overlap
    # check migration sums into demes at all times is <= 1
end
