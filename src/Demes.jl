__precompile__(true)

module Demes

using Combinatorics
using YAML

include("demes_structs.jl")
include("utils.jl") # functions to manipulate and get information from model
include("loader.jl") # read YAML formatted models as data
include("builder.jl") # iteratively build demographic models
include("validator.jl") # validate input data
include("writer.jl") # write models to YAML format
include("simplifier.jl") # simplify a model to non-redundant

end
