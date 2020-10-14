--[[
	Advanced OOP Implementation v1.0, August 24th 2020
	Designed and written by Kironte (49703460)
	
	For full documentation and description of the module, visit it's Devforum article here:

]]


---VV DO NOT CHANGE ANYTHING BELOW UNLESS YOU KNOW WHAT YOU'RE DOING! VV---

local httpS = game:GetService("HttpService")

--Constants--
local TABLE_PREFIX = "^&^"
local PRIM_OBJECT_PREFIX = "&^&"
local SUPPORTED_PRIM_OBJECTS = {
	"UDim","UDim2",
	"Vector2","Vector2int16",
	"Vector3","Vector3int16",
	"CFrame"
}
------------- 

local default = {}
local Base = {}

default.__index = default

function default:toString()
	return self.NAME
end

function default:equals(object)
	return self.GUID == object.GUID
end

function default:isA(className)
	local currentParent = self
	for i=1, 20 do
		if currentParent.CLASS_NAME == className then
			return true
		end
		if currentParent.PARENT then
			currentParent = currentParent.PARENT
		else
			return false
		end
	end
	warn("Too many inheritances!")
	return false
end

function default:GetID()
	return self.GUID
end

function default:GetName()
	return self.NAME
end

function default:SetName(name)
	self.NAME = name
end

function default:super(...)
	local child = self.PARENT.new(...)
	setmetatable(child,self)
	return child
end

function default:make()
	local child = {}
	setmetatable(child,self)
	child.GUID = httpS:GenerateGUID(false)..httpS:GenerateGUID(false)
	return child
end

function default:GetCleanObj() --Used for getting an object while bypassing all .new() constructors
	local child
	if self.PARENT then
		child = self.PARENT:GetCleanObj()
	else
		child = self:make()
	end
	
	setmetatable(child,self)
	return child
end

function default:Destroy()
	self.PARENT = nil
	self = nil
end

function default:Clone(objectsToUse)
	return Base.DeSerialize(self:Serialize(),objectsToUse)
end

function default:Serialize(returnJson,keyList,typeOfList,compressPrimObjects,ignoreWarnings)
	return Base.Serialize(self,returnJson,keyList,typeOfList,compressPrimObjects,ignoreWarnings)
end

function default:DeSerialize(serial,objectsToUse)
	
	local reConstructed = {}
	
	if type(serial) == "string" then
		serial = httpS:JSONDecode(serial)
	end
	-----------------------------------------
	objectsToUse = objectsToUse or {}
	if self and self.CLASS_NAME and not objectsToUse[self.CLASS_NAME] then
		objectsToUse[self.CLASS_NAME] = self
	end
	
	local function reConstruct(tab)
		local object = tab
		if tab.CLASS_NAME then
			--print(tab.CLASS_NAME)
			if not objectsToUse[tab.CLASS_NAME] then
				if objectsToUse._Package then
					local foundClass
					for _,v in pairs(objectsToUse._Package:GetDescendants()) do
						if v.Name == tab.CLASS_NAME and v:IsA("ModuleScript") then
							objectsToUse[tab.CLASS_NAME] = require(v) 
							foundClass = v 
							break
						end
					end
					
					if not foundClass then
						error("Missing '"..serial.CLASS_NAME.."' class! Did you forget to provide it?")
					end
				else
					error("Missing '"..serial.CLASS_NAME.."' class! Did you forget to provide it or the Package?")
				end
			end 
			
			object = objectsToUse[tab.CLASS_NAME]:GetCleanObj()
		end
		
		for k,v in pairs(tab) do
			object[k] = v
		end
			
		return object
	end
	
	for k,v in pairs(serial) do
		serial[k] = reConstruct(v)
	end
	
	local function referenceReConstruct(tab)
		for k,v in pairs(tab) do
			if type(v) == "string" then
				if string.find(v,TABLE_PREFIX,1,true) then
					local prefixBounds = {string.find(v,TABLE_PREFIX,1,true)}
					local numId = tonumber(string.sub(v,prefixBounds[2]+1))
					
					tab[k] = serial[numId]
				elseif string.find(v,PRIM_OBJECT_PREFIX,1,true) then
					tab[k] = Base.DeSerializePrimitiveObject(v)
				end
			end
		end
	end
	
	for k,v in pairs(serial) do
		referenceReConstruct(v)
	end
	
	return serial[1]
