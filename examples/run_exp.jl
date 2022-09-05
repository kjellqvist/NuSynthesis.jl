using NuSynthesis
using JLD
using Dates
using GLPK

maxN = 8
Niter = 10000
Nexps = 500
θs = Vector(0.2:0.1:.9)

data, dstatistics = gen_data(maxN, Niter, Nexps, θs, GLPK.Optimizer)
save(string(now())*".jld", "data", data, "dstatistics", dstatistics)
