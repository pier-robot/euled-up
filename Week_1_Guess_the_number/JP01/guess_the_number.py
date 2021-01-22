import argparse
import random

# create a parse which will show the default values when you type --help
parser = argparse.ArgumentParser(
    description='Guess the number within a range.',
    formatter_class=argparse.ArgumentDefaultsHelpFormatter
)
parser.add_argument("--min", default=1, help="Lower bound for random number.")
parser.add_argument("--max", default=10, help="Upper bound for random number.")
args = parser.parse_args()

if __name__ == "__main__":
    try:
        number_to_guess = random.randint(int(args.min), int(args.max))
    except ValueError:
        print("Range has to use a whole/integer numbers!!!!")
        exit()

    correct = False
    while not correct:
        guess = input(
            "\nGuess a number between between {0} and {1} \n".format(args.min, args.max)
        )
        # make sure it's a number
        try:
            guess = int(guess)
        except ValueError:
            print("It has to be a whole/integer number!!!!")
            continue

        # now confirm if we guessed correct
        if guess > number_to_guess:
            print("Guess Lower!")
        elif guess < number_to_guess:
            print("Guess Higher!")
        else:
            print("You got it!")
            correct = True
