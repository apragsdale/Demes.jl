# Load file/string as a dictionary, then fill 

using YAML
include("validate.jl")
include("simplify.jl")

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

function writesGraph(data::Dict)
    str = YAML.write(data)
    return str
end

function writeGraph(data::Dict, fname::String, overwrite=true)
    if isfile(fname) && overwrite == false
        error("filename ", fname, " exists, but overwrite is set to false")
    end
    simplified = simplifyGraph(data)
    validateGraph(simplified)
    str = writesGraph(simplified)
    io = open(fname, "w+")
    write(io, str)
    close(io)
end

f = "gutenkunst_ooa.yml"
data = loadGraph(f)
writeGraph(data, "gutenkunst_out.yml")

include("resolve.jl")
filled = fillGraph(data)
simplified = simplifyGraph(filled)

println("data == simplified: ", data == simplified)
