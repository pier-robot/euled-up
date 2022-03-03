# Guess the Peano Number

Have you ever wondered *exactly* how to define the set of natural numbers, or are you normal?
Well, one way to define the natural numbers is to use Peano's axioms, which generate the natural
numbers by postulating the existence of a number called zero, and then defining something called the
successor function.  Essentially, starting from zero, you can generate the countably infinite set of
natural numbers by repeatedly adding one. 

This solution for the "guess the number" challenge uses the power of algebraic data types in Haskell
to implement the Peano numbers, and then lets you guess a Peano number between 1 and 10!
Functionally, this is identical to guessing any of the numeric types that already exist in the Haskell standard
library, but the point was to explore the Haskell type system and type classes a little bit.
