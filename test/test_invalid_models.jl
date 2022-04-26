# load and run all valid models in demes-spec

function loadModel(fname::String)
    println(fname)
    graph = Demes.loadGraph(fname)
    simplified = Demes.asDictSimplified(graph)
    return simplified
end

@testset "InvalidModels" begin
    for f in readdir(joinpath(@__DIR__, "../demes-spec/test-cases/invalid"))
        fname = joinpath(@__DIR__, "../demes-spec/test-cases/invalid", f)
        if occursin("bad_ancestors", f)
            @test_throws Demes.DemeError loadModel(fname)
        elseif occursin("bad_ancestry", f)
            @test_throws Demes.DemeError loadModel(fname)
        end
    end
end
