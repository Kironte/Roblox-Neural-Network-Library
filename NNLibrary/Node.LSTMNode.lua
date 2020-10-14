--[[
Designed and written in it's entirety by Kironte (roblox.com/users/49703460/profile).
Made for the Roblox Neural Network Library.
For documentation and the open source license, refer to: github.com/Kironte/Roblox-Neural-Network-Library

Last updated 10/13/2020
]]

local Package = script:FindFirstAncestorOfClass("Folder")
local Base = require(Package.BaseRedirect)

local Node = require(Package.Node)
local ActivationFunction = require(Package.ActivationFunction)
local FeedforwardNetwork = require(Package.NeuralNetwork.FeedforwardNetwork)
local GateNetwork = require(Package.NeuralNetwork.FeedforwardNetwork.GateNetwork)

--local LSTMNode = Base.new("LSTMNode")
local LSTMNode = Base.newExtends("LSTMNode",Node)

function LSTMNode.new(activName,bias,learningRate,prevLSTMNode,nextLSTMNode,numOfInputs)
	--Base.Assert(activName,"string",bias,"number",learningRate,"number",prevLSTMNode,"LSTMNode",nextLSTMNode,"LSTMNode",numOfInputs,"number")
	
	--local obj = LSTMNode:make()
	local obj = LSTMNode:super(activName,bias,learningRate)
	
	obj.PrevLSTMNode = prevLSTMNode
	obj.NextLSTMNode = nextLSTMNode
	obj.CellState = 0
	obj:SetCostData()
	obj.Value = nil
	
	numOfInputs = numOfInputs or 1
	local inputNames = {"PrevHiddenState"}
	for i=1, numOfInputs do
		table.insert(inputNames,tostring(i))
	end
	
	obj.HyperTanFunc = ActivationFunction.new("Tanh")
	
	local inputGateSettings = {
		outputActivationName = "Sigmoid";
		bias = 0.1;
		learningRate = learningRate;
	}
	obj.InputGateNetwork = GateNetwork.new(inputNames,{"out"},inputGateSettings)
	obj.InputGateNetwork:RandomizeWeights()
	
	local forgetGateSettings = {
		outputActivationName = "Sigmoid";
		bias = 0.1;
		learningRate = learningRate;
	}
	obj.ForgetGateNetwork = GateNetwork.new(inputNames,{"out"},forgetGateSettings)
	obj.ForgetGateNetwork:RandomizeWeights()
	
	local activationGateSettings = {
		outputActivationName = "Tanh";
		bias = 0.1;
		learningRate = learningRate;
	}
	obj.ActivationGateNetwork = GateNetwork.new(inputNames,{"out"},activationGateSettings)
	obj.ActivationGateNetwork:RandomizeWeights()
	
	local outputGateSettings = {
		outputActivationName = "Sigmoid";
		bias = 0.1;
		learningRate = learningRate;
	}
	obj.OutputGateNetwork = GateNetwork.new(inputNames,{"out"},outputGateSettings)
	obj.OutputGateNetwork:RandomizeWeights()
	
	
	return obj
end

function LSTMNode:CalculateValue()
	local prevHiddenState = self:GetPrevHiddenState()
	
	local numberOfInputs = #self.Inputs
	local input = 0
	if numberOfInputs ~= 0 then
		input = self.Inputs[1]:GetValue()
	end
	
	local combinedInput = {PrevHiddenState = prevHiddenState or 0}
	if type(input) == "number" then
		input = {input}
	end
	for k,v in ipairs(input) do
		combinedInput[tostring(k)] = v
	end
	
	local averageInput = 0
	for _,v in pairs(combinedInput) do
		averageInput += v
	end
	averageInput /= numberOfInputs
	
	local cellState = self:GetPrevCellState()
	
	local forgetGate = self.ForgetGateNetwork
	local inputGate = self.InputGateNetwork
	local activationGate = self.ActivationGateNetwork
	local outputGate = self.OutputGateNetwork
	
	forgetGate:SetInputValues(combinedInput)
	local forgetGateOutput = forgetGate().out
	
	inputGate:SetInputValues(combinedInput)
	local inputGateOutput = inputGate().out
	
	activationGate:SetInputValues(combinedInput)
	local activationGateOutput = activationGate().out
	
	outputGate:SetInputValues(combinedInput)
	local outputGateOutput = outputGate().out
	
	local str = ""
	for k,v in pairs(combinedInput) do
		str ..= k.."="..v.." "
	end
	
	cellState *= forgetGateOutput
	cellState += inputGateOutput * activationGateOutput
	
	local newHiddenState = self.HyperTanFunc:GetValue(cellState) * outputGateOutput
	
	self:SetCellState(cellState)
	self:SetValue(newHiddenState)
	
	self:SetCostData(averageInput,activationGateOutput,inputGateOutput,forgetGateOutput,outputGateOutput,cellState,newHiddenState)
	
	return newHiddenState
end

function LSTMNode:ClearValue()
	self.Value = nil
	self.CellState = 0
	
	self.InputGateNetwork:ClearValues()
	self.ForgetGateNetwork:ClearValues()
	self.ActivationGateNetwork:ClearValues()
	self.OutputGateNetwork:ClearValues()
	
	self:SetCostData()
end

function LSTMNode:GetCellState()
	return self.CellState
end

function LSTMNode:GetPrevCellState()
	if self.PrevLSTMNode then
		return self.PrevLSTMNode:GetCellState()
	end
	return 0
end

function LSTMNode:SetCellState(cellState)
	--Base.Assert(cellState,"number")
	
	self.CellState = cellState
end

function LSTMNode:GetNextLSTMNode()
	return self.NextLSTMNode
end

function LSTMNode:SetNextLSTMNode(nextLSTMNode)
	--Base.Assert(nextLSTMNode,"LSTMNode")
	
	self.NextLSTMNode = nextLSTMNode
end

function LSTMNode:GetPrevLSTMNode()
	return self.PrevLSTMNode
end

function LSTMNode:SetPrevLSTMNode(prevLSTMNode)
	--Base.Assert(prevLSTMNode,"LSTMNode")
	
	self.PrevLSTMNode = prevLSTMNode
end

function LSTMNode:GetPrevHiddenState()
	if self.PrevLSTMNode then
		return self.PrevLSTMNode:GetValue()
	end
	return 0
end

function LSTMNode:SetCostData(averageInput,activation,input,forget,output,state,hiddenState)
	--Base.Assert(averageInput,"number",activation,"number",input,"number",forget,"number",output,"number",state,"number",hiddenState,"number")
	
	self.CostData = {
		AverageInput = averageInput or 0;
		Activation = activation or 0;
		Input = input or 0;
		Forget = forget or 0;
		Output = output or 0;
		State = state or 0;
		HiddenState = hiddenState or 0;
	}
end

function LSTMNode:GetCostData()
	return self.CostData
end

function LSTMNode:GetActivationFunction()
	return self.HyperTanFunc
end

function LSTMNode:AddRandomNoise(min,max)
	--Base.Assert(min,"number",max,"number")
	
	Node.AddRandomNoise(self,min,max)
	
	self.InputGateNetwork:AddRandomNoise(min,max)
	self.ForgetGateNetwork:AddRandomNoise(min,max)
	self.OutputGateNetwork:AddRandomNoise(min,max)
	self.ActivationGateNetwork:AddRandomNoise(min,max)
end


return LSTMNode