# Download data from https://climate.weather.gc.ca/historical_data/search_historic_data_e.html

import csv
import json

records = []
with open("weather.csv", "r") as in_f:
    # The file contains an out of place byte at the start, so ignore it.
    in_f.read(1)
    reader = csv.reader(in_f, quoting=csv.QUOTE_ALL)
    columns = next(reader)
    for row in reader:
        records.append({
            k: v for k, v in zip(columns, row)
        })

with open("weather.json", "w") as out_f:
    json.dump(records, out_f, ensure_ascii=False)
