--[[
Designed and written in it's entirety by Kironte (roblox.com/users/49703460/profile).
Made for the Roblox Neural Network Library.
For documentation and the open source license, refer to: github.com/Kironte/Roblox-Neural-Network-Library

Last updated 10/13/2020
]]

local Package = script:FindFirstAncestorOfClass("Folder")
local Base = require(Package.BaseRedirect)

local Optimizer = require(Package.Optimizer)

--local StochasticGradientDescent = Base.new("StochasticGradientDescent")
local StochasticGradientDescent = Base.newExtends("StochasticGradientDescent",Optimizer)

function StochasticGradientDescent.new()
	--local obj = StochasticGradientDescent:make()
	local obj = StochasticGradientDescent:super()
	
	return obj
end

function StochasticGradientDescent:Calculate(node,inputValue,gradient)
	local network = self.Network
	local backProp = network:GetBackPropagator()
	
	local learningRate = node:GetLearningRate()
	local gradient = gradient or backProp:GetGradient(node)
	inputValue = inputValue or 1
	
	return -learningRate * gradient * inputValue
end

return StochasticGradientDescent