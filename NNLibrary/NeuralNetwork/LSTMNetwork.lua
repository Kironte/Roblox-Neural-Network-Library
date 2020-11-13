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
local LSTMNode = require(Package.Node.LSTMNode)
local InputNode = require(Package.Node.InputNode)
local OutputNode = require(Package.Node.OutputNode)
local LSTMBackPropagator = require(Package.BackPropagator.LSTMBackPropagator)

--ocal LSTMNetwork = Base.new("LSTMNetwork")
local LSTMNetwork = Base.newExtends("LSTMNetwork",NeuralNetwork)

function LSTMNetwork.new(inputNamesArray,numberOfLSTMLayers,numberOfLSTMNodesPerLayer,outputNamesArray,customSettings)
	Base.Assert(inputNamesArray,"array",numberOfLSTMLayers,"number",numberOfLSTMNodesPerLayer,"number",outputNamesArray,"array",customSettings,"dictionary OPT")
	
	--local obj = LSTMNetwork:make()
	local obj = LSTMNetwork:super(customSettings)
	
	--Default Settings
	local default = {}
	default.HiddenActivationName = "ReLU"
	default.OutputActivationName = "Sigmoid"
	default.Bias = 0
	default.LearningRate = 0.3
	default.NumOfInputsForLSTMUnits = {Default = 1}
	default.MakeDenseLayer = true
	default.MakeDirectOutput = false
	default.RandomizeWeights = true
	
	if customSettings then
		for setting,value in pairs(default) do
			if customSettings[setting] ~= nil then
				default[setting] = customSettings[setting]
			end
		end
	end
	-----------------------------------------------
	
	obj.CreationVariables = {inputNamesArray,numberOfLSTMLayers,numberOfLSTMNodesPerLayer,outputNamesArray,customSettings}
	
	for _,inputName in pairs(inputNamesArray) do
		local inputNode = InputNode.new(inputName)
		obj:AddInputNode(inputNode)
	end
	
	obj.Layers = {}
	for layerNumber = 1, numberOfLSTMLayers do
		local nodeLayer = NodeLayer.new()
		
		for nodeNumber = 1, numberOfLSTMNodesPerLayer do
			local numOfInputs = default.NumOfInputsForLSTMUnits[nodeNumber] or default.NumOfInputsForLSTMUnits.Default
			local LSTMnode = LSTMNode.new(default.HiddenActivationName,default.Bias,default.LearningRate,nil,nil,numOfInputs)
			nodeLayer:AddNodes(LSTMnode)
			obj:AddHiddenNode(LSTMnode)
			
			local otherNodes = nodeLayer:GetNodes()
			if nodeNumber > 1 then
				local prevNode = otherNodes[#otherNodes-1]
				
				prevNode:SetNextLSTMNode(LSTMnode)
				LSTMnode:SetPrevLSTMNode(prevNode)
			end
			
			if layerNumber == 1 then
				if nodeNumber <= #inputNamesArray then
					local inputNode = Base.findByName(obj.InputNodes,inputNamesArray[nodeNumber])
					obj:ConnectNodes(inputNode,LSTMnode)
				end
			else
				local previousNode = obj.Layers[#obj.Layers]:GetNodes()[nodeNumber]
				obj:ConnectNodes(previousNode,LSTMnode)
			end
		end
		
		obj.Layers[layerNumber] = nodeLayer
	end
	
	if default.MakeDenseLayer then
		local denseLayer = NodeLayer.new()
		for nodeNumber = 1, numberOfLSTMNodesPerLayer do
			local node = Node.new(default.HiddenActivationName,default.Bias,default.LearningRate)
			denseLayer:AddNodes(node)
			obj:AddHiddenNode(node)
			
			for _,previousNode in pairs(obj.Layers[#obj.Layers]:GetNodes()) do
				obj:ConnectNodes(previousNode,node)
			end
		end
		obj.Layers[#obj.Layers+1] = denseLayer
	end
	
	for k,outputName in ipairs(outputNamesArray) do
		local outputNode = OutputNode.new(default.OutputActivationName,outputName,default.Bias,default.LearningRate)
		obj:AddOutputNode(outputNode)
		
		if not default.MakeDirectOutput then
			for _,layerNode in pairs(obj.Layers[#obj.Layers]:GetNodes()) do
				obj:ConnectNodes(layerNode,outputNode)
			end
		else
			local prevNode = obj.Layers[#obj.Layers]:GetNodes()[k]
			if prevNode then
				obj:ConnectNodes(prevNode,outputNode)
			end
			outputNode:SetDirectOutput(true)
		end
	end
	
	obj.BackPropagator = LSTMBackPropagator.new(obj)
	if default.RandomizeWeights then
		obj:RandomizeWeights()
	end
	
	return obj
end

return LSTMNetwork