--[[
Designed and written in it's entirety by Kironte (roblox.com/users/49703460/profile).
Made for the Roblox Neural Network Library.
For documentation and the open source license, refer to: github.com/Kironte/Roblox-Neural-Network-Library

Last updated 11/13/2020
]]

local Package = script:FindFirstAncestorOfClass("Folder")
local Base = require(Package.BaseRedirect)

local GeneticAlgorithm = require(Package.GeneticAlgorithm)

--local ParamEvo = Base.new("ParamEvo")
local ParamEvo = Base.newExtends("ParamEvo",GeneticAlgorithm)

function ParamEvo.new(neuralNetworkTemp,popSize,geneticSettings)
	Base.Assert(neuralNetworkTemp,"NeuralNetwork",popSize,"number",geneticSettings,"dictionary OPT")
	
	--local obj = ParamEvo:make()
	local obj = ParamEvo:super(neuralNetworkTemp,popSize,geneticSettings)
	
	--*** Default Settings ***
	local default = obj.GeneticSettings
	default.ParameterNoiseRange = 0.01
	
	if geneticSettings then
		for setting,value in pairs(default) do
			if geneticSettings[setting] ~= nil then
				default[setting] = geneticSettings[setting]
			end
		end
	end
	-----------------------------------------------
	
	obj:GeneratePopulation()
	
	return obj
end

function ParamEvo:GeneratePopulation()
	local networkTemp = self.NeuralNetwork
	
	for num = 1, self.PopSize do
		local newNetwork 
		if networkTemp:isA("FeedforwardNetwork") then
			--(inputNamesArray,numberOfLayers,numberOfNodesPerLayer,outputNamesArray,customSettings)
			local inputNamesArray,numberOfLayers,numberOfNodesPerLayer,outputNamesArray,customSettings = networkTemp:GetCreationVariables()
			
			newNetwork = networkTemp.new(inputNamesArray,numberOfLayers,numberOfNodesPerLayer,outputNamesArray,customSettings)
		elseif networkTemp:isA("LSTMNetwork") then
			--(inputNamesArray,numberOfLSTMLayers,numberOfLSTMNodesPerLayer,outputNamesArray,customSettings)
			local inputNamesArray,numberOfLSTMLayers,numberOfLSTMNodesPerLayer,outputNamesArray,customSettings = networkTemp:GetCreationVariables()
			
			newNetwork = networkTemp.new(inputNamesArray,numberOfLSTMLayers,numberOfLSTMNodesPerLayer,outputNamesArray,customSettings)
		end
		
		self:AddNetwork(newNetwork)
	end
end

function ParamEvo:CrossoverNetworks(parent1,parent2)
	--Base.Assert(parent1,"NeuralNetwork",parent2,"NeuralNetwork")
	
	local networkTemp = self.NeuralNetwork
	local setting = self.GeneticSettings
	local packageInfo = {_Package=Package}
	
	local crossoverRatio = setting.PercentageOfBestParentToCrossover
	local paramNoise = setting.ParameterNoiseRange
	local percOfCrossMutate = setting.PercentageOfCrossedToMutate
	
	local child = parent1:Clone(packageInfo)
	
	for nodeK,node1 in pairs(child:GetFunctionalNodes()) do
		
		local crossover = math.random() > crossoverRatio
		local node2 = parent2:GetFunctionalNodes()[nodeK]
		
		local function copyParameters(...)
			for _,param in pairs({...}) do
				if crossover then
					if type(node2[param]) == "table" then
						node1[param] = Base.Clone(node2[param],packageInfo) 
					else
						node1[param] = node2[param]
					end
				end
			end
		end
		
		node1:AddRandomNoise(-paramNoise,paramNoise)
		
		local node1Syn,node2Syn = node1:GetInputSynapses(),node2:GetInputSynapses()
		for synapseK,synapse in pairs(node1Syn) do
			if crossover then
				synapse:SetWeight(node2Syn[synapseK]:GetWeight())
			end
		end
		
		if node1:isA("LSTMNode") then
			copyParameters(	"InputGateNetwork","ForgetGateNetwork","ActivationGateNetwork",
							"OutputGateNetwork","Bias")
		else --Normal nodes
			copyParameters("Bias")
		end
	end
	
	self:MutateNetwork(child,percOfCrossMutate)
	
	return child
end

function ParamEvo:MutateNetwork(network,chance)
	local networkTemp = self.NeuralNetwork
	local population = self.Population
	local popSize = self.PopSize
	local setting = self.GeneticSettings
	
	local numNodesToMutate = setting.NumberOfNodesToMutate
	local paramMutateRange = setting.ParameterMutateRange
	
	if math.random() > chance then
		return
	end
	
	local nodes = network:GetFunctionalNodes()
	local nodesToMutate = Base.DistinctRandIntArray(1,#nodes,numNodesToMutate)
	
	for _,nodeK in pairs(nodesToMutate) do
		local node = nodes[nodeK]
		
		node:AddRandomNoise(-paramMutateRange,paramMutateRange)
	end
end

function ParamEvo:MutateNetworks()
	local networkTemp = self.NeuralNetwork
	local population = self.Population
	local popSize = self.PopSize
	local setting = self.GeneticSettings
	
	local percMutate = setting.PercentageToMutate
	local mutateBest = setting.MutateBestNetwork
	
	for networkNum,networkData in pairs(population) do
		if networkNum == 1 and not mutateBest then
			continue
		end
		self:MutateNetwork(networkData.Network,percMutate)
	end
end

function ParamEvo:CalculateScores()
	local population = self.Population
	local popSize = self.PopSize
	local setting = self.GeneticSettings
	
	local scoreFunc = setting.ScoreFunction
	if scoreFunc then
		
		for k,v in pairs(population) do
			v.Score = scoreFunc(v.Network)
		end
	else
		error("No scores or ScoreFunction were provided!")
	end
end

return ParamEvo