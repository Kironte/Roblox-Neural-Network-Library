--[[
Designed and written in it's entirety by Kironte (roblox.com/users/49703460/profile).
Made for the Roblox Neural Network Library.
For documentation and the open source license, refer to: github.com/Kironte/Roblox-Neural-Network-Library

Last updated 11/13/2020
]]

local Package = script:FindFirstAncestorOfClass("Folder")
local Base = require(Package.BaseRedirect)

local BackPropagator = require(Package.BackPropagator)

--local LSTMBackPropagator = Base.new("LSTMBackPropagator")
local LSTMBackPropagator = Base.newExtends("LSTMBackPropagator",BackPropagator)

function LSTMBackPropagator.new(neuralNetwork)
	Base.Assert(neuralNetwork,"LSTMNetwork")
	
	--local obj = LSTMBackPropagator:make()
	local obj = LSTMBackPropagator:super(neuralNetwork)
	
	obj.CostValues = {
		Activations = {};
		Outputs = {};
		LSTM = {};
	}
	obj.Derivs = {}
	
	return obj
end

function LSTMBackPropagator:Reset()
	self.CostValues = {
		Activations = {};
		Outputs = {};
		LSTM = {};
	}
	self.NumberOfCosts = 0
	self.Gradients = {}
end

function LSTMBackPropagator:GetGradient(node)
	--Base.Assert(node,"Node")
	
	local gradient = self.Gradients[node:GetID()]
	if not gradient then
		if node:isA("OutputNode") then
			return math.clamp(self:CalculateOutputGradient(node),-1,1)
		elseif node:isA("LSTMNode") then
			return math.clamp(self:CalculateLSTMGradient(node),-1,1)
		else
			return math.clamp(self:CalculateHiddenGradient(node),-1,1)
		end
	end
	return math.clamp(gradient,-1,1)
end

function LSTMBackPropagator:CalculateOutputGradient(node)
	--Base.Assert(node,"OutputNode")
	
	local derivValue = node:GetActivationFunction():GetDeriv(node:GetValue())
	local gradient = derivValue * self.CostValues.Outputs[node:GetName()]
	
	self:SetGradient(node,gradient)
	
	return gradient
end

function LSTMBackPropagator:CalculateLSTMGradient(node,calculateInputGradient)
	--Base.Assert(node,"LSTMNode",calculateInputGradient,"boolean OPT")
	
	local prevNode = node:GetPrevLSTMNode()
	local nextNode = node:GetNextLSTMNode()
	local activFunc = node:GetActivationFunction()
	
	local activGate = node.ActivationGateNetwork
	local inputGate = node.InputGateNetwork
	local forgetGate = node.ForgetGateNetwork
	local outputGate = node.OutputGateNetwork
	
	local derivValue = activFunc:GetDeriv(node:GetValue())
	local sumValue = 0
	for _,outSynapse in pairs(node:GetOutputSynapses()) do
		local outNode = outSynapse:GetOutputNode()
		local outWeight = outSynapse:GetWeight()
		
		sumValue += outWeight * self:GetGradient(outNode)
	end
	
	local costValues = self.CostValues.LSTM[node:GetID()]
	
	local outputDelta = sumValue
	
	local nextOutputDelta = 0
	if nextNode then
		nextOutputDelta = self:GetGradient(node:GetNextLSTMNode())
	end
	
	self.Derivs[node:GetID()] = self.Derivs[node:GetID()] or {}
	local derivs = self.Derivs[node:GetID()]
	
	local derivOutput = outputDelta + nextOutputDelta
	local derivState = derivOutput * costValues.Output * activFunc:GetDeriv(costValues.State) 
	if nextNode then
		derivState += self.Derivs[nextNode:GetID()].State * self.CostValues.LSTM[nextNode:GetID()].Forget
	end
	derivs.State = derivState
	
	local derivActivGate = derivState * costValues.Input * (1 - costValues.Activation^2)--activGate:GetActivationFunction():GetDeriv(costValues.Activation)
	local derivInputGate = derivState * costValues.Activation * costValues.Input * (1 - costValues.Input)--inputGate:GetActivationFunction():GetDeriv(costValues.Input)
	local derivForgetGate = 0
	if prevNode then
		derivForgetGate = derivState * self.CostValues.LSTM[prevNode:GetID()].State * costValues.Forget * (1 - costValues.Forget)--forgetGate:GetActivationFunction():GetDeriv(costValues.Forget)
	end
	local derivOutputGate = derivOutput * activFunc:GetValue(costValues.State) * costValues.Output * (1 - costValues.Output) --outputGate:GetActivationFunction():GetDeriv(costValues.Output)
	
	derivs.Activation = derivActivGate
	derivs.Input = derivInputGate
	derivs.Forget = derivForgetGate
	derivs.Output = derivOutputGate
	
	local gradient = 	activGate:GetWeight("PrevHiddenState")*derivActivGate + inputGate:GetWeight("PrevHiddenState")*derivInputGate +
						forgetGate:GetWeight("PrevHiddenState")*derivForgetGate + outputGate:GetWeight("PrevHiddenState")*derivOutputGate

	self:SetGradient(node,gradient)
	
	return gradient
