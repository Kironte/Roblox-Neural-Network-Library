--[[
Designed and written in it's entirety by Kironte (roblox.com/users/49703460/profile).
Made for the Roblox Neural Network Library.
For documentation and the open source license, refer to: github.com/Kironte/Roblox-Neural-Network-Library

Last updated 10/13/2020
]]

local Package = script:FindFirstAncestorOfClass("Folder")
local Base = require(Package.BaseRedirect)

local Optimizer = require(Package.Optimizer)

--local AdaGrad = Base.new("AdaGrad")
local AdaGrad = Base.newExtends("AdaGrad",Optimizer)

function AdaGrad.new(epsilon)
	
	--local obj = AdaGrad:make()
	local obj = AdaGrad:super()
	
	obj.Epsilon = epsilon or 10^(-8)
	obj.GradientSum = {}
	
	return obj
end

function AdaGrad:Calculate(node,inputValue,gradient,id)
	
	local network = self.Network
	local backProp = network:GetBackPropagator()
	
	local learningRate = node:GetLearningRate()
	local gradient = gradient or backProp:GetGradient(node)
	inputValue = inputValue or 1
	id = id or node:GetID()
	
	self.GradientSum[id] = self.GradientSum[id] or 0
	local sum = self.GradientSum[id]
	sum += self.Epsilon 
	sum = math.sqrt(sum)
	
	local newChange = -learningRate/sum * gradient * inputValue 
	
	self.GradientSum[id] += gradient^2
	
	return newChange
end

return AdaGrad