--[[
Designed and written in it's entirety by Kironte (roblox.com/users/49703460/profile).
Made for the Roblox Neural Network Library.
For documentation and the open source license, refer to: github.com/Kironte/Roblox-Neural-Network-Library

Last updated 10/13/2020
]]

local Package = script:FindFirstAncestorOfClass("Folder")
local Base = require(Package.BaseRedirect)

local Optimizer = require(Package.Optimizer)

--local RMSprop = Base.new("RMSprop")
local RMSprop = Base.newExtends("RMSprop",Optimizer)

function RMSprop.new(decayConstant,epsilon)
	--local obj = RMSprop:make()
	local obj = RMSprop:super()
	
	obj.Epsilon = epsilon or 10^(-8)
	obj.DecayConstant = decayConstant or 0.9
	obj.GradientAve = {}
	
	return obj
end

function RMSprop:Calculate(node,inputValue,gradient,id)
	local network = self.Network
	local backProp = network:GetBackPropagator()
	
	local learningRate = node:GetLearningRate()
	local gradient = gradient or backProp:GetGradient(node)
	inputValue = inputValue or 1
	id = id or node:GetID()
	
	self.GradientAve[id] = self.GradientAve[id] or 0
	local average = self.GradientAve[id]
	average += self.Epsilon 
	average = math.sqrt(average)
	
	local newChange = -learningRate/average * gradient * inputValue 
	
	self.GradientAve[id] += (1 - self.DecayConstant) * gradient^2
	
	return newChange
end

return RMSprop