using Pkg
Pkg.activate(".")
using NuSynthesis
using JLD
using Dates

maxN = 5
Niter = 100
Nexps = 2
θs = Vector(0.2:0.1:.9)

data, dstatistics = gen_data(maxN, Niter, Nexps, θs)
save(string(now())*".jld", "data", data, "dstatistics", dstatistics)
