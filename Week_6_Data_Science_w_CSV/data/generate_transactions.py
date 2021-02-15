import csv
import datetime
import decimal
import json
import random

PRICES = {
    "Bread": "5.92",
    "Jam": "12.89",
    "Cake": "8.73",
    "Tea": "3.29",
    "Coffee": "4.37",
    "Pastry": "7.49",
}
ITEMS = list(PRICES)
STAFF = [
    "Cersai",
    "Anakin",
    "Karen",
    "Khan",
    "The Hood",
    "Dr Claw",
    "Ariana",
]

NUM_TRANSACTIONS = 12500
TRANSACTION_COLUMNS = ["Transaction ID", "Date", "Item", "Deposit Amount"]
SALE_COLUMNS = ["Transaction ID", "Staff", "Date", "Item", "Amount"]

transactions = []
sales = []
errors = []
date = datetime.date(2020, 6, 1)
cur_staff_i = random.randrange(len(STAFF))
for transaction_id in range(NUM_TRANSACTIONS):
    item = random.choice(ITEMS)
    date_str = f"{date:%Y/%m/%d}"
    sale = (transaction_id, STAFF[cur_staff_i], date_str, item, PRICES[item])
    incorrect = random.randrange(0, 100) <= 1
    if incorrect:
        error = random.triangular(1, 90, 20) * random.choice([-1, 1])
        amount = float(PRICES[item]) * error / 100
        transaction = (transaction_id, date_str, item, f"{amount:.2f}")
        errors.append(transaction_id)
    else:
        transaction = (sale[0], sale[2], sale[3], sale[4])
    sales.append(sale)
    transactions.append(transaction)
    if random.randrange(1, 30) == 1:
        date = date + datetime.timedelta(days=1)
        cur_staff_i = (cur_staff_i + 1) % len(STAFF)

with open("transactions.csv", "w") as out_f:
    writer = csv.writer(out_f)
    writer.writerow(TRANSACTION_COLUMNS)
    writer.writerows(transactions)

with open("sales.csv", "w") as out_f:
    writer = csv.writer(out_f)
    writer.writerow(SALE_COLUMNS)
    writer.writerows(sales)

with open("errors.csv", "w") as out_f:
    writer = csv.writer(out_f)
    writer.writerow(["Transaction ID"])
    for error in errors:
        writer.writerow([error])

with open("transactions.json", "w") as out_f:
    json_transactions = [
        {k: v for k, v in zip(TRANSACTION_COLUMNS, transaction)} for transaction in transactions
    ]
    json.dump(json_transactions, out_f)

with open("sales.json", "w") as out_f:
    json_sales = [
        {k: v for k, v in zip(SALE_COLUMNS, sale)} for sale in sales
    ]
    json.dump(json_sales, out_f)

with open("errors.json", "w") as out_f:
    json.dump(errors, out_f)
