--[[
Designed and written in it's entirety by Kironte (roblox.com/users/49703460/profile).
Made for the Roblox Neural Network Library.
For documentation and the open source license, refer to: github.com/Kironte/Roblox-Neural-Network-Library

Last updated 11/13/2020
]]

local Package = script:FindFirstAncestorOfClass("Folder")
local Base = require(Package.BaseRedirect)

local GeneticAlgorithm = Base.new("GeneticAlgorithm")
--local GeneticAlgorithm = Base.newExtends("GeneticAlgorithm",?)

function GeneticAlgorithm.new(neuralNetwork,popSize,geneticSettings)
	Base.Assert(neuralNetwork,"NeuralNetwork",popSize,"number",geneticSettings,"dictionary OPT")
	
	local obj = GeneticAlgorithm:make()
	--local obj = GeneticAlgorithm:super()
	
	--*** Default Settings ***
	local default = {}
	default.ScoreFunction = false
	default.PostFunction = false
	default.HigherScoreBetter = true
	
	default.PercentageToKill = 0.5
	default.PercentageOfKilledToRandomlySpare = 0.1
	
	default.PercentageOfBestParentToCrossover = 0.6
	
	default.PercentageToMutate = 0.1
	default.MutateBestNetwork = false
	default.PercentageOfCrossedToMutate = 0.5
	
	default.NumberOfNodesToMutate = 2
	default.ParameterMutateRange = 4
	
	
	if geneticSettings then
		for setting,value in pairs(default) do
			if geneticSettings[setting] ~= nil then
				default[setting] = geneticSettings[setting]
			end
		end
	end
	-----------------------------------------------
	
	obj.NeuralNetwork = neuralNetwork
	obj.PopSize = popSize
	obj.Population = {}
	obj.ScoresCalculated = false
	obj.GeneticSettings = default
	obj.Generation = 1
	
	return obj
end

function GeneticAlgorithm:GetPopulation()
	return self.Population
end

function GeneticAlgorithm:GetBestNetwork()
	return self:GetPopulation()[1].Network
end

function GeneticAlgorithm:AddNetwork(network)
	--Base.Assert(network,"NeuralNetwork")
	
	table.insert(self.Population,{Network=network,Score=0})
end

function GeneticAlgorithm:ProcessGeneration(scoreArray)
	Base.Assert(scoreArray,"array OPT")
	
	self:ScoreNetworks(scoreArray)
	self:KillWorstNetworks()
	self:CrossoverNetworksToFill()
	self:MutateNetworks()
	
	self.Generation += 1
	
	local setting = self.GeneticSettings
	local postFunc = setting.PostFunction
	if postFunc then
		postFunc(self)
	end
end

function GeneticAlgorithm:ProcessGenerations(num)
	Base.Assert(num,"number")
	
	if not self.ScoreFunc then
		--TODO error
	end
	
	for i=1, num do
		self:ProcessGeneration()
	end
end

function GeneticAlgorithm:CrossoverNetworksToFill()
	
	local population = self.Population
	local popSize = self.PopSize
	local setting = self.GeneticSettings
	
	local percOfBestParentToCrossover = setting.PercentageOfBestParentToCrossover
	local missingNetworks = popSize - #population
	
	for i=1, missingNetworks do
		
		local parentIndexes = Base.DistinctRandIntArray(1,#population,2)
		table.sort(parentIndexes,function(a,b)
			return a < b
		end)
		
		local parent1Data,parent2Data = population[parentIndexes[1]],population[parentIndexes[2]]
		local child = self:CrossoverNetworks(parent1Data.Network,parent2Data.Network)
		
		self:AddNetwork(child)
	end
end

function GeneticAlgorithm:CrossoverNetworks(parent1,parent2)
end

function GeneticAlgorithm:KillWorstNetworks()
	local population = self.Population
	local popSize = self.PopSize
	local setting = self.GeneticSettings 
	
	local percToKill = setting.PercentageToKill
	local percToRandSpare = setting.PercentageOfKilledToRandomlySpare
	local indexStart = math.clamp(math.floor(popSize * (1-percToKill) + 1), 2, popSize)
	for i=indexStart, self.PopSize do
		if math.random() < percToRandSpare then continue end
		
		if population[i] == nil then
			print(population[i],population[9],#population,indexStart,popSize,i)
			for d=1, popSize do
				print(d,population[d])
			end
		end
		local network = population[i].Network
		
		network:Destroy()
		population[i] = false
	end
	
	while true do
		local clear = true
		for i=1, #population do
			if not population[i] then
				table.remove(population,i)
				clear = false
				break
			end
		end
		if clear then
			break
		end
	end
	
	for i=#population,indexStart,-1 do
		if not population[i] then
			table.remove(population,i)
		end
	end
	
	self.ScoresCalculated = false
end

function GeneticAlgorithm:ScoreNetworks(scoreArray)
	--Base.Assert(scoreArray,"array OPT")
	
	if not self.ScoresCalculated then
		if scoreArray then
			self:SetScores(scoreArray)
		else
			self:CalculateScores()
		end
		self.ScoresCalculated = true
		
		self:SortPopulation()
	end
end

function GeneticAlgorithm:SortPopulation()
	local setting = self.GeneticSettings 
	
	local higherScoreBetter = setting.HigherScoreBetter
	table.sort(self.Population,function(a,b)
		if higherScoreBetter then
			return a.Score > b.Score
		else
			return a.Score < b.Score
		end
	end)
end

function GeneticAlgorithm:SetScores(scoreArray)
	--Base.Assert(scoreArray,"array")
	
	local population = self.Population
	
	for k,v in pairs(population) do
		v.Score = scoreArray[k]
	end
end

function GeneticAlgorithm:GetInfo()
	local info = {
		Generation = self.Generation;
		BestScore = self.Population[1].Score;
	}
	
	local sum = 0
	for _,v in pairs(self.Population) do
		sum += v.Score
	end
	info.AverageScore = sum / #self.Population
	
	return info
end

function GeneticAlgorithm:CalculateScores()
end

function GeneticAlgorithm:MutateNetworks()
end

return GeneticAlgorithm