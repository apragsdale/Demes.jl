# Load a demographic model from a YAML file or from a 
function loadsGraph(str::String)
    # Load graph from a YAML-formatted string.
    # Returns a dictionary.
    try
        data = YAML.load(str)
        if length(data) == 0
            throw(DemesError("input data is empty"))
        elseif (typeof(data) <: Dict) == false
            throw(DemesError("input data is invalid"))
        end
        return data
    catch e
        if isa(e, MethodError)
            throw(DemesError("input data is invalid"))
        elseif isa(e, DemesError)
            throw(e)
        else
            throw(DemesError("unexpected input, YAML could not be read"))
        end
    end
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
