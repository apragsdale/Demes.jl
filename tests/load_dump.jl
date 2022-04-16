# Load file/string as a dictionary, then fill 

using YAML

function graphKeys()
    allowed = [
        "description",
        "doi",
        "time_units",
        "generation_time",
        "defaults",
        "demes",
        "migrations",
        "pulses"
       ]
    return allowed
end

function validateGraph(data)
    # check that only allowed keys are present in data
    allowed = graphKeys()
    for k in keys(data)
        if k ∉ allowed
            error("Graph cannot include field ", k)
        end
    end

    validateTimeUnits(data)
    validateDemes(data)
    validateDOI(data)
    validateDefaults(data)
    validateMigrations(data)
    validatePulses(data)
end

function validateTimeUnits(data)
    # time units must be present, and must be years of generations
    # generation_time must be present if time_units is in years
    if "time_units" ∉ keys(data)
        error("Graph must have time units")
    elseif data["time_units"] ∉ ["generations", "years"]
        error("Graph time units must be generations or years")
    elseif data["time_units"] == "years" && "generation_time" ∉ keys(data)
        error("Graph must specify generation time in time units is not generations")
    end
end

function validateDemes(data)
    # demes must be present, and it must be a list of at least length 1
    if "demes" ∉ keys(data)
        error("Graph must contain at least one deme")
    elseif length(data["demes"]) == 0
        error("Graph must contain at least one deme")
    else
        for d in data["demes"]
            validateDeme(d, data)
        end
    end
end

function validateMigrations(data)
    # validate migrations and pulses
    if "migrations" in keys(data)
        for m in data["migrations"]
            validateMigration(m, data)
        end
    end
end

function validatePulses(data)
    if "pulses" in keys(data)
        for p in data["pulses"]
            validatePulse(p, data)
        end
    end
end

function validateDOI(data)
    # doi must be a list of strings, if provided
    if "doi" in keys(data)
        if typeof(data["doi"]) != Vector{String}
            error("doi must by a vector of strings")
        end
    end
end

function validateDefaults(data)
    if "defaults" in keys(data)
    end
end

function validateDeme(deme, data)
    # check
    # 1. deme parameters all make sense
    # 2. ancestors exist if given, and times overlap
    # 3. proportions are valid
    # 4. epochs are all valid, sorted properly, times make sense
end

function validateMigration(migration, data)
    # check
    # 1. 
end

function validatePulse(pulse, data)
end

function loadsGraph(str::String)
    data = YAML.load(str)
    return data
end

function loadGraph(fname)
    io = open(fname, "r")
    str = read(io, String)
    close(io)
    data = loadsGraph(str)
    validateGraph(data)
    return data
end

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

function fillDeme(deme, deme_intervals, data)
    full_deme = Dict{String, Any}()
    full_deme["name"] = deme["name"]
    if "description" in keys(deme)
        full_deme["description"] = deme["description"]
    else
        full_deme["description"] = nothing
    end
    if "ancestors" in keys(deme)
        full_deme["ancestors"] = deme["ancestors"]
    else
        full_deme["ancestors"] = []
    end
    if "proportions" in keys(deme)
        full_deme["proportions"] = deme["proportions"]
    elseif "ancestors" in keys(deme)
        if length(deme["ancestors"]) == 1
            full_deme["proportions"] = [1.0]
        end
    else
        full_deme["proportions"] = []
    end
    if "start_time" in keys(deme)
        full_deme["start_time"] = deme["start_time"]
    elseif "ancestors" in keys(deme)
        if length(deme["ancestors"]) == 1
            full_deme["start_time"] = deme_intervals[deme["ancestors"][1]]
        else
            error("Too many ancestors!")
        end
    else
        full_deme["start_time"] = Inf
    end
    full_deme["epochs"] = Dict{String, Any}[]
    for epoch in deme["epochs"]
        full_epoch = Dict{String, Any}()
        # end time
        if "end_time" in keys(epoch)
            full_epoch["end_time"] = epoch["end_time"]
        else
            full_epoch["end_time"] = 0
        end
        # start size
        if "start_size" in keys(epoch)
            full_epoch["start_size"] = epoch["start_size"]
        else
            full_epoch["start_size"] = full_deme["epochs"][end]["end_time"]
        end
        # end size
        if "end_size" in keys(epoch)
            full_epoch["end_size"] = epoch["end_size"]
        else
            full_epoch["end_size"] = full_epoch["start_size"]
        end
        # size function
        if "size_function" in keys(epoch)
            full_epoch["size_function"] = epoch["size_function"]
        elseif full_epoch["start_size"] == full_epoch["end_size"]
            full_epoch["size_function"] = "constant"
        else
            full_epoch["size_function"] = "exponential"
        end
        # selfing rate
        if "selfing_rate" in keys(epoch)
            full_epoch["selfing_rate"] = epoch["selfing_rate"]
        else
            full_epoch["selfing_rate"] = 0
        end
        # cloning rate
        if "cloning_rate" in keys(epoch)
            full_epoch["cloning_rate"] = epoch["cloning_rate"]
        else
            full_epoch["cloning_rate"] = 0
        end
        push!(full_deme["epochs"], full_epoch)
    end
    return full_deme
end

function fillGraph(data::Dict)
    validateGraph(data)
    filled = Dict{String, Any}()
    # add defaults
    if "defaults" ∉ keys(data)
        filled["defaults"] = Dict{String, Any}
    else
        filled["defaults"] = data["defaults"]
    end
    # add demes
    deme_intervals = Dict{String, Array}()
    filled["demes"] = Dict{String, Any}[]
    for deme in data["demes"]
        deme_intervals[deme["name"]] = getDemeInterval(deme, data)
        full_deme = fillDeme(deme, deme_intervals, data)
        push!(filled["demes"], full_deme)
    end
    # add description
    if "description" ∉ keys(data)
        filled["description"] = nothing
    else
        filled["description"] = data["description"]
    end
    # add doi
    if "doi" ∉ keys(data)
        filled["doi"] = String[]
    else
        filled["doi"] = data["doi"]
    end
    # add generation time
    if "generation_time" ∉ keys(data)
        filled["generation_time"] = nothing
    else
        filled["generation_time"] = data["generation_time"]
    end
    # add migrations
    if "migrations" ∉ keys(data)
        filled["migrations"] = Dict{String, Any}[]
    else
        filled["migrations"] = data["migrations"]
    end
    # add pulses
    if "pulses" ∉ keys(data)
        filled["pulses"] = Dict{String, Any}[]
    else
        filled["pulses"] = data["pulses"]
    end
    # add time units
    filled["time_units"] = data["time_units"]
    return filled
end

function simplifyGraph(data::Dict)
    # Returns a simplified demographic model without redundancies or empty fields
    allowed = graphKeys()
    simplified = Dict()
    simplified["time_units"] = data["time_units"]
    if data["time_units"] != "generations"
        simplified["generation_time"] = data["generation_time"]
    end
    return simplified
end

function writesGraph(data::Dict)
    str = YAML.write(data)
    return str
end

function writeGraph(data::Dict, fname::String, overwrite=true)
    if isfile(fname) && overwrite == false
        error("filename ", fname, " exists, but overwrite is set to false")
    end
    simplified = simplifyGraph(data)
    str = writesGraph(simplified)
    io = open(fname, "w+")
    write(io, str)
    close(io)
end

f = "gutenkunst_ooa.yml"
data = loadGraph(f)
writeGraph(data, "gutenkunst_out.yml")
