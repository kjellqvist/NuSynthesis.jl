using LinearAlgebra

function nu(A::AbstractMatrix)
    if maximum(diag(A)) == maximum(A)
        return maximum(A)
    end
    w = A[2,1]
    Anormalized = A / w

    return w * det(Anormalized) / (sum(diag(Anormalized)) - 2)
end

nubar(A) = max(A[1,1], A[2,2], sqrt(A[1,2] * A[2,1]))
spectralradius(A) = maximum(eigvals(A))
A = rand(2,2)
A[2,1] = A[1,2]
nu(A)
@info "Matrix" A
@info "result" nu(A) 

N = 1000
nubar_by_nu = zeros(N)
mu_by_nu = zeros(N)
for n=1:N
    random_numbers = rand(3)
    A = [random_numbers[1] random_numbers[2]; random_numbers[2] random_numbers[3]]
    nubar_by_nu[n] = nubar(A) / nu(A)
    mu_by_nu[n] = spectralradius(A) / nu(A)
end

##
p = scatter(nubar_by_nu, mu_by_nu)
savefig(p, "scatter.png")

##
using DataFrames
using CSV
df = DataFrame(nubar_by_nu = nubar_by_nu, mu_by_nu = mu_by_nu)
CSV.write("scatter.csv", df)