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

function fillGraph(data::Dict)
    if "description" ∉ keys(data)
        data["description"] = nothing
    end
    if "doi" ∉ keys(data)
        data["doi"] = []
    end
    if "migrations" ∉ keys(data)
        data["migrations"] = []
    end
    if "pulses" ∉ keys(data)
        data["pulses"] = []
    end
    if "generation_time" ∉ keys(data)
        data["generation_time"] = nothing
    end
    if "defaults" ∉ keys(data)
        data["defaults"] = Dict()
    end
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
