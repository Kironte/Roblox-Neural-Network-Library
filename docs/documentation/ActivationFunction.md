# **ActivationFunction Class**
This class is responsible for housing the basic activation functions used in the library. As it didn't really need any extra work, this is directly ported from the first library.<br>
When choosing a function, you can only choose 1 of the supported functions below:<br>
<pre>
• Identity  • Binary       • Sigmoid    • Tanh<br>
• ArcTan    • Sin          • Sinc       • ArSinh<br>
• SoftPlus  • BentIdentity • ReLU       • SoftReLU<br>
• LeakyReLU • Swish        • ElliotSign • Gaussian<br>
• SQ-RBF
</pre>
<br>

<div class=functionDoc>
ActivationFunction .new(string activName)
Creates and returns the ActivationFunction with the !activName! indicating which activation function to use.
</div>

<div class=functionDoc>
number :Calculate(number x,bool deriv)
Calculates the Y of the activation function given the !x!, or, if !deriv! is true, instead returns the derivative tangent of the function at !x!.
</div>

<div class=functionDoc>
number :GetValue(number x)
Calculates the Y of the activation function given the !x!.
</div>

<div class=functionDoc>
number :GetDeriv(number x)
Calculates the derivative tangent of the activation function at !x!.
</div>

<div class=functionDoc>
void :SetActivator(string activName)
Sets the activation function. Be sure to review the possible options at the top of the page.
</div>

<div class=functionDoc>
string :GetActivator()
Returns the currently set activation function name.
</div>