# python -m venv .venv
# .venv/bin/pip/install beautifulsoup4 requests
# .venv/bin/python scrape_sudoku.py 'https://www.sudokuoftheday.com/dailypuzzles/archive/archivepuzzle/?days=0&level=1'

import sys

from bs4 import BeautifulSoup
import requests

page = requests.get(sys.argv[1])
soup = BeautifulSoup(page.content, "html.parser")
script = soup.find("h2").parent.find("script")
parts = script.string.strip().split("\"")
if len(parts) != 3:
    raise RuntimeError(f"Unexpected script content: {script.string}")
if len(parts[1]) != 9 * 9:
    raise RuntimeError(f"Unexpected sudoku board content: {parts[1]}")
print(parts[1])
