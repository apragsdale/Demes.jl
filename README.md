# Demes.jl

A Julia package for working with [demes](https://popsim-consortium.github.io/demes-docs/latest/introduction.html) demographic models.

## Usage

Demographic models written in the demes standard can be loaded as

```julia
using Demes
graph = Demes.loadGraph("test/gutenkunst_ooa.yaml")
```

This imports a demes-specified demographic model, which is used in
downstream population genetics simulation software.
