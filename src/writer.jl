# Write a demographic model in simplified YAML format
function writesGraph(graph::Graph)
    data = asDictSimplified(graph)
    str = YAML.write(data)
    return str
end

function writeGraph(graph::Graph, filename::String, overwrite::Bool = true)
    if isfile(filename) && overwrite == false
        error("filename ", filename, " exists, but overwrite is set to false")
    end
    simplified = simplifyGraph(data)
    validateGraph(simplified)
    str = writesGraph(simplified)
    io = open(fname, "w+")
    write(io, str)
    close(io)
end
