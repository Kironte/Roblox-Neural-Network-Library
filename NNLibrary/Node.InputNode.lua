--[[
Designed and written in it's entirety by Kironte (roblox.com/users/49703460/profile).
Made for the Roblox Neural Network Library.
For documentation and the open source license, refer to: github.com/Kironte/Roblox-Neural-Network-Library

Last updated 10/13/2020
]]

local Package = script:FindFirstAncestorOfClass("Folder")
local Base = require(Package.BaseRedirect)

local Node = require(Package.Node)

--local InputNode = Base.new("InputNode")
local InputNode = Base.newExtends("InputNode",Node)

function InputNode.new(name)
	--Base.Assert(name,"string")
	
	--local obj = InputNode:make()
	local obj = InputNode:super(nil,0,0)
	
	if name then
		obj:SetName(name)
	end
	obj.Value = 0
	
	return obj
end

function InputNode:call() --Fire node
	for _,outputSyn in pairs(self.Outputs) do
		outputSyn()
	end
end

function InputNode:ClearValue()
	self.Value = 0
end

--Overides

function InputNode:CalculateValue()
end


return InputNode