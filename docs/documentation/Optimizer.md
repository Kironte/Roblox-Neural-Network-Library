# **Abstract Optimizer Class**
This class is responsible for the base of all optimizers. Optimizers are functions that determine the stepping size of backpropagation, each unique optimizer having a different algorithm at play. Each one has it's strengths and weaknesses.<br>
This class is abstract and thus cannot be used directly.

<div class=functionDoc>
abstract Optimizer .new()
Creates and returns the Optimizer.
</div>

<div class=functionDoc>
void :SetNetwork(NeuralNetwork network)
Sets the optimizer's network to !network!.
</div>