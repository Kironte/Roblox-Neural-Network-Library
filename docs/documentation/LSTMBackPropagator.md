# **LSTMBackPropagator Class**
This class is responsible for backpropagating the associated LSTM neural network according to it's set optimizer. It is heavily modified and in places completely changed in order to work with LSTM systems.

<div class=functionDoc>
LSTMBackPropagator .new(NeuralNetwork neuralNetwork)
Creates and returns the LSTMBackPropagator with the given !neuralNetwork!.
</div>

<div class=functionDoc>
void :Reset()
Resets all saved gradients and costs.
</div>

!!! caution
    :CalculateCosts() must be used at least once before :Learn()
<div class=functionDoc>
void :Learn()
Uses the calculated costs up to this point and the associated network's optimizer to backpropagate the network parameters. :Reset() is called when finished.
</div>

<div class=functionDoc>
Tuple :CalculateCost(dictionary inputValues,dictionary correctOutputValues)
Calculates the cost values for each node when the network is ran with !inputValues! and the output is compared to the given !correctOutputValues!. This function can be called multiple times before :Learn() as it will simply average the cost values over time.//
dictionary CostValues, dictionary outputValues
</div>

## Inherited from <code class=funcName>BackPropagator</code>:
<i>Only unchanged and unmodified functions are listed below.</i>

<div class=functionDoc>
dictionary :GetCost()
Returns the cost values for the BackPropagator. See :Reset()'s code if you want to know the structure as it is for internal use.//
{Outputs = dictionary, Activations = dictionary}
</div>

<div class=functionDoc>
number :GetTotalCost()
Takes the square cost of every output node and adds it all up to calculate the total cost number and returns it. This is the prime indicator for how well the network is training with backpropagation.
</div>