end


function LSTMBackPropagator:Learn()
	
	local network = self.NeuralNetwork
	local optimizer = network:GetOptimizer()
	
	for _,node in pairs(network:GetNodes()) do
		if node:isA("InputNode") then continue end
		
		local gradient = self:GetGradient(node)
		local learningRate = node:GetLearningRate()
		
		if not node:isA("LSTMNode") then
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
			--Bias
			node:AddBias(optimizer:Calculate(node))
		else
			local derivs = self.Derivs[node:GetID()]
			local costValues = self.CostValues.LSTM[node:GetID()]
			
			local activGate = node.ActivationGateNetwork
			local inputGate = node.InputGateNetwork
			local forgetGate = node.ForgetGateNetwork
			local outputGate = node.OutputGateNetwork
			
			local inputNode = node:GetInputSynapses()[1]
			local inputs = {0} --Incase of no input
			if inputNode then
				inputNode = inputNode:GetInputNode()
				inputs = self.CostValues.Activations[inputNode:GetID()]
			end
			
			local function modifyGateParameters(gate,gateDeriv,nextLSTMGateDeriv)
				local out = costValues.HiddenState
				--Input Weights
				for k,input in pairs(inputs) do
					local synapse = gate:GetSynapseWithNodeName(tostring(k))
					gate:AddWeight(tostring(k),optimizer:Calculate(node,input,gateDeriv,synapse:GetID()))
				end
				--Prev Hidden State Weight
				if nextLSTMGateDeriv then
					local synapse = gate:GetSynapseWithNodeName("PrevHiddenState")
					gate:AddWeight("PrevHiddenState",optimizer:Calculate(node,out,nextLSTMGateDeriv,synapse:GetID()))
				end
				--Biases
				gate:AddBias(optimizer:Calculate(node,nil,gateDeriv))
			end
			
			local nextNode = node:GetNextLSTMNode()
			if nextNode then
				local nextDerivs = self.Derivs[nextNode:GetID()]
				
				modifyGateParameters(activGate,derivs.Activation,nextDerivs.Activation)
				modifyGateParameters(inputGate,derivs.Input,nextDerivs.Input)
				modifyGateParameters(forgetGate,derivs.Forget,nextDerivs.Forget)
				modifyGateParameters(outputGate,derivs.Output,nextDerivs.Output)
			else
				modifyGateParameters(activGate,derivs.Activation)
				modifyGateParameters(inputGate,derivs.Input)
				modifyGateParameters(forgetGate,derivs.Forget)
				modifyGateParameters(outputGate,derivs.Output)
			end
		end
	end
	
	self:Reset()
end

function LSTMBackPropagator:CalculateCost(inputValues,correctOutputValues)
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
		
		self.CostValues.Outputs[outputName] += ((cost-costAverage)/self.NumberOfCosts)
	end
	
	
	local hiddenNodes = network:GetHiddenNodes()
	for _,node in pairs(hiddenNodes) do
		if node:isA("LSTMNode") then
			local entry = self.CostValues.LSTM[node:GetID()] 
			if not entry then
				self.CostValues.LSTM[node:GetID()] = {}
				entry = self.CostValues.LSTM[node:GetID()]
			end
			
			local costData = node:GetCostData()
			for k,v in pairs(costData) do
				entry[k] = entry[k] or 0
				local average = entry[k]
				
				entry[k] += ((v-average)/self.NumberOfCosts)
			end
		end
	end
	
	return self.CostValues,outputValues
end

return LSTMBackPropagator