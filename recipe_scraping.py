from recipe_scrapers import scrape_me

scraper = scrape_me('https://www.allrecipes.com/recipe/158968/spinach-and-feta-turkey-burgers/')

scraper.title()
scraper.total_time()
scraper.yields()
scraper.ingredients()
scraper.instructions()
scraper.image()
scraper.host()
scraper.links()
scraper.nutrients()  # if available

print(scraper.title())
print(scraper.ingredients())

for i in scraper.links():
    print(i['href'])
    exit
