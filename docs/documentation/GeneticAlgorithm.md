# **Abstract GeneticAlgorithm Class**
This class is responsible for managing a set population of neural networks and breeding them in an efficient manner in order to create better performing networks while following the user's given customizations. <br>
This class is abstract and cannot be used directly. 

<div class=functionDoc>
abstract GeneticAlgorithm .new(NeuralNetwork neuralNetwork, number popSize, dictionary geneticSettings)
Creates and returns the GeneticAlgorithm with the given template !neuralNetwork!, population size as !popSize!, and settings as !geneticSettings!. The settings determine how the algorithm works and is open to customization. 
The available setting parameters and their default values are below.

```lua
local geneticSettings = {
    ScoreFunction = nil;
	PostFunction = nil;
    HigherScoreBetter = true;
    
	PercentageToKill = 0.5;
    PercentageOfKilledToRandomlySpare = 0.1;
    
    PercentageOfBestParentToCrossover = 0.6;
    
	PercentageToMutate = 0.1;
	MutateBestNetwork = false;
    PercentageOfCrossedToMutate = 0.5;
    
	NumberOfNodesToMutate = 2;
	ParameterMutateRange = 4;
}
```
</div>

<div class=functionDoc>
array :GetPopulation()
Returns the population of networks in an array.
</div>

<div class=functionDoc>
NeuralNetwork :GetBestNetwork()
Returns the best network in the population.
</div>

<div class=functionDoc>
void :AddNetwork(NeuralNetwork network)
Adds !network! to the population.
</div>

<div class=functionDoc>
void :ProcessGeneration(array scoreArray)
Completely runs a single generation along with the pre-function and post-function.
</div>

<div class=functionDoc>
void :ProcessGenerations(number num)
Completely runs !num! number of generations with :ProcessGeneration().
</div>

<div class=functionDoc>
dictionary :GetInfo()
Returns a dictionary containing basic status info about the population.//
{Generation = number, BestScore = number}
</div>