--[[
Designed and written in it's entirety by Kironte (roblox.com/users/49703460/profile).
Made for the Roblox Neural Network Library.
For documentation and the open source license, refer to: github.com/Kironte/Roblox-Neural-Network-Library

Last updated 10/13/2020
]]

local Package = script:FindFirstAncestorOfClass("Folder")
local Base = require(Package.BaseRedirect)

local Optimizer = require(Package.Optimizer)

--local Momentum = Base.new("Momentum")
local Momentum = Base.newExtends("Momentum",Optimizer)

function Momentum.new(momentumConstant)
	--local obj = Momentum:make()
	local obj = Momentum:super()
	
	obj.MomentumConstant = 0.1
	obj.LastChange = {}
	
	return obj
end

function Momentum:Calculate(node,inputValue,gradient,id)
	local network = self.Network
	local backProp = network:GetBackPropagator()
	
	local learningRate = node:GetLearningRate()
	local gradient = gradient or backProp:GetGradient(node)
	inputValue = inputValue or 1
	id = id or node:GetID()
	
	local lastChange = self.LastChange[id] or 0
	local newChange = -learningRate * gradient * inputValue + self.MomentumConstant * lastChange
	self.LastChange[id] = newChange
	
	return newChange
end

return Momentum