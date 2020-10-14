--[[
Designed and written in it's entirety by Kironte (roblox.com/users/49703460/profile).
Made for the Roblox Neural Network Library.
For documentation and the open source license, refer to: github.com/Kironte/Roblox-Neural-Network-Library

Last updated 10/13/2020
]]

local Package = script:FindFirstAncestorOfClass("Folder")
local Base = require(Package.BaseRedirect)

local Optimizer = Base.new("Optimizer")
--local Optimizer = Base.newExtends("Optimizer",?)

function Optimizer.new()
	local obj = Optimizer:make()
	--local obj = Optimizer:super()
	
	obj.Network = nil
	
	return obj
end

function Optimizer:SetNetwork(network)
	--Base.Assert(network,"NeuralNetwork")
	
	self.Network = network
end

return Optimizer