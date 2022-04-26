function validateDemeNameDescription(deme_data::Dict, deme_intervals::Dict)
    if "name" ∉ keys(deme_data)
        throw(DemeError("", "no deme name given"))
    end
    if deme_data["name"] ∈ keys(deme_intervals)
        throw(DemeError(deme_data["name"], "deme name must be unique"))
    end
end

function validateDemeStartTime(deme_data::Dict, deme_intervals::Dict)
    start_time = deme_data["start_time"]
    if start_time == "Infinity"
        start_time = Inf
    end
    # check for valid start time
    if start_time <= 0
        throw(DemeError(deme_data["name"], "start time must be positive"))
    end
    # check start time is valid with respect to ancestors
    if "ancestors" ∈ keys(deme_data)
        for ancestor ∈ deme_data["ancestors"]
            if start_time < deme_intervals[ancestor][2] ||
               start_time >= deme_intervals[ancestor][1]
                throw(
                    DemeError(
                        deme_data["name"],
                        "start time must be in ancestor existence times",
                    ),
                )
            end
        end
    end
    return start_time
end

function validateDemeAncestorsProportions(
    ancestors::Vector,
    proportions::Vector,
    name::String,
)
    if length(ancestors) != length(proportions)
        throw(DemeError(name, "ancestors and proportions must have equal length"))
    elseif length(ancestors) > 0 && sum(proportions) != 1
        throw(DemeError(name, "ancestor proportions must sum to 1"))
    end
end

function validateMigrationStartTime(
    migration_data::Dict,
    source::String,
    dest::String,
    deme_intervals::Dict,
)
    if source ∉ keys(deme_intervals) || dest ∉ keys(deme_intervals)
        throw(MigrationError("source and dest must be present in graph"))
    end
    if "start_time" ∈ keys(migration_data)
        start_time = migration_data["start_time"]
        if start_time == "Infinity"
            start_time = Inf
        end
        if start_time > deme_intervals[source][1]
            throw(MigrationError("migration start time greater than source start time"))
        elseif start_time > deme_intervals[dest][1]
            throw(MigrationError("migration start time greater than dest start time"))
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
        throw(MigrationError("source and dest must be present in graph"))
    end
    if "end_time" ∈ keys(migration_data)
        end_time = migration_data["end_time"]
        if end_time < deme_intervals[source][2]
            throw(MigrationError("migration end time less than source end time"))
        elseif end_time < deme_intervals[dest][2]
            throw(MigrationError("migration end time greater than dest end time"))
        end
    else
        end_time = max(deme_intervals[source][2], deme_intervals[dest][2])
    end
    return end_time
end

function validatePulseFields(pulse_data::Dict)
    # check all fields are provided
    if "time" ∉ keys(pulse_data)
        throw(PulseError("pulse must have time provided"))
    end
    if "dest" ∉ keys(pulse_data)
        throw(PulseError("pulse must have dest provided"))
    end
    if "sources" ∉ keys(pulse_data)
        throw(PulseError("pulse must have sources provided"))
    elseif isa(pulse_data["sources"], AbstractArray) == false
        throw(PulseError("pulse sources must be an array"))
    end
    if "proportions" ∉ keys(pulse_data)
        throw(PulseError("pulse must have proportions"))
    elseif isa(pulse_data["proportions"], AbstractArray) == false
        throw(PulseError("pulse proportions must be an array"))
    elseif length(pulse_data["proportions"]) != length(pulse_data["sources"])
        throw(PulseError("pulse proportions and sources must have matching lengths"))
    end
end

function validatePulseDemes(pulse_data::Dict)
    # check valid sources and dests
    if pulse_data["dest"] ∈ pulse_data["sources"]
        throw(PulseError("pulses cannot have same dest and source"))
    end
    if length(pulse_data["sources"]) != length(Set(pulse_data["sources"]))
        throw(PulseError("pulse has repeated sources"))
    end
end

function validatePulseTiming(pulse_data::Dict, deme_intervals::Dict)
    # check timing of pulse
    if pulse_data["time"] >= deme_intervals[pulse_data["dest"]][1]
        throw(PulseError("pulse time greater than destination existence interval"))
    elseif pulse_data["time"] < deme_intervals[pulse_data["dest"]][2]
        throw(PulseError("pulse time less than destination existence interval"))
    end
    for source ∈ pulse_data["sources"]
        if pulse_data["time"] >= deme_intervals[source][1]
            throw(PulseError("pulse time greater than source existence interval"))
        elseif pulse_data["time"] < deme_intervals[source][2]
            throw(PulseError("pulse time less than source existence interval"))
        end
    end
end

function validatePulseProportions(pulse_data::Dict)
    # check proportions are <= 1
    for prop ∈ pulse_data["proportions"]
        if prop < 0 || prop > 1
            throw(PulseError("pulse proportions must be between 0 and 1"))
        end
    end
    if sum(pulse_data["proportions"]) > 1
        throw(PulseError("pulse proportions must sum to 1 or less"))
    end
end
