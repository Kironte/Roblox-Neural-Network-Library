# Example Code

Along with the documentation, you will need some examples of what your code should look like when using this library.<br>
The code needed to operate this library is significantly simpler and more readable than the one for the first library, but it still has the same basic principles. For consistency, this example code does the same thing as the previous library's example code.<br><br>
The 2 examples shows how to operate single networks as well as genetic algorithm populations. LSTM and feedforward networks are interchangeable here, assuming you know how to use the former as they are not for novices. <br>
Each example is heavily documented for your understanding. To use these examples, simply drop the library into ReplicatedStorage, and copy paste the example code into a server/localscript anywhere you like, and run.<br><br>
Both examples have undocumented versions if you find it distracting/bloating.

### **Single Network Example**

```lua
--Whenever using math.random() for small experiments like this, you should set a random seed
--in order to not get the same results every time.
math.randomseed(os.clock()+os.time())

--For this experiment, I placed the library package in ReplicatedStorage.
local Package = game:GetService("ReplicatedStorage").NNLibrary
local Base = require(Package.BaseRedirect)
local FeedforwardNetwork = require(Package.NeuralNetwork.FeedforwardNetwork)
local Momentum = require(Package.Optimizer.Momentum)

--If the training/testing is intensive, we will want to setup automatic wait() statements
--in order to avoid a timeout. This can be done with os.clock().
local clock = os.clock()


----------------<<MAIN SETTINGS>>---------------------------------------------------------------


--This setting dictionary contains whatever customizations you want on your neural network.
--Each setting has it's own default and is completely optional.
local setting = {
	--We will set the optimizer to Momentum because it seems to work the best for this experiment.
	Optimizer = Momentum.new();
	--We want to accept negative inputs so a LeakyReLU will do.
	HiddenActivationName = "LeakyReLU";
	--The output is between 0 and 1 so good ol' sigmoid will do.
	OutputActivationName = "Sigmoid";
	LearningRate = 0.3;
}
--Number of generations for the training.
local generations = 200000 
--Number of generations that need to pass before we backpropagate the network.
local numOfGenerationsBeforeLearning = 1


----------------<<END OF MAIN SETTINGS>>---------------------------------------------------------------


--This is the statement that creates the network. Only the most basic settings are used here.
--The rest are in the 'setting' dictionary. In this case, the network has 2 inputs 'x' and 'y',
--2 layers with 2 nodes each, and 1 output 'out'.
local net = FeedforwardNetwork.new({"x","y"},2,3,{"out"},setting)
--To backpropagate, you need to get the network's backpropagator.
local backProp = net:GetBackPropagator()

--This function determines what mathematical function we want to test the network with 
--and if the given coordinates are above (1) or below (0) the function. 
--For this experiment, a simple cubic will do.
function isAboveFunction(x,y)
	if x^3 + 2*x^2 < y then
		return 0
	end
	return 1
end

for generation = 1, generations do
	--Both input and outputs are dictionaries where the key (index) is the name of the input/output,
	--while the value is it's associated value. This is why 'coords' has x and y, while 'correctAnswer'
	--has out.
	local coords = {x = math.random(-400,400)/100, y = math.random(-400,400)/100}

	local correctAnswer = {out = isAboveFunction(coords.x,coords.y)}
	--Here, we calculate the cost of the network with the given inputs and correct outputs. Basically,
	--we calculate how wrong/right the network currently is.
	backProp:CalculateCost(coords,correctAnswer)
	--The automated wait() and print() statements that give the computer a break every 0.1 seconds and
	--give us an update as to how much of training is left.
	if os.clock()-clock >= 0.1 then
		clock = os.clock()
		wait()
		print(generation/generations*(100).."% trained. Cost: "..backProp:GetTotalCost())
	end
	--If time is of the essence, you can have the backpropagator save the costs of multiple generations
	--before actually training the network. This results in less effective training, but is way faster.
	if generation % numOfGenerationsBeforeLearning == 0 then
		backProp:Learn()
	end
end
--Total number of test runs.
local totalRuns = 0
--The number of runs that were deemed correct.
local wins = 0

--Lua is dumb and counts -400 to 400 as 801 runs instead of 800
for x = -400, 399 do
	for y = -400, 399 do
		
		local coords = {x = x/100, y = y/100}
		--Now, you can get the output of a network by just calling it like a function.
		local output = net(coords)

		local correctAnswer = isAboveFunction(coords.x,coords.y)
		--I will call it correct if the difference between the correct answer and the network's output
		--is less than or equal to 0.3.
		if math.abs(output.out - correctAnswer) <= 0.3 then
			wins += 1
		end
		totalRuns += 1
	end

	if os.clock()-clock >= 0.1 then
		clock = os.clock()
		wait()
		print("Testing... "..(x+400)/(8).."%")
	end
end

print(wins/totalRuns*(100).."% correct!")
```


