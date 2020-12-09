--[[
Designed and written in it's entirety by Kironte (roblox.com/users/49703460/profile).
Made for the Roblox Neural Network Library.
For documentation and the open source license, refer to: github.com/Kironte/Roblox-Neural-Network-Library

Last updated 11/13/2020
]]

local Package = script:FindFirstAncestorOfClass("Folder")
local Base = require(Package.BaseRedirect)

local Synapse = require(Package.Synapse)
local BackPropagator = require(Package.BackPropagator)
local StochasticGradientDescent = require(Package.Optimizer.StochasticGradientDescent)

local NeuralNetwork = Base.new("NeuralNetwork")
--local NeuralNetwork = Base.newExtends(?)

function NeuralNetwork.new(customSettings)
	Base.Assert(customSettings,"dictionary OPT")
	
	local obj = NeuralNetwork:make()
	--local obj = NeuralNetwork:super()
	
	--Default Settings
	local default = {}
	default.Optimizer = StochasticGradientDescent.new()
	default.SoftMax = false
	
	if customSettings then
		for setting,value in pairs(default) do
			if customSettings[setting] ~= nil then
				default[setting] = customSettings[setting]
			end
		end
	end
	-------------------------------------
	
	obj.Nodes = {}
	obj.InputNodes = {}
	obj.OutputNodes = {}
	obj.HiddenNodes = {}
	obj.Synapses = {}
	obj.OutputValues = {}
	obj.BackPropagator = nil
	obj.Optimizer = default.Optimizer.new(unpack(default.Optimizer.CreationVariables))
	obj.Optimizer:SetNetwork(obj)
	obj.SoftMax = default.SoftMax
	
	return obj
end

function NeuralNetwork.newFromSave(serial)
	Base.Assert(serial,"string")
	
	local obj = Base.DeSerialize(serial,{_Package = Package})
	return obj
end

function NeuralNetwork:Save()
	return self:Serialize(true)
end

function NeuralNetwork:ConnectNodes(inNode,outNode,checkOveride)
	--Base.Assert(inNode,"Node",outNode,"Node",checkOveride,"boolean OPT")
	
	if not checkOveride then
		for _,synapse in pairs(self.Synapses) do
			if synapse:GetInputNode() == inNode and synapse:GetOutputNode() == outNode then
				warn("Synapse already exists")
				return 
			end
		end
	end
	
	table.insert(self.Synapses,Synapse.new(inNode,outNode))
end

function NeuralNetwork:call(inputValues,doNotClearOtherInputValues) --Fire network
	--Base.Assert(inputValues,"dictionary OPT",doNotClearOtherInputValues,"boolean OPT")
	
	self:ClearValues()
	
	if inputValues then
		self:SetInputValues(inputValues,doNotClearOtherInputValues)
	end
	
	for _,outputNode in pairs(self.OutputNodes) do
		self.OutputValues[outputNode:GetName()] = outputNode:GetValue()
	end
	
	return self:GetOutputValues()
end

function NeuralNetwork:GetOutputValues()
	if self.OutputValues == {} then
		self()
	end
	if self.SoftMax then
		local sum = 0
		for _,v in pairs(self.OutputValues) do
			sum += v
		end
		for k,v in pairs(self.OutputValues) do
			self.OutputValues[k] = v / sum
		end
	end
	return self.OutputValues
end

function NeuralNetwork:SetInputValues(tab,doNotClearOtherInputValues)
	--Base.Assert(tab,"dictionary",doNotClearOtherInputValues,"boolean OPT")

	if Base.type(tab) == "Array" then
		
	end
	
	if not doNotClearOtherInputValues then
		self:ClearInputValues()
	end
	
	for inputNodeName,inputValue in pairs(tab) do
		local inputNode = Base.findByName(self.InputNodes,inputNodeName)
		if inputNode then
			inputNode:SetValue(inputValue)
		else
			error("There is no input node named: "..inputNodeName)
		end
	end
end

function NeuralNetwork:ClearInputValues()
	for _,node in pairs(self.InputNodes) do
		node:ClearValue()
	end
	self.OutputValues = {}
end

function NeuralNetwork:ClearValues()
	for _,node in pairs(self.Nodes) do
		if not node:isA("InputNode") then
			node:ClearValue()
		end
	end
	self.OutputValues = {}
end

function NeuralNetwork:GetNodes()
	return self.Nodes
end

function NeuralNetwork:GetInputNodes()
	return self.InputNodes
end

function NeuralNetwork:AddInputNode(inputNode)
	--Base.Assert(inputNode,"Node")
	
	table.insert(self.InputNodes,inputNode)
	self:AddNode(inputNode)
end

function NeuralNetwork:GetOutputNodes()
	return self.OutputNodes
end

function NeuralNetwork:AddOutputNode(outputNode)
	--Base.Assert(outputNode,"OutputNode")
	
	table.insert(self.OutputNodes,outputNode)
	self:AddNode(outputNode)
end

function NeuralNetwork:GetHiddenNodes()
	return self.HiddenNodes
end

function NeuralNetwork:AddHiddenNode(node)
	--Base.Assert(node,"Node")
	
	table.insert(self.HiddenNodes,node)
	self:AddNode(node)
end

function NeuralNetwork:GetFunctionalNodes()
	local funcNodes = {}
	local hiddenNodes = self:GetHiddenNodes()
	local outputNodes = self:GetOutputNodes()
	for _,node in pairs(hiddenNodes) do
		table.insert(funcNodes,node)
	end
	for _,node in pairs(outputNodes) do
		table.insert(funcNodes,node)
	end
	
	return funcNodes
end

function NeuralNetwork:AddNode(node)
	--Base.Assert(node,"Node")
	
	table.insert(self.Nodes,node)
end

function NeuralNetwork:GetBackPropagator()
	return self.BackPropagator
end

function NeuralNetwork:RandomizeWeights(min,max)
	Base.Assert(min,"number OPT",max,"number OPT")
	
	local random = Random.new()
	
	min = min or -0.5
	max = max or 0.5
	for _,synapse in pairs(self.Synapses) do
		local num = random:NextNumber(min,max)
		--print(num)
		synapse:SetWeight(num)
	end
	
	random = nil
end

function NeuralNetwork:GetOptimizer()
	return self.Optimizer
end

function NeuralNetwork:GetCreationVariables()
	return unpack(self.CreationVariables)
end

function NeuralNetwork:AddRandomNoise(min,max)
	--Base.Assert(min,"number",max,"number")
	
	for _,node in pairs(self:GetFunctionalNodes()) do
		node:AddRandomNoise(min,max)
	end
end

return NeuralNetwork
