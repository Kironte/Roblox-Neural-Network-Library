# **LSTMNode Class**
This class is responsible for managing all LSTM nodes. The difference between normal hidden nodes and LSTM nodes is the existance of a connection between every LSTM node in the same layer, known as the previous/next LSTM nodes. Each LSTM node also has 4 gate networks necessary for it's function, making it considerably larger than normal nodes.

<div class=functionDoc>
LSTMNode .new(string activName, number bias, number learningRate, LSTMNode prevLSTMNode = nil, LSTMNode nextLSTMNode = nil, number numOfInputs=1)
Creates and returns the LSTMNode with the given activation function, bias, learning rate, previous/next LSTM nodes (if they exist), and number of inputs. 
</div>

<div class=functionDoc>
number :CalculateValue()
Calculates the node's output value and updates the cost data.
</div>

<div class=functionDoc>
void :ClearValue()
Resets the node's output value and gate networks.
</div>

<div class=functionDoc>
number :GetCellState()
Returns the cell state.
</div>

<div class=functionDoc>
number :GetPrevCellState()
Returns the cell state of the previous LSTM node if it exists.
</div>

<div class=functionDoc>
number :GetPrevHiddenState()
Returns the hidden state of the previous LSTM node if it exists.
</div>

<div class=functionDoc>
void :SetCellState(number cellState)
Sets the cell state to !cellstate!.
</div>

<div class=functionDoc>
LSTMNode :GetNextLSTMNode()
Returns the next LSTM node if it exists.
</div>

<div class=functionDoc>
void :SetNextLSTMNode(LSTMNode nextLSTMNode)
Sets the next LSTM node to !nextLSTMNode!.
</div>

<div class=functionDoc>
LSTMNode :GetPrevLSTMNode()
Returns the previous LSTM node if it exists.
</div>

<div class=functionDoc>
void :SetPrevLSTMNode(LSTMNode prevLSTMNode)
Sets the previous LSTM node to !prevLSTMNode!.
</div>

<div class=functionDoc>
ActivationFunction :GetActivationFunction()
Returns the node's Tanh ActivationFunction.
</div>

<div class=functionDoc>
void :AddRandomNoise(number min, number max)
Adds a random noise with the minimum !min! and maximum !max! to the gate networks' parameters in the node.
</div>

## Inherited from <code class=funcName>Node</code>:
<i>Only unchanged and unmodified functions are listed below.</i>

<div class=functionDoc>
void :()
Fires the node and fires any node that is at it's output, potentially causing a chain reaction.
<br><br>
This function is fired when the Node object is called, such as:

```lua
node:()
```
</div>

<div class=functionDoc>
number :GetValue()
Returns the node's output value if calculated. If not, calculates it and returns the new output value.
</div>

<div class=functionDoc>
void :SetValue(number value)
Sets the node's output value to !value!.
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