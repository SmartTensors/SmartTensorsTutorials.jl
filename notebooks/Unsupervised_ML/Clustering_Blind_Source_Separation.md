# $k$-means clustering

$k$-means clustering finds pre-specified number of clusters based on the closeness (proximity) between data points

## $k$-means pros
- It is a simple, fast, and scaleable algorithm
- It demarcates boundaries amongst data
- Good algorithm for finding pattern in data
- Highly used in geosciences

## $k$-means cons
- Initial number of clusters has to be predetermined
- The initial assignment of cluster centers is random i.e., each time you run the algorithm, results may slightly differ
- Each data point is assigned to only one cluster
- sensitive to outliers


```julia
import NMFk
import Mads
import Clustering
import Cairo
import Fontconfig
import Statistics
import Distances
import Plots
import Random

Random.seed!(2021)
```

    [1mMads: Model Analysis & Decision Support[0m
    ====
    
    [1m[34m    ___      ____    [1m[31m        ____   [1m[32m ____         [1m[35m     ______[0m
    [1m[34m   /   \    /    \  [1m[31m        /    | [1m[32m |    \     [1m[35m       /  __  \[0m
    [1m[34m  |     \  /     |   [1m[31m      /     |  [1m[32m|     \     [1m[35m     /  /  \__\[0m
    [1m[34m  |  |\  \/  /|  | [1m[31m       /      | [1m[32m |      \   [1m[35m     |  |[0m
    [1m[34m  |  | \    / |  |  [1m[31m     /  /|   | [1m[32m |   |\  \   [1m[35m     \  \______.[0m
    [1m[34m  |  |  \__/  |  |  [1m[31m    /  / |   | [1m[32m |   | \  \  [1m[35m      \_______  \[0m
    [1m[34m  |  |        |  | [1m[31m    /  /  |   | [1m[32m |   |  \  \  [1m[35m             \  \[0m
    [1m[34m  |  |        |  |  [1m[31m  /  /===|   | [1m[32m |   |___\  \ [1m[35m   __.        |  |[0m
    [1m[34m  |  |        |  | [1m[31m  /  /    |   | [1m[32m |           \  [1m[35m \  \______/  /[0m
    [1m[34m  |__|        |__| [1m[31m /__/     |___| [1m[32m |____________\ [1m[35m  \__________/[0m
    
    [1mMADS[0m is an integrated high-performance computational framework for data- and model-based analyses.
    [1mMADS[0m can perform: Sensitivity Analysis, Parameter Estimation, Model Inversion and Calibration, Uncertainty Quantification, Model Selection and Model Averaging, Model Reduction and Surrogate Modeling, Machine Learning, Decision Analysis and Support.
    [1mNMFk: Nonnegative Matrix Factorization + k-means clustering and physics constraints[0m
    ====
    
    [1m[34m  _     _  [1m[31m _      _  [1m[32m _______   [1m[35m_[0m
    [1m[34m |  \  | | [1m[31m|  \  /  | [1m[32m|  _____| [1m[35m| |  _[0m
    [1m[34m | . \ | | [1m[31m| . \/ . | [1m[32m| |___    [1m[35m| | / /[0m
    [1m[34m | |\ \| | [1m[31m| |\  /| | [1m[32m|  ___|   [1m[35m| |/ /[0m
    [1m[34m | | \ ' | [1m[31m| | \/ | | [1m[32m| |       [1m[35m|   ([0m
    [1m[34m | |  \  | [1m[31m| |    | | [1m[32m| |       [1m[35m| |\ \[0m
    [1m[34m |_|   \_| [1m[31m|_|    |_| [1m[32m|_|       [1m[35m|_| \_\[0m
    
    NMFk performs unsupervised machine learning based on matrix decomposition coupled with various constraints.
    NMFk provides automatic identification of the optimal number of signals (features) present in two-dimensional data arrays (matrices).
    NMFk offers visualization, pre-, and post-processing capabilities.



    MersenneTwister(2021)


Let us generate 3 random signals:


```julia
a = rand(15)
b = rand(15)
c = rand(15)
[a b c]
```




    15×3 Matrix{Float64}:
     0.405796   0.705261   0.592091
     0.0657738  0.0900316  0.802722
     0.398162   0.0208244  0.782083
     0.163816   0.0835003  0.316525
     0.783094   0.634718   0.803177
     0.134115   0.0967049  0.0685768
     0.883121   0.664583   0.73253
     0.386875   0.61921    0.846265
     0.242105   0.402028   0.361288
     0.131588   0.0956702  0.390644
     0.085331   0.219395   0.344963
     0.330099   0.637804   0.094793
     0.654601   0.590012   0.45923
     0.467328   0.947572   0.271188
     0.889334   0.936274   0.567385



The singals look like this:


```julia
Mads.plotseries([a b c])
```


    
![png](Clustering_Blind_Source_Separation_files/Clustering_Blind_Source_Separation_5_0.png)
    


    

We can collect the 3 signal vectors into a signal matrix `W`:


```julia
W = [a b c]
```




    15×3 Matrix{Float64}:
     0.405796   0.705261   0.592091
     0.0657738  0.0900316  0.802722
     0.398162   0.0208244  0.782083
     0.163816   0.0835003  0.316525
     0.783094   0.634718   0.803177
     0.134115   0.0967049  0.0685768
     0.883121   0.664583   0.73253
     0.386875   0.61921    0.846265
     0.242105   0.402028   0.361288
     0.131588   0.0956702  0.390644
     0.085331   0.219395   0.344963
     0.330099   0.637804   0.094793
     0.654601   0.590012   0.45923
     0.467328   0.947572   0.271188
     0.889334   0.936274   0.567385



Now we can mix the signals in matrix `W` to produce a data matrix `X` representing data collected at 5 sensors (e.g., measurement devices or wells at different locations).

Each of the 5 sensors is observing some mixture of the signals in `W`.

The way the 3 signals are mixed at the sensors is represented by the mixing matrix `H`.

Let us define the mixing matrix `H` as:


```julia
H = [1 10 0 0 1; 0 1 1 5 2; 3 0 0 1 5]
```




    3×5 Matrix{Int64}:
     1  10  0  0  1
     0   1  1  5  2
     3   0  0  1  5



Each column of the `H` matrix defines how the 3 signals are represented in each sensors.

For example, the first sensor (column 1 above) detects only Signals 1 and 3; Signal 2 is missing because `H[2,1]` is equal to zero.

The second sensor (column 2 above) detects Signals 1 and 2; Signal 3 is missing because `H[3,2]` is equal to zero.

The entries of `H` matrix also define the proportions at which the signals are mixed.

For example, the first sensor (column 1 above) detects Signal 3 times stronger than Signal 1.

The data matrix `X` is formed by multiplying `W` and `H` matrices. `X` defines the actual data observed.


```julia
X = permutedims(W * H)
```




    5×15 Matrix{Float64}:
     2.18207   2.47394    2.74441    1.11339    …  2.03229   1.28089   2.59149
     4.76322   0.74777    4.00244    1.72166       7.13603   5.62085   9.82962
     0.705261  0.0900316  0.0208244  0.0835003     0.590012  0.947572  0.936274
     4.11839   1.25288    0.886205   0.734027      3.40929   5.00905   5.24876
     4.77677   4.25945    4.35023    1.91344       4.13078   3.71841   5.59881



The data matrix `X` looks like this:


```julia
Mads.plotseries(X'; name="Sensors")
```


    
![png](Clustering_Blind_Source_Separation_files/Clustering_Blind_Source_Separation_13_0.png)
    


    

### $k$-means analysis

$k$-means clustering allowing up to 4 clusters


```julia
result = Clustering.kmeans(X, 3); # run K-means for the 3 clusters
```

A clustering function would return an object containing both the resulting clustering (e.g. assignments of points to the clusters) and the information about the clustering algorithm (e.g. the number of iterations and whether it converged).

### check if the number of clusters are same as specified


```julia
@assert Clustering.nclusters(result) == 3
```

### view some basic features for $k$-meanus clustering


```julia
M = result.centers # center of clusters
```




    5×3 Matrix{Float64}:
     1.27948   1.9633   2.95494
     1.53577   4.99155  9.26369
     0.164555  0.58678  0.745192
     1.20356   3.44151  4.42699
     2.37016   4.15208  5.84739




```julia
size = Clustering.counts(result) # cluster size ==> number of data points for each cluster
```




    3-element Vector{Int64}:
     6
     6
     3



### get the assignments of points to clusters


```julia
a = Clustering.assignments(result)
```




    15-element Vector{Int64}:
     2
     1
     2
     1
     3
     1
     3
     2
     1
     1
     1
     2
     2
     2
     3



### plot with the point color mapped to the assigned cluster index


```julia
Plots.scatter(a, b, marker_z=result.assignments, color=:lightrainbow, legend=false)
```




    
![svg](Clustering_Blind_Source_Separation_files/Clustering_Blind_Source_Separation_25_0.svg)
    



### We ran single $k$-means clustering but we do not know if 3 is the best cluster for this data
- for validation of $k$-means clustering results there are several metrics
- one of them is the Silhouette width
- others are elbow, cross tabulation, rand index, variation of information, V-measure, mutual information
- among them the Silhouette width is most used; however, these metrics are dataset dependent


### Silhouette width measures the quality of each clustering by quantifying distance of each cluster from its neighboring clusters
- The Silhouette width for $i$ data point is a cosine norm:
    $$
    s_i = \frac{b_i - a_i}{\mathrm{max}\left(a_i, b_i\right)} 
    $$ 
where
- $a_i$ is the average distance from $i$ to the other points in the same cluster $z_i$
- $b_i$ is the average distance from the i to the points in the $k$-th cluster


### Computing the Silhouette width, we need distance matrix of features/data


```julia
dists = Distances.pairwise(Distances.SqEuclidean(), X)
```




    15×15 Matrix{Float64}:
      0.0       25.0664   11.9925    30.4324    …   6.58604   3.51974   27.8428
     25.0664     0.0      10.8135     8.57255      45.9215   40.3072   100.971
     11.9925    10.8135    0.0       13.8272       17.0646   23.017     55.4082
     30.4324     8.57255  13.8272     0.0          42.4899   37.5121   102.616
     16.4226    71.0708   33.0018    77.8877        7.19274  18.4336     4.15117
     44.4028    18.4029   26.0175     2.25732   …  55.7145   48.2617   122.544
     24.4163    87.6903   43.0732    91.3704       10.1328   23.8946     1.92483
      1.8332    24.2571   12.2357    37.0655       11.0739    9.80641   30.5188
     11.3434     8.95245   7.99698    4.92288      21.8467   15.8339    66.7993
     29.1889     5.89136  13.0966     0.282237     43.4378   37.6646   103.452
     28.5369     6.03277  15.985      1.05335   …  45.1449   36.1253   105.076
     11.1125    22.8164   15.8253    12.0009       16.4576    9.0313    54.9448
      6.58604   45.9215   17.0646    42.4899        0.0       5.71748   13.2268
      3.51974   40.3072   23.017     37.5121        5.71748   0.0       23.0249
     27.8428   100.971    55.4082   102.616        13.2268   23.0249     0.0



### find Silhouette width


```julia
sil_width = Statistics.mean(Clustering.silhouettes(result, dists))
```




    0.5881906669707156



### We did for one cluster. Now, let's perform analyses for multiple $k$ values


```julia
cl_num    = [2, 3, 4, 5, 6, 7]
sil_width = []
for cluster in cl_num
    results          = Clustering.kmeans(X, cluster)
    silhouette_width = Statistics.mean(Clustering.silhouettes(results, dists))
    push!(sil_width, silhouette_width)
    display(silhouette_width)
end
```


    0.722172126175015



    0.4409544217285092



    0.5669914967453166



    0.4660328443803485



    0.49493919065195285



    0.4323455271566419



```julia
Plots.plot(cl_num, sil_width, xlabel="No. of cluster", ylabel="Silhouette width", linewidth=2)
```




    
![svg](Clustering_Blind_Source_Separation_files/Clustering_Blind_Source_Separation_32_0.svg)
    



### Here, $k = 2$ has highest Silhouette value. However, three is the closest to two. From my experience, $k=2$ provides highest silhouette width than larger $k$ values. Potential cause is two cluster can easily demarcate the boundaries in a dataset. However, it does not mean that they represent the data accurately. So, it is better to look for $k$ value greater than `two`. Here, $k=4$ does it and also the actual data also has `four` distinct classification.

### There are more clustering tools available on Julia

### Exercise

- geodata consists of $102 \times 24$ dataset
- first two columns are for locations
- remaining 22 columns are for attributes
- run $k$-means clustering on these 22 attributes and find best clusters representing the dataset


```julia
import DelimitedFiles
attributes   = ["BHT", "Temperature gradient", "Temperature 200m", "Temperature 4km", "Heat flow", "Gravity", "Insar", "Seismic time", "pH", "Na", "K", "Ca", "Mg", "Fe", "SiO2", "B", "Li", "HCO3", "SO4", "Cl", "Fl", "TDS"]
nearest_logv1 = [false, true, false, false, false, true, true, true, false, true, true, true, true, true, true, true, true, true, true, true, true, true]
nearest_logv2 = falses(length(attributes))
nearest_logv2[indexin(["Temperature gradient"], attributes)] .= true
nearest_logv2[indexin(["Heat flow"], attributes)] .= true
geotdata  = DelimitedFiles.readdlm("../../data/forge_geot_data_reconstructed.csv", ',')
```




    102×24 Matrix{Float64}:
     38.5508  -112.776   14.1883  …  51.5245   3392.46  3.91224  6001.14
     38.5137  -112.799   12.1971     36.712    3134.31  2.74557  5651.07
     38.512   -112.862  163.291      44.8246   3709.47  4.69564  6172.23
     38.5642  -112.907   19.0248     22.3832   2913.51  2.74896  5516.75
     38.5695  -112.893   18.5733     16.4856   3081.45  2.8482   5654.83
     38.5682  -112.85    25.743   …  32.307    2915.4   2.83643  5510.52
     38.5488  -112.822   11.5693     23.1454   2909.32  2.64491  5504.12
     38.5495  -112.826   14.2348     17.9023   3385.39  2.58566  5815.15
     38.5499  -112.853   25.3148     13.0501   3711.67  2.60167  6028.44
     38.5503  -112.857   25.2905     11.4289   3687.52  2.58977  6012.66
     38.5515  -112.864   16.8433  …   9.02111  3671.58  2.51107  6002.38
     38.5523  -112.872   14.865       9.88504  3468.12  2.51768  5869.24
     38.5517  -112.874   15.0315     10.1955   3484.39  2.52031  5879.88
      ⋮                           ⋱   ⋮                          
     38.4351  -112.906   42.5479  …  22.7564   3143.99  3.10724  5702.49
     38.4232  -112.884   28.7183     28.4654   3120.8   2.83502  5648.9
     38.4387  -112.885   37.7746     26.9083   3158.9   3.13456  5717.11
     38.425   -112.896   17.562      14.3827   3377.22  2.79974  5847.7
     38.5067  -112.857  167.387      60.8642   3616.67  5.62827  6243.68
     38.4168  -112.833   11.7769  …  19.1485   3131.86  2.59624  5649.4
     38.4697  -112.953   49.8904     26.3974   3092.5   3.59158  5737.67
     38.4757  -112.953   28.0618     27.1464   3151.97  3.62818  5809.66
     38.4692  -112.917   80.9602     27.8056   3047.46  3.68361  5682.98
     38.4724  -112.92    55.6592     19.7741   2886.41  2.9348   5489.11
     38.4428  -112.95    33.9897  …  11.2134   2885.26  2.70606  5488.0
     38.4503  -112.952   30.732      22.1075   2997.02  3.05272  5610.8




```julia
# write your code here
```

## Math behind $k$-means clustering

### $k$-means is a classic method for clustering
- $k$ is an integer number that produces a fixed number of cluster, which are associated with a center and each data point is assigned to a cluster.
- It solves the following optimization problem:
$$
\mathrm{minimize} \sum^{n}_{i=1} \Vert( \mathbf{x}_i - \mathbf{\mu}_{z_i} \Vert^2)  \quad \mathrm{w.r.t} \quad \left(\mathbf{\mu}, z\right)
$$
where $\mu_k$ is the center of the $k^\mathrm{th}$ cluster, $z_i$ is an index of the cluster for point $\mathbf{x}_i$
