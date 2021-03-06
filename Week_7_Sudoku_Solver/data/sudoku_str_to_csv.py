import sys

for _ in range(9):
    for j in range(9):
        sys.stdout.write(sys.stdin.read(1))
        if j != 8:
            sys.stdout.write(",")
    sys.stdout.write("\n")
