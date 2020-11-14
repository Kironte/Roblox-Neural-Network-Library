# **GateNetwork Class**
This class is responsible for constructing and managing gate networks. This is a custom type of feedforward network that contains a single hidden node that is specifically managed by several new functions. The point of this type of network is to process values in the simplest way possible while keeping the features of a feedforward network. This is used by LSTM networks. For this documentation, the single hidden node will be called the "gate node".

<div class=functionDoc>
GateNetwork .new(array inputNamesArray, array outputNamesArray, dictionary customSettings)
Creates and returns the GateNetwork according to the given settings as !customSettings!. The settings determine how the network will perform and function and is open to customization.
The available setting parameters and their default values are below.

```lua
local customSettings = {
    Optimizer = StochasticGradientDescent.new();
    SoftMax = false;
    
    HiddenActivationName = "ReLU";
	OutputActivationName = "Sigmoid";
	Bias = 0;
	LearningRate = 0.3;
	RandomizeWeights = true;
}
```
</div>

<div class=functionDoc>
Node :GetNode()
Returns the gate node.
</div>

<div class=functionDoc>
Synapse :GetSynapseWithNodeName(string inputName)
Returns the synapse that connects the input node with the name !inputName! and the gate node.
</div>

<div class=functionDoc>
number :GetWeight(string inputName)
Returns the weight of the synapse that connects the input node with the name !inputName! and the gate node.
</div>

<div class=functionDoc>
void :AddWeight(string inputName, number weightDelta)
Adds !weightDelta! to the weight of the synapse that connects the input node with the name !inputName! and the gate node.
</div>

<div class=functionDoc>
void :SetWeight(string inputName, number weight)
Sets weight of the synapse that connects the input node with the name !inputName! and the gate node to !weight!.
</div>

<div class=functionDoc>
number :GetBias()
Returns the gate node's bias.
</div>

<div class=functionDoc>
void :AddBias(number biasDelta)
Adds !biasDelta! to the gate node's bias.
</div>

<div class=functionDoc>
void :SetBias(number bias)
Sets the gate node's bias to !bias!.
</div>

<div class=functionDoc>
number :GetLearningRate()
Returns the learning rate of the gate node.
</div>

<div class=functionDoc>
ActivationFunction :GetActivationFunction()
Returns the ActivationFunction object of the gate node.
</div>

## Inherited from <code class=funcName>FeedforwardNetwork</code>:
<i>Only unchanged and unmodified functions are listed below.</i>

<div class=functionDoc>
NeuralNetwork .newFromSave(string serial)
Deserializes and returns the neural network from the !serial! string: the save string.
</div>

<div class=functionDoc>
string :Save()
Returns the serialized form of the neural network as a string, allowing you to save the network.
</div>

<div class=functionDoc>
void :SetBiases(number bias)
Sets the bias of every node to !bias!.
</div>

<div class=functionDoc>
void :ConnectNodes(Node inNode, Node outNode, bool checkOveride=false)
Creates a synapse for the 2 nodes with !inNode! as the input and !outNode! as the output. If !checkOveride! is true, this function will not check if the synapse between these 2 nodes already exists; this is purely for internal performance purposes where the check is unnecessary. Do not set this to true if you are experimenting unless you're confident.
</div>

<div class=functionDoc>
dictionary :(dictionary inputValues, bool doNotClearOtherInputValues=false)
Propagates the network with the given !inputValues! if provided. If not, the network will run with the input values already set previously. If !doNotClearOtherInputValues! is true, any inputs that are missing from the !inputValues! dictionary are set to 0.
<br><br>
This function is fired when the NeuralNetwork object is called, such as:

```lua
neuralNetwork:({Input1 = 0.5, Input2 = -0.2})
```
</div>

<div class=functionDoc>
dictionary :GetOutputValues()
Returns the current output values.
</div>

<div class=functionDoc>
void :SetInputValues(dictionary inputValues, bool doNotClearOtherInputValues=false)
Sets the given input values as !inputValues! into the input nodes. If !doNotClearOtherInputValues! is true, any inputs that are missing from the !inputValues! dictionary are set to 0.
</div>

<div class=functionDoc>
void :ClearInputValues()
Sets all input values of the input nodes to 0.
</div>

<div class=functionDoc>
void :ClearValues()
Sets all the output values of every functional node to 0.
</div>

<div class=functionDoc>
array :GetNodes()
Returns every node in the network in an unreliable order.
</div>

<div class=functionDoc>
array :GetInputNodes()
Returns the input nodes in the network in the order they were assigned by the user upon network creation.
</div>

<div class=functionDoc>
void :AddInputNode(InputNode inputNode)
Adds input node !inputNode! to the network.
</div>

<div class=functionDoc>
array :GetOutputNodes()
Returns the output nodes in the network in the order they were assigned by the user upon network creation.
</div>

<div class=functionDoc>
void :AddOutputNode(OutputNode outputNode)
Adds output node !outputNode! to the network.
</div>

<div class=functionDoc>
array :GetHiddenNodes()
Returns the hidden nodes in the network in the order they were created (first node to last node of first layer, first node to last node of second layer, etc).
</div>

<div class=functionDoc>
void :AddHiddenNode(Node node)
Adds the hidden node !node! to the network.
</div>

<div class=functionDoc>
array :GetFunctionNodes()
Returns the functional nodes in the network. Functional nodes, in my definition, are nodes that have a working bias and weight set. Thus, hidden nodes and output nodes are all functional nodes.
</div>

<div class=functionDoc>
void :AddNode(Node node)
Adds the node !node! to the network.
</div>

<div class=functionDoc>
BackPropagator :GetBackPropagator()
Returns the BackPropagator object for this network.
</div>

<div class=functionDoc>
void :RandomizeWeights(number min=-0.5, number max=0.5)
Randomizes all weights in the network with the given minimum !min! and maximum !max! values.
</div>

<div class=functionDoc>
Optimizer :GetOptimizer()
Returns the Optimizer object the network is using.
</div>

<div class=functionDoc>
void :AddRandomNoise(number min, number max)
Adds a random noise to every parameter in the network with the given minimum !min! and maximum !max! values.
</div>