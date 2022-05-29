import Flux
import CUDA
import MLDatasets

function getdata(args, device)
	# Loading Dataset
	xtrain, ytrain = MLDatasets.MNIST.traindata(Float32)
	xtest, ytest = MLDatasets.MNIST.testdata(Float32)

	# Reshape Data in order to flatten each image into a linear array
	xtrain = Flux.flatten(xtrain)
	xtest = Flux.flatten(xtest)

	# One-hot-encode the labels
	ytrain = Flux.onehotbatch(ytrain, 0:9)
	ytest = Flux.onehotbatch(ytest, 0:9)

	# Create DataLoaders (mini-batch iterators)
	train_loader = Flux.Data.DataLoader((xtrain, ytrain), batchsize=args.batchsize, shuffle=true)
	test_loader = Flux.Data.DataLoader((xtest, ytest), batchsize=args.batchsize)

	return train_loader, test_loader
end

function build_model(; imgsize=(28,28,1), nclasses=10)
	return Flux.Chain(Flux.Dense(prod(imgsize), 32, Flux.relu), Flux.Dense(32, nclasses))
end

function loss_and_accuracy(data_loader, model, device)
	acc = 0
	ls = 0.0f0
	num = 0
	for (x, y) in data_loader
		x, y = device(x), device(y)
		ŷ = model(x)
		ls += Flux.Losses.logitcrossentropy(ŷ, y, agg=sum)
		acc += sum(Flux.onecold(ŷ) .== Flux.onecold(y))
		num += size(x)[end]
	end
	return ls / num, acc / num
end

@Base.kwdef mutable struct Args
	η::Float64 = 3e-4       # learning rate
	batchsize::Int = 256    # batch size
	epochs::Int = 10        # number of epochs
	use_cuda::Bool = false   # use gpu (if cuda available)
end

function train(; kws...)
	args = Args(; kws...) # collect options in a struct for convenience

	if CUDA.functional() && args.use_cuda
		@info "Training on CUDA GPU"
		CUDA.allowscalar(false)
		device = Flux.gpu
	else
		@info "Training on CPU"
		device = Flux.cpu
	end

	# Create test and train data loaders
	train_loader, test_loader = getdata(args, device)

	# Construct model
	model = build_model() |> device
	ps = Flux.params(model) # model's trainable parameters

	## Optimizer
	opt = Flux.ADAM(args.η)

	## Training
	for epoch in 1:args.epochs
		for (x, y) in train_loader
			x, y = device(x), device(y) # transfer data to device
			display(y)
			gs = Flux.gradient(()->Flux.Losses.logitcrossentropy(model(x), y), ps) # compute gradient
			Flux.Optimise.update!(opt, ps, gs) # update parameters
		end

		train_loss, train_acc = loss_and_accuracy(train_loader, model, device)
		test_loss, test_acc = loss_and_accuracy(test_loader, model, device)
		println("Epoch = $epoch")
		println("  train_loss = $train_loss, train_accuracy = $train_acc")
		println("  test_loss = $test_loss, test_accuracy = $test_acc")
	end
end

train()