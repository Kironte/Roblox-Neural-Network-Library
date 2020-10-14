--[[
Designed and written in it's entirety by Kironte (roblox.com/users/49703460/profile).
Made for the Roblox Neural Network Library.
For documentation and the open source license, refer to: github.com/Kironte/Roblox-Neural-Network-Library

Last updated 10/13/2020
]]

local Package = script:FindFirstAncestorOfClass("Folder")
local Base = require(Package.BaseRedirect)

local Synapse = Base.new("Synapse")
--local Synapse = Base.newExtends(?)

function Synapse.new(input,output,weight)
	--Base.Assert(input,"Node",output,"Node",weight,"number")
	
	local obj = Synapse:make()
	--local obj = Synapse:super()
	
	obj.Input = input
	obj.Output = output
	obj.Weight = weight or 0
	
	input:AddOutputSynapse(obj)
	output:AddInputSynapse(obj)
	
	return obj
end

function Synapse:call() --Fire synapse
	self.Output()
end

function Synapse:GetValue()
	return self.Input:GetValue()
end

function Synapse:SetInputNode(inputNode)
	Base.Assert(inputNode,"Node")
	
	self.Input = inputNode
end

function Synapse:GetInputNode()
	return self.Input
end

function Synapse:SetOutputNode(outputNode)
	Base.Assert(outputNode,"Node")
	
	self.Output = outputNode
end

function Synapse:GetOutputNode()
	return self.Output
end

function Synapse:GetWeight()
	return self.Weight
end

function Synapse:AddWeight(weightDelta)
	--Base.Assert(weightDelta,"number")
	
	self.Weight += weightDelta
end

function Synapse:SetWeight(weight)
	--Base.Assert(weight,"number")
	
	self.Weight = weight
end

return Synapse