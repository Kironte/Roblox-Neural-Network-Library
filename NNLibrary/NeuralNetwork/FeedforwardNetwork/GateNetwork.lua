--[[
Designed and written in it's entirety by Kironte (roblox.com/users/49703460/profile).
Made for the Roblox Neural Network Library.
For documentation and the open source license, refer to: github.com/Kironte/Roblox-Neural-Network-Library

Last updated 10/13/2020
]]

local Package = script:FindFirstAncestorOfClass("Folder")
local Base = require(Package.BaseRedirect)

local NeuralNetwork = require(Package.NeuralNetwork)
local FeedforwardNetwork = require(Package.NeuralNetwork.FeedforwardNetwork)
local NodeLayer = require(Package.NodeLayer)
local Node = require(Package.Node)
local InputNode = require(Package.Node.InputNode)
local OutputNode = require(Package.Node.OutputNode)
local BackPropagator = require(Package.BackPropagator)

--local GateNetwork = Base.new("GateNetwork")
local GateNetwork = Base.newExtends("GateNetwork",FeedforwardNetwork)

function GateNetwork.new(inputNamesArray,outputNamesArray,customSettings)
	Base.Assert(inputNamesArray,"array",outputNamesArray,"array",customSettings,"dictionary OPT")
	
	--local obj = GateNetwork:make()
	local obj = GateNetwork:super(inputNamesArray,0,0,outputNamesArray,customSettings)
	obj.Node = obj.OutputNodes[1]
	obj.BackPropagator = nil
	
	return obj
end

function GateNetwork:GetNode()
	return self.Node
end

function GateNetwork:GetSynapseWithNodeName(name)
	--Base.Assert(name,"string")
	
	local correctSynapse
	for _,synapse in pairs(self.Node:GetInputSynapses()) do
		if synapse:GetInputNode():GetName() == name then
			return synapse
		end
	end
end

function GateNetwork:GetWeight(inputName)
	--Base.Assert(inputName,"string")
	
	return self:GetSynapseWithNodeName(inputName):GetWeight()
end

function GateNetwork:AddWeight(inputName,weightDelta)
	--Base.Assert(inputName,"string",weightDelta,"number")
	
	self:GetSynapseWithNodeName(inputName):AddWeight(weightDelta)
end

function GateNetwork:SetWeight(inputName,weight)
	--Base.Assert(inputName,"string",weight,"number")
	
	self:GetSynapseWithNodeName(inputName):SetWeight(weight)
end

function GateNetwork:GetBias()
	return self.Node:GetBias()
end

function GateNetwork:AddBias(biasDelta)
	--Base.Assert(biasDelta,"number")
	
	self.Node:AddBias(biasDelta)
end

function GateNetwork:SetBias(bias)
	--Base.Assert(bias,"number")
	
	self.Node:SetBias(bias)
end

function GateNetwork:GetLearningRate()
	return self.Node:GetLearningRate()
end

function GateNetwork:GetActivationFunction()
	return self.Node:GetActivationFunction()
end

return GateNetwork