end

----------------------------------

function Base.new(className,parent)
	if parent then
		return Base.newExtends(className,parent)
	end
	
	local newObj = {}
	newObj.__index = newObj
	setmetatable(newObj,default)
	
	newObj.CLASS_NAME = className
	newObj.NAME = className
	
	
	newObj.__call = function(obj,...)
		return obj:call(...)
	end
	newObj.__tostring = function(obj)
		return obj:toString()
	end
	newObj.__add = function(obj,value)
		return obj:add(value)
	end
	newObj.__sub = function(obj,value)
		return obj:subtract(value)
	end
	newObj.__mul = function(obj,value)
		return obj:multiply(value)
	end
	newObj.__div = function(obj,value)
		return obj:divide(value)
	end
	newObj.__pow = function(obj,value)
		return obj:power(value)
	end
	newObj.__eq = function(obj,value)
		return obj:equals(value)
	end
	newObj.__len = function(obj,value)
		return obj:length(value)
	end
	
	return newObj
end

function Base.newExtends(className,parent)
	local newObj = Base.new(className)
	newObj.PARENT = parent
	
	setmetatable(newObj,parent)
	return newObj
end

function Base.find(tab,object)
	for key,value in pairs(tab) do
		if type(value) == "table" and value.GUID == object.GUID then
			return key
		end
	end
	return false
end

function Base.findByName(tab,name)
	for key,value in pairs(tab) do
		if type(value) == "table" and value.NAME == name then
			return value,key
		end
	end
	return false
end

function Base.type(object)
	if typeof(object) ~= "table" then
		return typeof(object)
	end
	if object.CLASS_NAME then
		return object.CLASS_NAME,true --True lets you know that this is a custom object
	end
	for key,_ in pairs(object) do
		if typeof(key) == "string" then
			return "dictionary"
		end
	end
	return "array"
end

function Base.copyTable(dict) --Do not use for metatables!
	local newTable = {}
	for k,v in pairs(dict) do
		if type(v) == "table" then
			newTable[k] = Base.copyTable(v)
		else
			newTable[k] = v
		end
	end
	return newTable
end

function Base.SerializePrimitiveObject(obj,compress)
	local typeOfObj = typeof(obj)
	local compressFunctions = {
		UDim = function(obj)
			return PRIM_OBJECT_PREFIX..typeOfObj.."1"..string.pack("dd",obj.Scale,obj.Offset)
		end;
		UDim2 = function(obj)
			return PRIM_OBJECT_PREFIX..typeOfObj.."1"..string.pack("dddd",obj.X.Scale,obj.X.Offset,obj.Y.Scale,obj.Y.Offset)
		end;
		Vector2 = function(obj)
			return PRIM_OBJECT_PREFIX..typeOfObj.."1"..string.pack("dd",obj.X,obj.Y)
		end;
		Vector2int16 = function(obj)
			return PRIM_OBJECT_PREFIX..typeOfObj.."1"..string.pack("hh",obj.X,obj.Y)
		end;
		Vector3 = function(obj)
			return PRIM_OBJECT_PREFIX..typeOfObj.."1"..string.pack("ddd",obj.X,obj.Y,obj.Z)
		end;
		Vector3int16 = function(obj)
			return PRIM_OBJECT_PREFIX..typeOfObj.."1"..string.pack("hhh",obj.X,obj.Y,obj.Z)
		end;
		CFrame = function(obj)
			return PRIM_OBJECT_PREFIX..typeOfObj.."1"..string.pack("dddddddddddd",obj:GetComponents())
		end;
	}
	local functions = {
		UDim = function(obj)
			return PRIM_OBJECT_PREFIX..typeOfObj.."0"..obj.Scale..","..obj.Offset
		end;
		UDim2 = function(obj)
			return PRIM_OBJECT_PREFIX..typeOfObj.."0"..obj.X.Scale..","..obj.X.Offset..","..obj.Y.Scale..","..obj.Y.Offset
		end;
		Vector2 = function(obj)
			return PRIM_OBJECT_PREFIX..typeOfObj.."0"..obj.X..","..obj.Y
		end;
		Vector2int16 = function(obj)
			return PRIM_OBJECT_PREFIX..typeOfObj.."0"..obj.X..","..obj.Y
		end;
		Vector3 = function(obj)
			return PRIM_OBJECT_PREFIX..typeOfObj.."0"..obj.X..","..obj.Y..","..obj.Z
		end;
		Vector3int16 = function(obj)
			return PRIM_OBJECT_PREFIX..typeOfObj.."0"..obj.X..","..obj.Y..","..obj.Z
		end;
		CFrame = function(obj)
			return PRIM_OBJECT_PREFIX..typeOfObj.."0"..table.concat({obj:GetComponents()},",")
		end;
	}
	
	local func = functions[typeOfObj]
	if compress then
		func = compressFunctions[typeOfObj]
	end
	if func then
		return func(obj)
	end
