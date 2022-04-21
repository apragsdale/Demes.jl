function validateDemeNameDescription(deme_data::Dict, deme_intervals::Dict)
    if "name" ∉ keys(deme_data)
        error("Deme name must be provided")
    end
    if deme_data["name"] ∈ keys(deme_intervals)
        error("Deme name must be unique")
    end
end

function validateDemeStartTime(deme_data::Dict, deme_intervals::Dict)
    # check for valid start time
    if deme_data["start_time"] <= 0
        error("Deme start time must be positive")
    end
    # check start time is valid with respect to ancestors
    if "ancestors" ∈ keys(deme_data)
        for ancestor ∈ deme_data["ancestors"]
            if deme_data["start_time"] < deme_intervals[ancestor][2]
                error("Deme start time must coincide with ancestors' existence times")
            elseif deme_data["start_time"] >= deme_intervals[ancestor][1]
                error("Deme start time must coincide with ancestors' existence times")
            end
        end
    end
end

function validateDemeAncestorsProportions(deme_data::Dict)
    if length(deme_data["ancestors"]) > 1 && "proportions" ∉ keys(deme_data)
        error("Proportions must be given for more than one ancestor")
    end
    if "proportions" ∈ keys(deme_data)
        if length(deme_data["ancestors"]) != length(deme_data["proportions"])
            error("Ancestors and proportions must be of same length")
        elseif sum(deme_data["proportions"]) != 1
            error("Proportions must sum to 1")
        end
    end
end

function validateMigrationStartTime(
        migration_data::Dict, source::String, dest::String, deme_intervals::Dict)
    if source ∉ keys(deme_intervals) || dest ∉ keys(deme_intervals)
        error("Source and dest must be present in graph")
    end
    if "start_time" ∈ keys(migration_data)
        start_time = migration_data["start_time"]
        if start_time > deme_intervals[source][1]
            error("Migration start time greater than source start time")
        elseif start_time > deme_intervals[dest][1]
            error("Migration start time greater than dest start time")
        end
    else
        start_time = min(deme_intervals[source][1], deme_intervals[dest][1])
    end
    return start_time
end

function validateMigrationEndTime(
        migration_data::Dict, source::String, dest::String, deme_intervals::Dict)
    if source ∉ keys(deme_intervals) || dest ∉ keys(deme_intervals)
        error("Source and dest must be present in graph")
    end
    if "end_time" ∈ keys(migration_data)
        end_time = migration_data["end_time"]
        if end_time < deme_intervals[source][1]
            error("Migration end time less than source start time")
        elseif end_time < deme_intervals[dest][1]
            error("Migration end time greater than dest start time")
        end
    else
        end_time = max(deme_intervals[source][2], deme_intervals[dest][2])
    end
    return end_time
end

function validatePulseFields(pulse_data::Dict)
    # check all fields are provided
    if "time" ∉ keys(pulse_data)
        error("Pulse must have time")
    end
    if "dest" ∉ keys(pulse_data)
        error("Pulse must have dest")
    end
    if "sources" ∉ keys(pulse_data)
        error("Pulse must have sources")
    elseif isa(pulse_data["sources"], AbstractArray) == false
        error("Pulse sources must be an array")
    end
    if "proportions" ∉ keys(pulse_data)
        error("Pulse must have proportions")
    elseif isa(pulse_data["proportions"], AbstractArray) == false
        error("Pulse proportions must be an array")
    elseif length(pulse_data["proportions"]) != length(pulse_data["sources"])
        error("Pulse proportions and sources must have matching lengths")
    end
end

function validatePulseDemes(pulse_data::Dict)
    # check valid sources and dests
    if pulse_data["dest"] ∈ pulse_data["sources"]
        error("Pulses cannot have same dest and source")
    end
    if length(pulse_data["sources"]) != length(Set(pulse_data["sources"]))
        error("Pulse has repeated sources")
    end
end

function validatePulseTiming(pulse_data::Dict, deme_intervals::Dict)
    # check timing of pulse
    if pulse_data["time"] >= deme_intervals[pulse_data["dest"]][1]
        error("Pulse time greater than destination existence interval")
    elseif pulse_data["time"] < deme_intervals[pulse_data["dest"]][2]
        error("Pulse time less than destination existence interval")
    end
    for source ∈ pulse_data["sources"]
        if pulse_data["time"] >= deme_intervals[source][1]
            error("Pulse time greater than source existence interval")
        elseif pulse_data["time"] < deme_intervals[source][2]
            error("Pulse time less than source existence interval")
        end
    end
end

function validatePulseProportions(pulse_data::Dict)
    # check proportions are <= 1
    for prop ∈ pulse_data["proportions"]
        if prop < 0 || prop > 1
            error("Pulse proportions must be between 0 and 1")
        end
    end
    if sum(pulse_data["proportions"]) > 1
        error("Pulse proportions must sum to 1 or less")
    end
end