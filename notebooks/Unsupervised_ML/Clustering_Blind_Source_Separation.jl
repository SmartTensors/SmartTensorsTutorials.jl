import NMFk
import Mads
import Clustering
import Statistics
import Distances
import Plots
import Random

cd(@__DIR__)

Random.seed!(2021)

a = rand(15)
b = rand(15)
c = rand(15)
[a b c]

Mads.plotseries([a b c])

W = [a b c]

H = [1 10 0 0 1; 0 1 1 5 2; 3 0 0 1 5]

X = permutedims(W * H)

Mads.plotseries(X'; name="Sensors")

result = Clustering.kmeans(X, 3); # run K-means for the 3 clusters

@assert Clustering.nclusters(result) == 3

M = result.centers # center of clusters

csize = Clustering.counts(result)

a = Clustering.assignments(result)

Plots.scatter(a, b, marker_z=result.assignments, color=:lightrainbow, legend=false)

dists = Distances.pairwise(Distances.SqEuclidean(), X)

sil_width = Statistics.mean(Clustering.silhouettes(result, dists))

cl_num    = [2, 3, 4, 5, 6, 7]
sil_width = []
for cluster in cl_num
    results          = Clustering.kmeans(X, cluster)
    silhouette_width = Statistics.mean(Clustering.silhouettes(results, dists))
    push!(sil_width, silhouette_width)
    display(silhouette_width)
end

Plots.plot(cl_num, sil_width, xlabel="No. of cluster", ylabel="Silhouette width", linewidth=2)

import DelimitedFiles
attributes   = ["BHT", "Temperature gradient", "Temperature 200m", "Temperature 4km", "Heat flow", "Gravity", "Insar", "Seismic time", "pH", "Na", "K", "Ca", "Mg", "Fe", "SiO2", "B", "Li", "HCO3", "SO4", "Cl", "Fl", "TDS"]
nearest_logv1 = [false, true, false, false, false, true, true, true, false, true, true, true, true, true, true, true, true, true, true, true, true, true]
nearest_logv2 = falses(length(attributes))
nearest_logv2[indexin(["Temperature gradient"], attributes)] .= true
nearest_logv2[indexin(["Heat flow"], attributes)] .= true
geotdata  = DelimitedFiles.readdlm("../../data/forge_geot_data_reconstructed.csv", ',')

# write your code here
