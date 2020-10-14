--[[
Designed and written in it's entirety by Kironte (roblox.com/users/49703460/profile).
Made for the Roblox Neural Network Library.
For documentation and the open source license, refer to: github.com/Kironte/Roblox-Neural-Network-Library

Last updated 10/13/2020
]]

local Package = script:FindFirstAncestorOfClass("Folder")
local Base = require(Package.BaseRedirect)

local NodeLayer = Base.new("NodeLayer")
--local NodeLayer = Base.newExtends("NodeLayer",?)

function NodeLayer.new()
	local obj = NodeLayer:make()
	--local obj = NodeLayer:super()
	
	obj.Nodes = {}
	
	return obj
end

function NodeLayer:AddNodes(...)
	local nodes = {...}
	for _,node in pairs(nodes) do
		self.Nodes[#self.Nodes+1] = node
	end
end

function NodeLayer:GetNodes()
	return self.Nodes
end

return NodeLayer