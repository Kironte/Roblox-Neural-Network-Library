local Package = script:FindFirstAncestorOfClass("Folder")

local baseModule = Package.Base
--^^ Simply adjust the variable so it matches the Base's location. ^^

return require(baseModule)
