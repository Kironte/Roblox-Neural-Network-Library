# **InputNode Class**
This class is responsible for managing input nodes. These nodes are heavily limited and effectivelly can only carry a value and fire proceeding nodes as it is simply an input, nothing more.

<div class=functionDoc>
InputNode .new(string name)
Creates and returns the InputNode with the given name.
</div>

<div class=functionDoc>
void :()
Fires the node and fires any node that is at it's output, potentially causing a chain reaction.
<br><br>
This function is fired when the InputNode object is called, such as:

```lua
inputNode:()
```
</div>

<div class=functionDoc>
void :ClearValue()
Sets the node's output value to 0. It is not set to nil like with Node because it has to have some sort of output.
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
void :AddOutputSynapse(Synapse outputSynapse)
Adds the synapse !outputSynapse! as an output synapse.
</div>

<div class=functionDoc>
array :GetOutputSynapses()
Returns the output synapses.
</div>

<div class=functionDoc>
void :RemoveOutputSynapse(Synapse outputSynapse)
Removes the output synapse !inputSynapse!.
</div>

<div class=functionDoc>
void :ClearOutputSynapses()
Removes all output synapses.
</div>