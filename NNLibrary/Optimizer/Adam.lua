--[[
Designed and written in it's entirety by Kironte (roblox.com/users/49703460/profile).
Made for the Roblox Neural Network Library.
For documentation and the open source license, refer to: github.com/Kironte/Roblox-Neural-Network-Library

Last updated 10/13/2020
]]

local Package = script:FindFirstAncestorOfClass("Folder")
local Base = require(Package.BaseRedirect)

local Optimizer = require(Package.Optimizer)

--local Adam = Base.new("Adam")
local Adam = Base.newExtends("Adam",Optimizer)

function Adam.new(decayConstant1,decayConstant2,epsilon)
	--local obj = Adam:make()
	local obj = Adam:super()
	
	obj.Epsilon = epsilon or 10^(-7)
	obj.DecayConstant1 = decayConstant1 or 0.9
	obj.DecayConstant2 = decayConstant2 or 0.999
	obj.FirstMoment = {}
	obj.SecondMoment = {}
	
	return obj
end

function Adam:Calculate(node,inputValue,gradient,id)
	local network = self.Network
	local backProp = network:GetBackPropagator()
	
	local learningRate = node:GetLearningRate()
	local gradient = gradient or backProp:GetGradient(node)
	inputValue = inputValue or 1
	id = id or node:GetID()
	--Initialize
	self.FirstMoment[id] = self.FirstMoment[id] or {Moment = 0, Time = 1}
	self.SecondMoment[id] = self.SecondMoment[id] or {Moment = 0}
	--Calculate new moments
	local timeStep = self.FirstMoment[id].Time
	self.FirstMoment[id].Moment = (1 - self.DecayConstant1) * gradient + self.DecayConstant1 * self.FirstMoment[id].Moment
	self.SecondMoment[id].Moment = (1 - self.DecayConstant2) * gradient^2 + self.DecayConstant2 * self.SecondMoment[id].Moment
	local firstMoment,secondMoment = self.FirstMoment[id].Moment,self.SecondMoment[id].Moment
	--Compute biased moments
	local biasedFirstMoment = firstMoment / (1 - self.DecayConstant1^timeStep)
	local biasedSecondMoment = secondMoment / (1 - self.DecayConstant2^timeStep)
	
	local newChange = -learningRate * biasedFirstMoment / (math.sqrt(biasedSecondMoment) + self.Epsilon) * inputValue 
	
	self.FirstMoment[id].Time += 1
	
	
	return newChange
end

return Adam