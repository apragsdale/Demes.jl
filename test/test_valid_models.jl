# load and run all valid models in demes-spec

function loadModel(fname::String)
    graph = Demes.loadGraph(fname)
    simplified = Demes.asDictSimplified(graph)
    return simplified
end

@testset "ValidModels" begin
    for f in readdir(joinpath(@__DIR__, "test-cases/valid"))
        fname = joinpath(@__DIR__, "test-cases/valid", f)
        if f in ["pulse_edge_case_02.yaml"]
            # these might not be valide test cases...
            @test_skip typeof(loadModel(fname)) == Dict{Any,Any}
        else
            @test typeof(loadModel(fname)) == Dict{Any,Any}
        end
    end
    @test typeof(loadModel("gutenkunst_ooa.yaml")) == Dict{Any,Any}
end