### **GeneticAlgorithm Example**

```lua
--Whenever using math.random() for small experiments like this, you should set a random seed
--in order to not get the same results every time.
math.randomseed(os.clock()+os.time())

--For this experiment, I placed the library package in ReplicatedStorage.
local Package = game:GetService("ReplicatedStorage").NNLibrary
local Base = require(Package.BaseRedirect)
local FeedforwardNetwork = require(Package.NeuralNetwork.FeedforwardNetwork)
local ParamEvo = require(Package.GeneticAlgorithm.ParamEvo)
local Momentum = require(Package.Optimizer.Momentum)

--If the training/testing is intensive, we will want to setup automatic wait() statements
--in order to avoid a timeout. This can be done with os.clock().
local clock = os.clock()


----------------<<MAIN SETTINGS>>---------------------------------------------------------------


--Number of generations to run.
local generations = 30
--The number of networks in the population. More means better outcome but worse performance.
local population = 20

--This function determines what mathematical function we want to test the network with 
--and if the given coordinates are above (1) or below (0) the function. 
--For this experiment, a simple cubic will do.
function isAboveFunction(x,y)
	if x^3 + 2*x^2 < y then
		return 0
	end
	return 1
end


--This setting dictionary contains whatever customizations you want on the neural network
--that will act as a template for the population.
--Each setting has it's own default and is completely optional.
local setting = {
	--We want to accept negative inputs so a LeakyReLU will do.
	HiddenActivationName = "LeakyReLU";
	--The output is between 0 and 1 so good ol' sigmoid will do.
	OutputActivationName = "Sigmoid";
}

--Similar to 'setting', this dictionary contains the settings for the genetic algorithm.
--As before, every setting has a default and is completely optional.
local geneticSetting = {
	--The function that, when given the network, will return it's score.
	ScoreFunction = function(net)
		local score = 0
		--Lua is dumb and counts -400 to 400 as 801 runs instead of 800
		for x = -400, 399, 8 do
			for y = -400, 399, 8 do
				--We want the values to stay within -4 and 4.
				local coords = {x = x/100, y = y/100}
				
				local correctAnswer = isAboveFunction(coords.x,coords.y)
				--Now, you can get the output of a network by just calling it like a function.
				local output = net(coords)
				--I will call it correct if the difference between the correct answer and the network's output
				--is less than or equal to 0.3.
				if math.abs(output.out - correctAnswer) <= 0.3 then
					score += 1
				end
			end
			
			if os.clock()-clock >= 0.1 then
				clock = os.clock()
				wait()
			end
		end
		
		return score
	end;
	--The function that runs when a generation is complete. It is given the genetic algorithm as input.
	PostFunction = function(geneticAlgo)
		local info = geneticAlgo:GetInfo()
		print("Generation "..info.Generation..", Best Score: "..info.BestScore/(100)^2*(100).."%")
	end;
}


----------------<<END OF MAIN SETTINGS>>---------------------------------------------------------------


--This is the statement that creates the template network. Only the most basic settings are used here.
--The rest are in the 'setting' dictionary. In this case, the network has 2 inputs 'x' and 'y',
--2 layers with 2 nodes each, and 1 output 'out'. Each network in the population will have this
--same structure.
local tempNet = FeedforwardNetwork.new({"x","y"},2,3,{"out"},setting)
local geneticAlgo = ParamEvo.new(tempNet,population,geneticSetting)
--We just tell the genetic algorithm to process a set number of generations and it does the rest
--of the work for us.
geneticAlgo:ProcessGenerations(generations)

--For testing, we go ahead and grab the first network in the population.
local net = geneticAlgo:GetBestNetwork()

--Total number of test runs.
local totalRuns = 0
--The number of runs that were deemed correct.
local wins = 0

for x = -400, 399 do
	for y = -400, 399 do

		local coords = {x = x/100, y = y/100}
		
		local output = net(coords)

		local correctAnswer = isAboveFunction(coords.x,coords.y)
		
		if math.abs(output.out - correctAnswer) <= 0.3 then
			wins += 1
		end
		totalRuns += 1
	end

	if os.clock()-clock >= 0.1 then
		clock = os.clock()
		wait()
		print("Testing... "..(x+400)/(8).."%")
	end
end

print(wins/totalRuns*(100).."% correct!")
```

### **Single Network Example (Undocumented)**

