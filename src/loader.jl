# Load a demographic model from a YAML file or from a 

using YAML

include("builder.jl") # builds a Graph struct from a dict

function loadsGraph(str::String)
    # Load graph from a YAML-formatted string.
    # Returns a dictionary.
    data = YAML.load(str)
    return data
end

function loadGraph(fname)
    # Load graph from a YAML file.
    # Returns 
    io = open(fname, "r")
    str = read(io, String)
    close(io)
    data = loadsGraph(str)
    graph = buildGraph(data)
    return graph
end
