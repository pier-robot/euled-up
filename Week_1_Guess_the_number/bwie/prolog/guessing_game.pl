:- use_module(library(random)).

get_random(Number) :-
    writeln("Getting random number between 1 and 10...\n"),
    random_between(1, 10, Number).


too_low(Guess, Answer) :-
    Guess < Answer,
    writeln("Too low, guess again.\n").


too_high(Guess, Answer) :-
    Guess > Answer,
    writeln("Too high, guess again.\n").


numeric_input_between(M, N, Input) :-
    prompt1("Please enter a number between 1 and 10: "),
    read(Input),
    number(Input),
    Input >= M,
    Input =< N.


% Fallthrough clause. This rule will only ever be run if the above rule fails.
numeric_input_between(M, N, Input) :-
    writeln("Whoops! I know, numbers are hard. Try again!\n"),
    numeric_input_between(M, N, Input).


guess(Guess, Answer) :-
    % Correct guess!
    Guess == Answer,
    writeln("Well done!"),
    true
;
    % Guess is either too high or too low.
    (
        too_low(Guess, Answer)
    ;
        too_high(Guess, Answer)
    ),
    numeric_input_between(1, 10, NewGuess),
    guess(NewGuess, Answer).


% "main" clause
guessing_game :-
    get_random(Answer),
    numeric_input_between(1, 10, Guess),
    guess(Guess, Answer).