end

function Base.DeSerializePrimitiveObject(serial)
	--Cutting away first prefix
	local prefixBounds = {string.find(serial,PRIM_OBJECT_PREFIX,1,true)}
	serial = string.sub(serial,prefixBounds[2]+1)
	
	local typeOfObj
	for _,v in pairs(SUPPORTED_PRIM_OBJECTS) do
		local find = {string.find(serial,v,1,true)}
		if find[1] then
			typeOfObj = v
			serial = string.sub(serial,find[2]+1)
			break
		end
	end
	
	local compressed = string.sub(serial,1,1)
	serial = string.sub(serial,2)
	if compressed == 1 then
		compressed = true
	else
		compressed = false
	end
	
	local compressFunctions = {
		UDim = function(serial)
			local data = {string.unpack("dd",serial)}
			table.remove(data,#data)
			
			return UDim.new(unpack(data))
		end;
		UDim2 = function(serial)
			local data = {string.unpack("dddd",serial)}
			table.remove(data,#data)
			
			return UDim2.new(unpack(data))
		end;
		Vector2 = function(serial)
			local data = {string.unpack("dd",serial)}
			table.remove(data,#data)
			
			return Vector2.new(unpack(data))
		end;
		Vector2int16 = function(serial)
			local data = {string.unpack("hh",serial)}
			table.remove(data,#data)
			
			return Vector2int16.new(unpack(data))
		end;
		Vector3 = function(serial)
			local data = {string.unpack("ddd",serial)}
			table.remove(data,#data)
			
			return Vector3.new(unpack(data))
		end;
		Vector3int16 = function(serial)
			local data = {string.unpack("hhh",serial)}
			table.remove(data,#data)
			
			return Vector3int16.new(unpack(data))
		end;
		CFrame = function(serial)
			local data = {string.unpack("dddddddddddd",serial)}
			table.remove(data,#data)
			
			return CFrame.new(unpack(data))
		end;
	}
	local functions = {
		UDim = function(serial)
			local data = string.split(serial,",")
			
			return UDim.new(unpack(data))
		end;
		UDim2 = function(serial)
			local data = string.split(serial,",")
			
			return UDim2.new(unpack(data))
		end;
		Vector2 = function(serial)
			local data = string.split(serial,",")
			
			return Vector2.new(unpack(data))
		end;
		Vector2int16 = function(serial)
			local data = string.split(serial,",")
			
			return Vector2int16.new(unpack(data))
		end;
		Vector3 = function(serial)
			local data = string.split(serial,",")
			
			return Vector3.new(unpack(data))
		end;
		Vector3int16 = function(serial)
			local data = string.split(serial,",")
			
			return Vector3int16.new(unpack(data))
		end;
		CFrame = function(serial)
			local data = string.split(serial,",")
			
			return CFrame.new(unpack(data))
		end;
	}
	
	local func = functions[typeOfObj]
	if compressed then
		func = compressFunctions[typeOfObj]
	end
	if func then
		return func(serial)
	end
end

function Base.Serialize(object,returnJson,keyList,typeOfList,compressPrimObjects,ignoreWarnings)
	local serial = {}
	
	local usingPrimObjects = false
	
	local seenTables = {}
	local seenTableCounter = 1
	
	local function filterAndDecycle(tab)
		local output = {}
		local index = tab
		local finalIndex = false
		
		while not finalIndex do
			for k,v in pairs(index) do
				if string.sub(k,1,2) ~= "__" and type(v) ~= "function" and k ~= "GUID" and k ~= "PARENT" then
					
					if k ~= "CLASS_NAME" then --Cannot ignore the classname
						if typeOfList == 0 or typeOfList == "Blacklist" then
							if table.find(keyList,k) then
								continue
							end
						elseif typeOfList == 1 or typeOfList == "Whitelist" then
							if not table.find(keyList,k) then
								continue
							end
						end
					end
					
					if output[k] then --If we have found all unique keys
						finalIndex = true
						break
					end
					
					if type(v) == "table" then
						local tableId = tostring(v)
						if v.GUID then
							tableId = v.GUID
						end
						
						if not seenTables[tableId] then
							seenTables[tableId] = {NumId = seenTableCounter}
							seenTableCounter += 1
							
							seenTables[tableId].Table = filterAndDecycle(v)
						end
						output[k] = TABLE_PREFIX..seenTables[tableId].NumId
					else
						if table.find(SUPPORTED_PRIM_OBJECTS,typeof(v)) then
							usingPrimObjects = true
							output[k] = Base.SerializePrimitiveObject(v,compressPrimObjects)
						else
							output[k] = v
						end
					end
					
				end
			end
			if not finalIndex then
				if index.__index then
					index = index.__index
				else
					break
				end
			end
		end
		
		return output
	end
	serial = filterAndDecycle({object})
	
	local tablesArray = {}
	for k,v in pairs(seenTables) do
		tablesArray[v.NumId] = v.Table 
	end
	
	serial = tablesArray
	
	if usingPrimObjects and compressPrimObjects and not ignoreWarnings then
		warn("WARNING! Compressing primitive objects makes this serialization impossible to convert to JSON or use it in a Datastore!" 
		)
	end
	
	if returnJson then
		if compressPrimObjects then
			warn("Cannot turn to JSON. Returning serial table that is not in JSON.")
		end
		return httpS:JSONEncode(serial)
	end
	return serial
end

function Base.DeSerialize(serial,objectsToUse)
	return default.DeSerialize(nil,serial,objectsToUse)
end

function Base.Clone(tab,objectsToUse)
	return default.Clone(tab,objectsToUse)
end

function Base.DistinctRandIntArray(min,max,amount)
	if max - min + 1 < amount then
		error("Given number range is too small for "..amount.." distinct numbers!")
	end
	
	local range = {}
	for i=min, max do
		table.insert(range,i)
	end
	
	local output = {}
	for i=1, amount do
		local rangeIndex = math.random(1,#range)
		local num = range[rangeIndex]
		table.remove(range,rangeIndex)
		table.insert(output,num)
	end
	
	return output
end

Base.TypeCheck = true

function Base.SetTypeChecking(bool)
	Base.TypeCheck = bool
end

function Base.Assert(...)
	--Type checking
	
	if Base.TypeCheck then
		local args = {...}
		
		for i=1, #args, 2 do
			local argNum = (i-1)/2 + 1
			local var = args[i]
			local typ,optional = unpack(string.split(args[i+1]," "))
			optional = optional == "OPT"
			
			local errorMess = debug.traceback()
			local actualType,customObject = Base.type(var)
			
			if var == nil and not optional then
				errorMess = "Argument #"..argNum.." missing or nil"
				error(errorMess)
			elseif var == nil and optional then
				continue
			end
			
			if customObject then
				if not var:isA(typ) then
					errorMess = "Invalid argument #"..argNum.." ("..typ.." expected, got "..actualType..")"
					error(errorMess)
				end
			else
				if actualType ~= typ then
					errorMess = "Invalid argument #"..argNum.." ("..typ.." expected, got "..actualType..")"
					error(errorMess)
				end
			end
		end
	end
end

return Base