# python -m venv .venv
# .venv/bin/pip install beautifulsoup4 requests

import csv
import json

from bs4 import BeautifulSoup
import requests


URLS = {
    "premiership": [
        "https://rugby.statbunker.com/competitions/TriesFor?comp_id=609",
        "https://rugby.statbunker.com/competitions/TriesAgainst?comp_id=609",
    ],
    "championship": [
        "https://rugby.statbunker.com/competitions/TriesFor?comp_id=613",
        "https://rugby.statbunker.com/competitions/TriesAgainst?comp_id=613",
    ]
}

COLUMNS = {
    #"Club": "Club",
    "T": "Total",
    "H": "Home",
    "A": "Away",
    "FH": "First Half",
    "SH": "Second Half",
    "0-20": "0-20",
    "21-40": "21-40",
    "41-60": "41-60",
    "61-80": "61-80",
    "MP": "Matches Played",
}

csv_data = {}
json_data = {league: {} for league in URLS}
for league, urls in URLS.items():
    for i, url in enumerate(urls):
        page = requests.get(url)
        soup = BeautifulSoup(page.content, "html.parser")
        stats_table = soup.find(name="tbody")
        # The last row contains aggregate stats that we don't want
        for row in stats_table.find_all("tr")[:-1]:
            row_data = []
            club = row.find("td").p.text
            for cell in row.find_all("td")[1:]:
                row_data.append(int(cell.text) if cell.text != "-" else 0)

            if i == 0:
                csv_data[club] = [league]
                json_data[league][club] = {}
            csv_data[club].extend(row_data)
            json_data[league][club].update({
                k + (" For", " Against")[i]: v for k, v in zip(COLUMNS.values(), row_data)
            })


with open("rugby.csv", "w", newline="") as out_f:
    writer = csv.writer(out_f)
    writer.writerow(
        ["Club"]
        + ["League"]
        + list(col + " For" for col in COLUMNS.values())
        + list(col + " Against" for col in COLUMNS.values())
    )
    for club, row_data in csv_data.items():
        writer.writerow([club] + row_data)


with open("rubgy.json", "w") as out_f:
    json.dump(json_data, out_f)
