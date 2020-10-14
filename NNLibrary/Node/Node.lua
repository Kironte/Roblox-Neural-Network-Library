--[[
Designed and written in it's entirety by Kironte (roblox.com/users/49703460/profile).
Made for the Roblox Neural Network Library.
For documentation and the open source license, refer to: github.com/Kironte/Roblox-Neural-Network-Library

Last updated 10/13/2020
]]

local Package = script:FindFirstAncestorOfClass("Folder")
local Base = require(Package.BaseRedirect)

local ActivationFunction = require(Package.ActivationFunction)

local Node = Base.new("Node")
--local Node = Base.newExtends(?)

function Node.new(activName,bias,learningRate)
	--Base.Assert(activName,"string",bias,"number",learningRate,"number")
	
	local obj = Node:make()
	--local obj = Node:super()
	
	obj.Inputs = {}
	obj.Outputs = {}
	obj.ActivationFunction = ActivationFunction.new(activName or "ReLU")
	obj.Bias = bias or 0
	obj.LearningRate = learningRate or 0.1 
	obj.Value = nil
	
	return obj
end

function Node:call() --Fire node
	self:CalculateValue()
	
	for _,outputSyn in pairs(self.Outputs) do
		outputSyn()
	end
end

function Node:GetValue()
	return self.Value or self:CalculateValue()
end

function Node:SetValue(value)
	--Base.Assert(value,"number")
	
	self.Value = value
end

function Node:CalculateValue()
	local value = 0
	
	local sum = 0
	for _,inputSyn in pairs(self.Inputs) do
		local getValue = inputSyn:GetValue()
		local getWeight = inputSyn:GetWeight()
		if type(getValue) == "table" then
			for _,v in pairs(getValue) do
				sum += v * getWeight
			end
		else
			sum += getValue * getWeight
		end
	end
	sum += self.Bias
	
	value = self.ActivationFunction:GetValue(sum)
	self:SetValue(value)
	
	return value
end

function Node:ClearValue()
	self.Value = nil
end

function Node:AddInputSynapse(inputSynapse)
	--Base.Assert(inputSynapse,"Synapse")
	
	self.Inputs[#self.Inputs+1] = inputSynapse
end

function Node:AddOutputSynapse(outputSynapse)
	--Base.Assert(outputSynapse,"Synapse")
	
	self.Outputs[#self.Outputs+1] = outputSynapse
end

function Node:GetInputSynapses()
	return self.Inputs
end

function Node:GetOutputSynapses()
	return self.Outputs
end

function Node:RemoveInputSynapse(inputSynapse)
	--Base.Assert(inputSynapse,"Synapse")
	
	for i=1,#self.Inputs do
		if self.Inputs[i] == inputSynapse then
			table.remove(self.Inputs,i)
		end
	end
end

function Node:RemoveOutputSynapse(outputSynapse)
	--Base.Assert(outputSynapse,"Synapse")
	
	for i=1,#self.Outputs do
		if self.Outputs[i] == outputSynapse then
			table.remove(self.Outputs,i)
		end
	end
end

function Node:ClearInputSynapses()
	self.Inputs = {}
end

function Node:ClearOutputSynapses()
	self.Outputs = {}
end

function Node:SetBias(bias)
	--Base.Assert(bias,"number")
	
	self.Bias = bias
end

function Node:GetBias()
	return self.Bias
end

function Node:AddBias(biasDelta)
	--Base.Assert(biasDelta,"number")
	
	self.Bias += biasDelta
end

function Node:SetLearningRate(learningRate)
	--Base.Assert(learningRate,"number")
	
	self.LearningRate = learningRate
end

function Node:GetLearningRate()
	return self.LearningRate
end

function Node:GetActivationFunction()
	return self.ActivationFunction
end

function Node:AddRandomNoise(min,max)
	--Base.Assert(min,"number",max,"number")
	
	local function noise()
		return math.random()*(max-min)+min
	end
	for _,synapse in pairs(self:GetInputSynapses()) do
		synapse:AddWeight(noise())
	end
	
	self:AddBias(noise())
end

return Node