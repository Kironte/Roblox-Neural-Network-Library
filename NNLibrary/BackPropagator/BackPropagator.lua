--[[
Designed and written in it's entirety by Kironte (roblox.com/users/49703460/profile).
Made for the Roblox Neural Network Library.
For documentation and the open source license, refer to: github.com/Kironte/Roblox-Neural-Network-Library

Last updated 11/13/2020
]]

local Package = script:FindFirstAncestorOfClass("Folder")
local Base = require(Package.BaseRedirect)

local BackPropagator = Base.new("BackPropagator")
--local BackPropagator = Base.newExtends("BackPropagator",Package.BackPropagator)

function BackPropagator.new(neuralNetwork)
	Base.Assert(neuralNetwork,"NeuralNetwork")
	
	local obj = BackPropagator:make()
	--local obj = BackPropagator:super()
	
	obj.NeuralNetwork = neuralNetwork
	obj.CostValues = {
		Outputs = {};
		Activations = {};
	}
	obj.NumberOfCosts = 0
	obj.Gradients = {}
	
	return obj
end

function BackPropagator:Reset()
	self.CostValues = {
		Outputs = {};
		Activations = {};
	}
	self.NumberOfCosts = 0
	self.Gradients = {}
end

function BackPropagator:GetGradient(node)
	--Base.Assert(node,"Node")
	
	local gradient = self.Gradients[node:GetID()]
	if not gradient then
		if node:isA("OutputNode") then
			return math.clamp(self:CalculateOutputGradient(node),-1,1)
		end
		return math.clamp(self:CalculateHiddenGradient(node),-1,1)
	end
	return math.clamp(gradient,-1,1)
end

function BackPropagator:SetGradient(node,gradient)
	--Base.Assert(node,"Node",gradient,"number")
	
	self.Gradients[node:GetID()] = gradient
end

function BackPropagator:CalculateHiddenGradient(node)
	--Base.Assert(node,"Node")
	
	local derivValue = node:GetActivationFunction():GetDeriv(node:GetValue())
	
	local sumValue = 0
	for _,outSynapse in pairs(node:GetOutputSynapses()) do
		local outNode = outSynapse:GetOutputNode()
		local outWeight = outSynapse:GetWeight()
		sumValue += outWeight * self:GetGradient(outNode)
	end
	
	local gradient = derivValue * sumValue
	
	self:SetGradient(node,gradient)
	return gradient
end

function BackPropagator:CalculateOutputGradient(node)
	--Base.Assert(node,"OutputNode")
	
	local derivValue = node:GetActivationFunction():GetDeriv(node:GetValue())
	local gradient = derivValue * self.CostValues.Outputs[node:GetName()]
	
	self:SetGradient(node,gradient)
	
	return gradient
end

function BackPropagator:Learn()
	local network = self.NeuralNetwork
	local optimizer = network:GetOptimizer()
	
	for _,node in pairs(network:GetNodes()) do
		if node:isA("InputNode") then continue end
		
		local gradient = self:GetGradient(node)
		local learningRate = node:GetLearningRate()
		--Weights
		for _,synapse in pairs(node:GetInputSynapses()) do
			local inNode = synapse:GetInputNode()
			local inNodeValue  = 0
			if type(inNode:GetValue()) == "table" then
				for _,v in pairs(inNode:GetValue()) do
					inNodeValue += v
				end
			else
				inNodeValue = inNode:GetValue()
			end 
			
			synapse:AddWeight(optimizer:Calculate(node,inNodeValue,nil,synapse:GetID()))
		end
		
		node:AddBias(optimizer:Calculate(node))
	end
	
	self:Reset()
end

function BackPropagator:CalculateCost(inputValues,correctOutputValues)
	Base.Assert(inputValues,"dictionary",correctOutputValues,"dictionary")
	
	local network = self.NeuralNetwork
	
	network:SetInputValues(inputValues)
	local outputValues = network()
	
	self.NumberOfCosts += 1
	
	for _,node in pairs(network:GetNodes()) do
		local value = node:GetValue()
		
		if type(value) == "number" then
			value = {value}
		end
		if not self.CostValues.Activations[node:GetID()] then
			self.CostValues.Activations[node:GetID()] = value
		else
			for k,v in ipairs(self.CostValues.Activations[node:GetID()]) do
				self.CostValues.Activations[node:GetID()][k] += ((value[k]-v)/self.NumberOfCosts)
			end
		end
	end
	
	for outputName,value in pairs(outputValues) do
		self.CostValues.Outputs[outputName] = self.CostValues.Outputs[outputName] or 0
		local costAverage = self.CostValues.Outputs[outputName]
		
		if not correctOutputValues[outputName] then
			continue
		end
		local cost = (value - (correctOutputValues[outputName]))
		
		self.CostValues.Outputs[outputName] += (cost-costAverage)/self.NumberOfCosts
	end
	
	return self.CostValues,outputValues
end

function BackPropagator:GetCost()
	if self.NumberOfCosts == 0 then
		warn("No costs were calculated yet.")
	end
	return self.CostValues
end

function BackPropagator:GetTotalCost()
	local sum = 0
	for _,cost in pairs(self:GetCost().Outputs) do
		sum += cost^2
	end
	return sum
