using JLD
using Plots
using NuSynthesis
using CSV
using DataFrames
ld = load("2022-08-19T00:23:09.835.jld")
data = ld["data"]
dstatistics = ld["dstatistics"]
Plots.scalefontsizes(2)
##
maxN = 8
Nas = 2 .^(1:maxN)
θs = Vector(0.2:0.1:.9)
tolerance = 1e-3
p = plot(yaxis = "N", legend = :bottomright, color_palette = palette(:Blues_9), size = (600, 400),
    xaxis = :log)

plot!(p, yaxis = :log)

for θ ∈ θs[1:end-2]
    plot!(p, Nas, (Na) -> first_until_tol(Na, θ, tolerance, dstatistics), 
    label = false, xaxis = "Na", linewidth = 2, marker = :x, markersize = 5)
end
savefig(p, "fix_tol_e-3.png")

Na = 2^7
p = plot(yaxis = "N", xaxis = "tolerance", color_palette = palette(:Blues_9), size = (600, 400))
plot!(p, xaxis = :log, yaxis = :log, xflip = true, legend = :topleft)

for θ ∈ θs[1:end-2]
    plot!(p, 10 .^(1 .- (0:0.01:4)), (tolerance) -> first_until_tol(Na, θ, tolerance, dstatistics), 
    label = false,  linewidth = 2)
end
p
savefig(p, "fix_Na_128.png")

## Save the data for Tikz for fix tol
v(θ) = [first_until_tol(Na, θ, tolerance, dstatistics) for Na ∈ Nas]
datamatrix = hcat(v.(θs)...)
df = DataFrame([Nas datamatrix], :auto)
CSV.write("fix_tol_e.csv", df)

## Save the data for Tikz, fixed Na

Na = 2^maxN
tolerances = 10 .^(0 .- (0:0.01:4))
w(θ) = [first_until_tol(Na, θ, tolerance, dstatistics) for tolerance in tolerances]
datamatrix = hcat(w.(θs)...)
df = DataFrame([tolerances datamatrix], :auto)
CSV.write("fix_Na.csv", df)
