--[[
Designed and written in it's entirety by Kironte (roblox.com/users/49703460/profile).
Made for the Roblox Neural Network Library.
For documentation and the open source license, refer to: github.com/Kironte/Roblox-Neural-Network-Library

Last updated 10/13/2020
]]

local Package = script:FindFirstAncestorOfClass("Folder")
local Base = require(Package.BaseRedirect)
local Node = require(Package.Node)

--local OutputNode = Base.new("OutputNode")
local OutputNode = Base.newExtends("OutputNode",Node)

function OutputNode.new(activName,name,bias,learningRate)
	--Base.Assert(activName,"string",name,"string",bias,"number",learningRate,"number")
	
	--local obj = OutputNode:make()
	local obj = OutputNode:super(activName or "Sigmoid",bias,learningRate)
	
	if name then
		obj:SetName(name)
	end
	obj.DirectOutput = false
	
	return obj
end

function OutputNode:SetDirectOutput(bool)
	--Base.Assert(bool,"boolean")
	
	self.DirectOutput = bool
	if bool then
		self:SetLearningRate(0)
		self:SetBias(0)
		
		local synapses = self:GetInputSynapses()
		for _,synapse in pairs(synapses) do
			synapse:SetWeight(1)
		end
		self:GetActivationFunction():SetActivator("Identity")
	end
end

--Overides

function OutputNode:call()
	self:CalculateValue()	
end

return OutputNode