# **Synapse Class**
This class is responsible for bridging the connection between 2 nodes, housing the weight, and providing functions to easily manage it.

<div class=functionDoc>
Synapse .new(Node input,Node output,number weight)
Creates and returns the Synapse with the given input/output nodes and weight. !weight! defaults to 0.
</div>

<div class=functionDoc>
void :call()
Propagates the output node.
<br><br>
This function is fired when the Synapse object is called, such as:

```lua
synapse:()
```
</div>

<div class=functionDoc>
number :GetValue()
Returns the output of the input node.
</div>

<div class=functionDoc>
void :SetInputNode(Node inputNode)
Sets the input node.
</div>

<div class=functionDoc>
Node :GetInputNode()
Returns the input node.
</div>

<div class=functionDoc>
void :SetOutputNode(Node outputNode)
Sets the output node.
</div>

<div class=functionDoc>
Node :GetOutputNode()
Returns the output node.
</div>

<div class=functionDoc>
number :GetWeight()
Returns the weight.
</div>

<div class=functionDoc>
void :AddWeight(number weightDelta)
Adds !weightDelta! to the current weight.
</div>

<div class=functionDoc>
void :SetWeight(number weight)
Sets the weight.
</div>