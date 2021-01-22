#!/usr/bin/env python2.7
import random

_min = 0
_max = 100


def _guess_input():
    while True:
        guess = raw_input(      #py2.7
            (
                "Guess a value between {} and {} (included): "
            ).format(_min, _max)
        )
        try:
            guess = int(guess)
        except ValueError:
            print("Please enter a number")
        else:
            if _min <= guess <= _max:
                break
            else:
                print("Choose between {} and {}!".format(_min, _max))
    return guess


def main():
    the_num = random.randint(_min, _max)
    while True:
        guess = _guess_input()
        if guess > the_num:
            print("Guess lower")
        elif guess < the_num:
            print("Guess higher")
        else:   # ==
            print("Woo! you guessed it right!")
            break


if __name__ == "__main__":
    main()

