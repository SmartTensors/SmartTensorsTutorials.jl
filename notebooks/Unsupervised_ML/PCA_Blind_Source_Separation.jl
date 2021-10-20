import NMFk
import Mads
import MultivariateStats
import Random

Random.seed!(2021)

a = rand(15)
b = rand(15)
c = rand(15)
[a b c]

import Cairo
Mads.plotseries([a b c])

W = [a b c]

H = [1 10 0 0 1; 0 1 1 5 2; 3 0 0 1 5]

X = W * H

Mads.plotseries(X; name="Sensors")

M = MultivariateStats.fit(MultivariateStats.PCA, X; maxoutdim=4)

Yte = MultivariateStats.transform(M, X)

Xr = MultivariateStats.reconstruct(M, Yte)
using Statistics
rmse_x = sqrt(sum((X .- Xr).^2))  # calculates the mse between true and predicted data

rmse_y = sqrt(sum((H .- Yte).^2))

NMFk.plotmatrix(X ./ maximum(X; dims=2); title="Original data matrix")

NMFk.plotmatrix(Xr ./ maximum(Xr; dims=2); title="Reconstructed data matrix")
