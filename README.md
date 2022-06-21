# Demes.jl

A Julia package for working with [demes](https://popsim-consortium.github.io/demes-docs/latest/introduction.html) demographic models.

## Usage

Demographic models written in the demes standard can be loaded as

```julia
using Demes
graph = Demes.loadGraph("test/gutenkunst_ooa.yaml")
```

## Development and installation

Testing takes advantage of valid and invalid Demes models provided in
[demes-spec](https://github.com/popsim-consortium/demes-spec.git).

After cloning, you will need to

```sh
git submodule init
git submodule update
```
