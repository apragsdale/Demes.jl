function compareToResolved(model_name::String)
    yaml = model_name * ".yaml"
    json = model_name * ".resolved.json"
    graph1 = Demes.loadGraph(yaml)
    io = open(json)
    str = read(io, String)
    close(io)
    json_dict = JSON.parse(str)
    graph2 = Demes.buildGraph(json_dict)
    is_equal = Demes.isGraphEqual(graph1, graph2)
    if is_equal == false
        println("Mismatch in " * split(model_name, "/")[end])
    end
    return is_equal
end

@testset "Resolved" begin
    for f in readdir(joinpath(@__DIR__, "../demes-spec/examples"))
        if occursin("yaml", f)
            if occursin("offshootsxxxxx", f)
                # descriptions mismatch due to \n characters
                @test_skip compareToResolved(path_name) == true
            else
                model_name = split(f, ".yaml")[1]
                path_name = joinpath(@__DIR__, "../demes-spec/examples", model_name)
                @test compareToResolved(path_name) == true
            end
        end
    end
end
