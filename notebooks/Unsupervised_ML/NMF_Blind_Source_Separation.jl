import NMF
import Cairo
import Fontconfig
import Mads
import NMFk
import Random

Random.seed!(2020)

a = rand(15)
b = rand(15)
c = rand(15)

[a b c]

Mads.plotseries([a b c])

W = [a b c]

H = [1 10 0 0 1; 0 1 1 5 2; 3 0 0 1 5]

X = W * H

Mads.plotseries(X; name="Sensors")

k = 3
nmfresults = NMF.nnmf(X, k; alg=:multmse, maxiter=1000, tol=1.0e-4)
We = nmfresults.W
He = nmfresults.H
println("NMF iterations:", nmfresults.niters)
println("NMF convergence: ", nmfresults.converged)
println("NMF objective function: ", nmfresults.objvalue)

We

He

Mads.plotseries(W; title="Original signals")

Mads.plotseries(We ./ maximum(We; dims=1); title="Reconstructed signals")

NMFk.plotmatrix(H ./ maximum(H; dims=2); title="Original mixing matrix")

NMFk.plotmatrix(He ./ maximum(He; dims=2); title="Reconstructed mixing matrix")
