# Sudoku Solver

In honour of the YouTube channel "Cracking the Cryptic",
this week's problem is a sudoku solver.

Each .txt file in the data/ folder contains a sudoku board encoded as a string of digits
such that they fill out the board cell by cell, going along a row.
A "0" represents a blank space.
For example "073200050080100300502830970321070080000000000050010743016028507008001060090003810"
represents the following board:

```
  7 3 | 2     |   5  
  8   | 1     | 3    
5   2 | 8 3   | 9 7  
------+-------+------
3 2 1 |   7   |   8  
      |       |      
  5   |   1   | 7 4 3
------+-------+------
  1 6 |   2 8 | 5   7
    8 |     1 |   6  
  9   |     3 | 8 1  
```

Each problem increases in difficulty and requires more complex techniques to solve.
Each technique is described here: https://www.sudokuoftheday.com/techniques/
Start with the easiest problem,
then add additional solving techniques to your solver
to be able to solve the more difficult problems.


## Beginner

* Single Candidate

## Easy

* Single Candidate

## Medium

* Single Position
* Single Candidate
* Candidate Lines

## Tricky

* Single Position
* Single Candidate
* Candidate Lines
* Multiple Lines
* Naked Pairs

## Fiendish

* Single Position
* Single Candidate
* Candidate Lines
* Naked Pairs
* Hidden Pairs

## Diabolical

* Single Position
* Single Candidate
* Candidate Lines
* Hidden Pairs
* X-Wings
* Forcing Chains

## Bonus

* Use the csv files to load in the sudoku data instead of the txt files.
* The data/ folder contains a Python script for scraping puzzles from
  https://www.sudokuoftheday.com.
  Find some sudokus using additional techniques mentioned on
  https://www.sudokuoftheday.com/techniques/,
  upgrade your solver to be able to use the new technique
  and use the script to download the puzzle to test.
* Watch https://www.youtube.com/watch?v=yKf9aUIxdb4
