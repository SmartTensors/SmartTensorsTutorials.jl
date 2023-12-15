# SmartTensors workshop materials

## Contents

The `Workshop` will showcase how to code and perform machine-learning analyses in Julia.
Especially, we will demonstrate what tools are good for geoscientific data analysis.
We will cover a series of general, frequently-solved ML tasks such as:
* Unsupervised and supervised machine learning

The unsupervised machine learning methods are:
* k-means clustering
* principal component analysis
* non-negative matrix factorization
* non-negative matrix factorization with customized k-means clustering

The supervised machine learning methods include:
* neural networks
* convolutional neural networks

We will also demonstrate guided tutorials using real data 
* Spatiotemporal data analytics
* GeoThermal exploration
* Filling data gaps


## Getting Started

Download and install [the latest version of Julia](https://julialang.org/downloads/).

### Julia REPL

Julia REPL looks like this:

![](images/julia_REPL.png)

### Julia and GIT

Julia uses GIT for package management.
GIT needs to be installed and configured as well.
`
### Jupyter Notebooks

Jupyter notebooks are in-browser interactive programming environments that we will use for this workshop.
The notebooks are run through IJulia.

To install IJulia separately, open a Julia REPL and run:

```julia
	ENV["PYTHON"] = ""
	import Pkg
	Pkg.add("IJulia")
```

To open a Jupyter Notebook session in your browser, run the following in a REPL:

```julia
	import IJulia
	IJulia.notebook()
```

The first time you run this, it will install `jupyter` using `conda`.

The `Workshop` has the following notebooks (in the notebook directory) that can be executed in Jupyter or in the Julia REPL.
* Julia_Introduction
* Unsupervised_ML
* Supervised_ML
* Geothermalcloud

## Required packages/modules to run the above-mentioned notebooks

```julia
	ENV["PYTHON"] = ""
	import Pkg
	Pkg.add("NMF")
	Pkg.add("Clustering")
	Pkg.add("Statistics")
	Pkg.add("MultivariateStats")
	Pkg.add("Distances")
	Pkg.add("Random")
	Pkg.add("Mads")
	Pkg.add("NMFk")
	Pkg.add("DelimitedFiles")
	Pkg.add("Cairo")
	Pkg.add("Fontconfig")
	Pkg.add("Gadfly")
	Pkg.add("Compose")
	Pkg.add("GMT") # this is not mandatory but an alternative tool of ArcGIS
```

## Julia support

The official Julia documentation is available at [https://docs.julialang.org](https://docs.julialang.org).

The official Julia [discourse https://discourse.julialang.org](https://discourse.julialang.org) is an excellent resource for all kinds of questions and insights in addition to [Stack Overflow](https://stackoverflow.com/questions/tagged/julia).

In the Julia community, it is not recommended to push/pull requests, submit coding issues, or ask questions before you have checked for existing answers or insights at the [Julia discourse website](https://discourse.julialang.org).
