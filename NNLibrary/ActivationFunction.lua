--[[
Designed and written in it's entirety by Kironte (roblox.com/users/49703460/profile).
Made for the Roblox Neural Network Library.
For documentation and the open source license, refer to: github.com/Kironte/Roblox-Neural-Network-Library

Last updated 10/13/2020
]]

local Package = script:FindFirstAncestorOfClass("Folder")
local Base = require(Package.BaseRedirect)

local ActivationFunction = Base.new("ActivationFunction")
--local ActivationFunction = Base.newExtends(?)

function ActivationFunction.new(activName)
	Base.Assert(activName,"string")
	
	local obj = ActivationFunction:make()
	--local obj = ActivationFunction:super()
	
	obj.Activator = activName or "Binary"
	
	return obj
end

function ActivationFunction:Calculate(x,deriv)
	--Base.Assert(x,"number",deriv,"boolean OPT")
	
	local activator = self.Activator
	
	if activator == "Identity" then  
		if deriv then
			return 1
		end
		return x
	end
	
	if activator == "Binary" then 
		if deriv then
			return 0
		end
		if x >= 0 then
			return 1
		end
		return 0
	end
	
	if activator == "Sigmoid" then
		if deriv then
			return (1/(1+2.718281828459^(-x)))*(1-(1/(1+2.718281828459^(-x))))
		end
		return 1/(1+2.718281828459^(-x))
	end
	
	if activator == "Tanh" then				
		if deriv then
			return 1-math.tanh(x)^2
		end
		return math.tanh(x)
	end
	
	if activator == "ArcTan" then			
		if deriv then
			return 1/(x^2+1)
		end
		return math.atan(x)
	end
	
	if activator == "Sin" then 
		if deriv then
			return math.cos(x)
		end
		return math.sin(x)
	end
	
	if activator == "Sinc" then 
		if deriv then
			if x == 0 then
				return 0
			end
			return math.cos(x)/x-math.sin(x)/x^2
		end
		if x == 0 then
			return 1
		end
		return math.sin(x)/x
	end
	
	if activator == "ArSinh" then 
		if deriv then
			return 1/(x^2+1)^0.5
		end
		return math.log(x+(x^2+1)^0.5)
	end
	
	if activator == "SoftPlus" then 
		if deriv then
			return 1/(1+2.718281828459^(-x))
		end
		return math.log(1+2.718281828459^x)
	end
	
	if activator == "BentIdentity" then 
		if deriv then
			return x*(2*(x^2+1)^0.5)+1
		end
		return ((x^2+1)^0.5-1)/2+x
	end
	
	if activator == "ReLU" then			
		if deriv then
			if x>0 then
				return 1
			elseif x == 0 then
				return 0.5
			end
			return 0
		end
		return math.max(0,x)
	end
	
	if activator == "SoftReLU" then			
		if deriv then
			return 1/(1+2.718281828459^(-x))
		end
		return math.log(1+2.718281828459^(x))
	end
	
	if activator == "LeakyReLU" then			
		if deriv then
			if x >= 0 then
				return 1
			end
			return 0.1
		end
		return math.max(0.1*x,x)
	end
	
	if activator == "Swish" then
		if deriv then
			return (2.718281828459^(-x)*(x+1)+1)/(1/(1+2.718281828459^(-x)))^2
		end
		return x*(1/(1+2.718281828459^(-x)))
	end
	
	if activator == "ElliotSign" then
		if deriv then
			return 1/(1+math.abs(x))^2
		end
		return x/(1+math.abs(x))
	end
	
	if activator == "Gaussian" then 
		if deriv then
			return -2*x*2.718281828459^(-x^2)
		end
		return 2.718281828459^(-x^2)
	end
	
	if activator == "SQ-RBF" then   --god why have you forsaken us
		if deriv then
			if math.abs(x)<=1 then 
				return -x
			end
			if 1<=math.abs(x) and math.abs(x)<2 then
				return 2-x
			end
			return 0
		end
		if math.abs(x)<=1 then 
			return 1-x^2/2
		end
		if 1<=math.abs(x) and math.abs(x)<2 then
			return 2-(2-x^2)/2
		end
		return 0 
	end
	
	error("Activator unsupported. Please refer to documentation for supported activation functions.")
end

function ActivationFunction:GetValue(x)
	return self:Calculate(x)
end

function ActivationFunction:GetDeriv(x)
	return self:Calculate(x,true)
end

function ActivationFunction:SetActivator(activName)
	self.Activator = activName
end

function ActivationFunction:GetActivator()
	return self.Activator
end

return ActivationFunction