end

return BackPropagator--[[
Designed and written in it's entirety by Kironte (roblox.com/users/49703460/profile).
Made for the Roblox Neural Network Library.
For documentation and the open source license, refer to: github.com/Kironte/Roblox-Neural-Network-Library

Last updated 11/13/2020
]]

local Package = script:FindFirstAncestorOfClass("Folder")
local Base = require(Package.BaseRedirect)

local BackPropagator = Base.new("BackPropagator")
--local BackPropagator = Base.newExtends("BackPropagator",Package.BackPropagator)

function BackPropagator.new(neuralNetwork)
	Base.Assert(neuralNetwork,"NeuralNetwork")
	
	local obj = BackPropagator:make()
	--local obj = BackPropagator:super()
	
	obj.NeuralNetwork = neuralNetwork
	obj.CostValues = {
		Outputs = {};
		Activations = {};
	}
	obj.NumberOfCosts = 0
	obj.Gradients = {}
	
	return obj
end

function BackPropagator:Reset()
	self.CostValues = {
		Outputs = {};
		Activations = {};
	}
	self.NumberOfCosts = 0
	self.Gradients = {}
end

function BackPropagator:GetGradient(node)
	--Base.Assert(node,"Node")
	
	local gradient = self.Gradients[node:GetID()]
	if not gradient then
		if node:isA("OutputNode") then
			return math.clamp(self:CalculateOutputGradient(node),-1,1)
		end
		return math.clamp(self:CalculateHiddenGradient(node),-1,1)
	end
	return math.clamp(gradient,-1,1)
end

function BackPropagator:SetGradient(node,gradient)
	--Base.Assert(node,"Node",gradient,"number")
	
	self.Gradients[node:GetID()] = gradient
end

function BackPropagator:CalculateHiddenGradient(node)
	--Base.Assert(node,"Node")
	
	local derivValue = node:GetActivationFunction():GetDeriv(node:GetValue())
	
	local sumValue = 0
	for _,outSynapse in pairs(node:GetOutputSynapses()) do
		local outNode = outSynapse:GetOutputNode()
		local outWeight = outSynapse:GetWeight()
		sumValue += outWeight * self:GetGradient(outNode)
	end
	
	local gradient = derivValue * sumValue
	
	self:SetGradient(node,gradient)
	return gradient
end

function BackPropagator:CalculateOutputGradient(node)
	--Base.Assert(node,"OutputNode")
	
	local derivValue = node:GetActivationFunction():GetDeriv(node:GetValue())
	local gradient = derivValue * self.CostValues.Outputs[node:GetName()]
	
	self:SetGradient(node,gradient)
	
	return gradient
end

function BackPropagator:Learn()
	local network = self.NeuralNetwork
	local optimizer = network:GetOptimizer()
	
	for _,node in pairs(network:GetNodes()) do
		if node:isA("InputNode") then continue end
		
		local gradient = self:GetGradient(node)
		local learningRate = node:GetLearningRate()
		--Weights
		for _,synapse in pairs(node:GetInputSynapses()) do
			local inNode = synapse:GetInputNode()
			local inNodeValue  = 0
			if type(inNode:GetValue()) == "table" then
				for _,v in pairs(inNode:GetValue()) do
					inNodeValue += v
				end
			else
				inNodeValue = inNode:GetValue()
			end 
			
			synapse:AddWeight(optimizer:Calculate(node,inNodeValue,nil,synapse:GetID()))
		end
		
		node:AddBias(optimizer:Calculate(node))
	end
	
	self:Reset()
end

function BackPropagator:CalculateCost(inputValues,correctOutputValues)
	Base.Assert(inputValues,"dictionary",correctOutputValues,"dictionary")
	
	local network = self.NeuralNetwork
	
	network:SetInputValues(inputValues)
	local outputValues = network()
	
	self.NumberOfCosts += 1
	
	for _,node in pairs(network:GetNodes()) do
		local value = node:GetValue()
		
		if type(value) == "number" then
			value = {value}
		end
		if not self.CostValues.Activations[node:GetID()] then
			self.CostValues.Activations[node:GetID()] = value
		else
			for k,v in ipairs(self.CostValues.Activations[node:GetID()]) do
				self.CostValues.Activations[node:GetID()][k] += ((value[k]-v)/self.NumberOfCosts)
			end
		end
	end
	
	for outputName,value in pairs(outputValues) do
		self.CostValues.Outputs[outputName] = self.CostValues.Outputs[outputName] or 0
		local costAverage = self.CostValues.Outputs[outputName]
		
		if not correctOutputValues[outputName] then
			continue
		end
		local cost = (value - (correctOutputValues[outputName]))
		
		self.CostValues.Outputs[outputName] += (cost-costAverage)/self.NumberOfCosts
	end
	
	return self.CostValues,outputValues
end

function BackPropagator:GetCost()
	if self.NumberOfCosts == 0 then
		warn("No costs were calculated yet.")
	end
	return self.CostValues
end

function BackPropagator:GetTotalCost()
	local sum = 0
	for _,cost in pairs(self:GetCost().Outputs) do
		sum += cost^2
	end
	return sum
end

return BackPropagator