from urllib.request import urlopen

# Step 1: Page fetch karna
url = "https://quotes.toscrape.com/tag/books/"
response = urlopen(url)
html = response.read().decode("utf-8")

# Step 2: Line by line HTML split
lines = html.split("\n")

print("=== Extracted Data from Quotes Website ===")
for line in lines:
    line = line.strip()

    # --- Page Heading (h1) ---
    if "<h1" in line and "</h1>" in line:
        start = line.find(">") + 1
        end = line.find("</h1>")
        heading = line[start:end]
        print("Heading:", heading)

    # --- Quotes (span class="text") ---
    if 'class="text"' in line:
        start = line.find('“')
        end = line.rfind('”') + 1
        if start != -1 and end != -1:
            quote = line[start:end]
            print("Quote:", quote)
