--[[
Designed and written in it's entirety by Kironte (roblox.com/users/49703460/profile).
Made for the Roblox Neural Network Library.
For documentation and the open source license, refer to: github.com/Kironte/Roblox-Neural-Network-Library

Last updated 11/13/2020
]]

local Package = script:FindFirstAncestorOfClass("Folder")
local Base = require(Package.BaseRedirect)

local NeuralNetwork = require(Package.NeuralNetwork)
local NodeLayer = require(Package.NodeLayer)
local Node = require(Package.Node)
local InputNode = require(Package.Node.InputNode)
local OutputNode = require(Package.Node.OutputNode)
local BackPropagator = require(Package.BackPropagator)

--local FeedforwardNetwork = Base.new("FeedforwardNetwork")
local FeedforwardNetwork = Base.newExtends("FeedforwardNetwork",NeuralNetwork)

function FeedforwardNetwork.new(inputNamesArray,numberOfLayers,numberOfNodesPerLayer,outputNamesArray,customSettings)
	Base.Assert(inputNamesArray,"array",numberOfLayers,"number",numberOfNodesPerLayer,"number",outputNamesArray,"array",customSettings,"dictionary OPT")
	
	--local obj = FeedforwardNetwork:make()
	local obj = FeedforwardNetwork:super(customSettings)
	
	--Default Settings
	local default = {}
	default.HiddenActivationName = "ReLU"
	default.OutputActivationName = "Sigmoid"
	default.Bias = 0
	default.LearningRate = 0.3
	default.RandomizeWeights = true
	
	default.HiddenLayerStructure = false
	-- e.g { {NumOfNodes = 5, Activation = "ReLU"}, {NumOfNodes = 3, Activation = "Sigmoid"} }
	
	if customSettings then
		for setting,value in pairs(default) do
			if customSettings[setting] ~= nil then
				default[setting] = customSettings[setting]
			end
		end
	end
	-----------------------------------------------
	
	obj.CreationVariables = {inputNamesArray,numberOfLayers,numberOfNodesPerLayer,outputNamesArray,customSettings}
	
	--Input layer
	for _,inputName in pairs(inputNamesArray) do
		local inputNode = InputNode.new(inputName)
		obj:AddInputNode(inputNode)
	end
	
	--Hidden layers
	local layerStructure = default.HiddenLayerStructure
	if not layerStructure then
		layerStructure = {}
		for i=1, numberOfLayers do
			local structure = {
				NumOfNodes = numberOfNodesPerLayer;
				Activation = default.HiddenActivationName;
				Bias = default.Bias;
				LearningRate = default.LearningRate;
			}
			table.insert(layerStructure,structure)
		end
	end
	
	obj.Layers = {}
	for i=1, #layerStructure do
		local nodeLayer = NodeLayer.new()
		local structure = layerStructure[i]
		
		for d=1, structure.NumOfNodes do
			local activation = structure.Activation or default.HiddenActivationName
			local bias = structure.Bias or default.Bias
			local learningRate = structure.LearningRate or default.LearningRate
			
			local node = Node.new(activation,bias,learningRate)
			nodeLayer:AddNodes(node)
			obj:AddHiddenNode(node)
			
			if i == 1 then
				for _,inputNode in pairs(obj.InputNodes) do
					obj:ConnectNodes(inputNode,node)
				end
			else
				for _,previousNode in pairs(obj.Layers[i-1]:GetNodes()) do
					obj:ConnectNodes(previousNode,node)
				end
			end
		end
		
		obj.Layers[i] = nodeLayer
	end
	
	--Output layer
	for _,outputName in ipairs(outputNamesArray) do
		local outputNode = OutputNode.new(default.OutputActivationName,outputName,default.Bias,default.LearningRate)
		obj:AddOutputNode(outputNode)
		
		if numberOfLayers > 0 then
			for _,layerNode in pairs(obj.Layers[#obj.Layers]:GetNodes()) do
				obj:ConnectNodes(layerNode,outputNode)
			end
		else
			for _,inputNode in pairs(obj:GetInputNodes()) do
				obj:ConnectNodes(inputNode,outputNode)
			end
		end
		
	end
	
	obj.BackPropagator = BackPropagator.new(obj)
	if default.RandomizeWeights then
		obj:RandomizeWeights()
	end
	
	return obj
end

function FeedforwardNetwork:SetBiases(bias)
	--Base.Assert(bias,"number")
	
	for _,node in pairs(self.Nodes) do
		node:SetBias(bias)
	end
end

return FeedforwardNetwork