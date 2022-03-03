:- use_module(library(random)).

% A simplified version of guessing_game.pl with no input verification being done.

get_random(Number) :-
    writeln("Getting random number between 1 and 10...\n"),
    random_between(1, 10, Number).

get_input(Number) :-
    prompt1("Please enter a number between 1 and 10: "),
    read(Number).

guess(Guess, Answer) :-
    % Correct guess!
    Guess == Answer,
    writeln("Well done!"),
    true
;
    % Guess is either too high or too low.
    writeln("Nope, try again!"),
    get_input(NewGuess),
    guess(NewGuess, Answer).


% "main" clause
guessing_game :-
    get_random(Answer),
    get_input(Guess),
    guess(Guess, Answer).
