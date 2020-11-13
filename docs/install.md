# Installation Procedure

The Github page is not meant to install the library, hence why I am not using Rojo.<br>
To install this library and use it yourself, you need to grab it from the catalog [here](https://www.roblox.com/library/5951897165/Roblox-Neural-Network-Library-V2-0).<br>
The package should be in either ReplicatedStorage, or ServerStorage, depending on where you intend to use it. If you're not sure, just place it in ReplicatedStorage in some folder where you store your 3rd party modules.<br><br>
And... thats it! This folder contains every module necessary for the library to work, including the OOP implementation called "Base". In order to use it in a script, you need to `require()` the Base module along with any classes you plan to use, like the neural network classes or the optimizer classes. For most packages, BaseRedirect is used by the package to locate the Base module, allowing you to move it's location and only have to change a single line of code. For this package, the Base is in the same folder.<br>
```lua
local repStorage = game:GetService("ReplicatedStorage")

--Try to keep the variable names equal to the class's name.
local Package = repStorage.NNLibrary
local Base = require(Package.BaseRedirect)
local FeedforwardNetwork = require(Package.NeuralNetwork.FeedforwardNetwork)
local ParamEvo = require(Package.GeneticAlgorithm.ParamEvo)

--Your machine learning code goes here. See example code (next page) for more info!
```