module SmartTensorsTutorials

const dir = splitdir(splitdir(pathof(SmartTensorsTutorials))[1])[1]

"Test SmartTensorsTutorials"
function test()
	include(joinpath(dir, "test", "runtests.jl"))
end

include("Notebooks.jl")

end