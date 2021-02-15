# Data Science with CSV files

## CSV Files

The data/ folder contains some csv and json files for the problem this week.

### Rugby

rugby.csv contains some statistics from the English Rubgy Union premiership
and championship leagues in the 19/20 season.
The columns "Total For" and "Total Against" contain the number of tries scored
for a team and against them respectively.
Write a program to read the file and print the teams with the smallest
and biggest differences in tries scored for and against them.


### Weather

weather.csv contains the weather data for Whistler Roundhouse in 2020.
Each row contains the weather data for a day of the year,
The columns "Max Temp (°C)" and "Min Temp (°C)" contain the lowest
and highest temperature for that day.
Write a program to read the file and print the days with the smallest
and biggest differences in temperature on a day.

Tips:

* If you have trouble with the unicode in the column headers then feel free to edit that out.
* If you have trouble with the quoting in the file then feel free to edit that out.

Bonus:
* Try to write the code such that you can use the same functions for the rugby and weather data.


### Detecting Accounting Errors

You've opened a successful bakery in Oregon (no sales tax!)
(but this is at a point in time where the US Dollar is weak
and matches the Canadian Dollar, so someone living in Canada wouldn't find your prices strange...).
An important part of any business is accounting.
transactions.csv contains bank transactions for all the sales you've made in the past month,
and sales.csv contains the receipt data for all of those transactions.
Your task is to write a program that will output the IDs of transactions
with accounting errors (ie. where the transaction amount does not match the amount on the receipt).

errors.csv contains the correct list of erroneous transactions
for you to validate against.

Bonus:
* Calculate the percentage of incorrect transactions.
* Calculate the amount of money gained or lost to errors.
* Calculate which staff member makes the most mistakes.
    * Calculate which staff member makes the most mistakes as
      a percentage of their total sales and fire them!
* Try to solve the problem without using the transaction ID from the bank transactions.
* If your chosen language has such a type, use a "decimal" type to calculate
  the amount of money lost or gained to errors,
  so that you do not accumulate floating point errors!
  For example, Python has https://docs.python.org/3/library/decimal.html.

### Bonuses

* Read the data out of the associated json files for each problem instead of the csv files.