```lua
math.randomseed(os.clock()+os.time())

local Package = game:GetService("ReplicatedStorage").NNLibrary
local Base = require(Package.BaseRedirect)
local FeedforwardNetwork = require(Package.NeuralNetwork.FeedforwardNetwork)
local Momentum = require(Package.Optimizer.Momentum)

local clock = os.clock()


----------------<<MAIN SETTINGS>>---------------------------------------------------------------

local setting = {
	Optimizer = Momentum.new();
	HiddenActivationName = "LeakyReLU";
	OutputActivationName = "Sigmoid";
	LearningRate = 0.3;
}

local generations = 200000 
local numOfGenerationsBeforeLearning = 1

----------------<<END OF MAIN SETTINGS>>---------------------------------------------------------------


local net = FeedforwardNetwork.new({"x","y"},2,3,{"out"},setting)
local backProp = net:GetBackPropagator()

function isAboveFunction(x,y)
	if x^3 + 2*x^2 < y then
		return 0
	end
	return 1
end

for generation = 1, generations do
	local coords = {x = math.random(-400,400)/100, y = math.random(-400,400)/100}
	local correctAnswer = {out = isAboveFunction(coords.x,coords.y)}

	backProp:CalculateCost(coords,correctAnswer)

	if os.clock()-clock >= 0.1 then
		clock = os.clock()
		wait()
		print(generation/generations*(100).."% trained. Cost: "..backProp:GetTotalCost())
	end

	if generation % numOfGenerationsBeforeLearning == 0 then
		backProp:Learn()
	end
end

local totalRuns = 0
local wins = 0

for x = -400, 399 do
	for y = -400, 399 do
		
		local coords = {x = x/100, y = y/100}
		local output = net(coords)

		local correctAnswer = isAboveFunction(coords.x,coords.y)

		if math.abs(output.out - correctAnswer) <= 0.3 then
			wins += 1
		end
		totalRuns += 1
	end

	if os.clock()-clock >= 0.1 then
		clock = os.clock()
		wait()
		print("Testing... "..(x+400)/(8).."%")
	end
end

print(wins/totalRuns*(100).."% correct!")
```

### **GeneticAlgorithm Example (Undocumented)**

```lua
math.randomseed(os.clock()+os.time())

local Package = game:GetService("ReplicatedStorage").NNLibrary
local Base = require(Package.BaseRedirect)
local FeedforwardNetwork = require(Package.NeuralNetwork.FeedforwardNetwork)
local ParamEvo = require(Package.GeneticAlgorithm.ParamEvo)
local Momentum = require(Package.Optimizer.Momentum)

local clock = os.clock()


----------------<<MAIN SETTINGS>>---------------------------------------------------------------

local generations = 30
local population = 20

function isAboveFunction(x,y)
	if x^3 + 2*x^2 < y then
		return 0
	end
	return 1
end

local setting = {
	HiddenActivationName = "LeakyReLU";
	OutputActivationName = "Sigmoid";
}

local geneticSetting = {
	ScoreFunction = function(net)
		local score = 0
		
		for x = -400, 399, 8 do
			for y = -400, 399, 8 do
				local coords = {x = x/100, y = y/100}
				local correctAnswer = isAboveFunction(coords.x,coords.y)
				
				local output = net(coords)
				
				if math.abs(output.out - correctAnswer) <= 0.3 then
					score += 1
				end
			end
			
			if os.clock()-clock >= 0.1 then
				clock = os.clock()
				wait()
			end
		end
		
		return score
	end;
	PostFunction = function(geneticAlgo)
		local info = geneticAlgo:GetInfo()
		print("Generation "..info.Generation..", Best Score: "..info.BestScore/(100)^2*(100).."%")
	end;
}

----------------<<END OF MAIN SETTINGS>>---------------------------------------------------------------

local tempNet = FeedforwardNetwork.new({"x","y"},2,3,{"out"},setting)
local geneticAlgo = ParamEvo.new(tempNet,population,geneticSetting)

geneticAlgo:ProcessGenerations(generations)

local net = geneticAlgo:GetBestNetwork()

local totalRuns = 0
local wins = 0

for x = -400, 399 do
	for y = -400, 399 do

		local coords = {x = x/100, y = y/100}
		
		local output = net(coords)

		local correctAnswer = isAboveFunction(coords.x,coords.y)
		
		if math.abs(output.out - correctAnswer) <= 0.3 then
			wins += 1
		end
		totalRuns += 1
	end

	if os.clock()-clock >= 0.1 then
		clock = os.clock()
		wait()
		print("Testing... "..(x+400)/(8).."%")
	end
end

print(wins/totalRuns*(100).."% correct!")
```