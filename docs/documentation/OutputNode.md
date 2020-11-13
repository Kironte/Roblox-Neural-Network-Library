# **OutputNode Class**
This class is responsible for managing output nodes. These nodes are effectively the same as hidden nodes expect that their output values are specifically saved as the network's output values. They are always on the last layer.

<div class=functionDoc>
OutputNode .new(string activName, string name, number bias, number learningRate)
Creates and returns the OutputNode with the given activation function, name, bias, and learning rate.
</div>

<div class=functionDoc>
void :()
Fires the OutputNode and saves it's output value to the network's output values.
<br><br>
This function is fired when the OutputNode object is called, such as:

```lua
outputNode:()
```
</div>

<div class=functionDoc>
void :SetDirectOutput(bool bool)
Sets whether or not the OutputNode should use it's activation function and bias or not. This is useful when you want to only use the hidden nodes and don't want the output nodes to interfere.
</div>

## Inherited from <code class=funcName>Node</code>:
<i>Only unchanged and unmodified functions are listed below.</i>

<div class=functionDoc>
number :GetValue()
Returns the node's output value if calculated. If not, calculates it and returns the new output value.
</div>

<div class=functionDoc>
void :SetValue(number value)
Sets the node's output value to !value!.
</div>

<div class=functionDoc>
number :CalculateValue()
Calculates and sets the node's new output value while also returning it.
</div>

<div class=functionDoc>
void :ClearValue()
Resets the node's output value.
</div>

<div class=functionDoc>
void :AddInputSynapse(Synapse inputSynapse)
Adds the synapse !inputSynapse! as an input synapse.
</div>

<div class=functionDoc>
void :AddOutputSynapse(Synapse outputSynapse)
Adds the synapse !outputSynapse! as an output synapse.
</div>

<div class=functionDoc>
array :GetInputSynapses()
Returns the input synapses.
</div>

<div class=functionDoc>
array :GetOutputSynapses()
Returns the output synapses.
</div>

<div class=functionDoc>
void :RemoveInputSynapse(Synapse inputSynapse)
Removes the input synapse !inputSynapse!.
</div>

<div class=functionDoc>
void :RemoveOutputSynapse(Synapse outputSynapse)
Removes the output synapse !inputSynapse!.
</div>

<div class=functionDoc>
void :ClearInputSynapses()
Removes all input synapses.
</div>

<div class=functionDoc>
void :ClearOutputSynapses()
Removes all output synapses.
</div>

<div class=functionDoc>
void :SetBias(number bias)
Sets the node's bias to !bias!.
</div>

<div class=functionDoc>
number :GetBias()
Returns the node's bias.
</div>

<div class=functionDoc>
void :AddBias(number biasDelta)
Adds !biasDelta! to the noder's bias.
</div>

<div class=functionDoc>
void :SetLearningRate(number learningRate)
Sets the node's learning rate to !learningRate!.
</div>

<div class=functionDoc>
number :GetLearningRate()
Returns the node's learning rate.
</div>

<div class=functionDoc>
ActivationFunction :GetActivationFunction()
Returns the node's ActivationFunction object.
</div>

<div class=functionDoc>
void :AddRandomNoise(number min, number max)
Adds random noise to the node's bias and input weights with the given minimum !min! and maximum !max!.
</div>