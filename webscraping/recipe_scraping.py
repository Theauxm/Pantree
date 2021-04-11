# pip install firebase_admin
# pip install recipe_scrapers

from recipe_scrapers import scrape_me
import firebase_admin

# Sets up website to scrape
top_level_website = scrape_me('https://allrecipes.com')
data = open("./data.txt", "w")

# Uses a set to guarantee no duplicates
ingredients = {}

# Gets all recipe subsections
for i in top_level_website.links():
    if 'https://www.allrecipes.com/recipes' not in i['href']:
        continue

    # For each subsection, gets all recipes
    scraper = scrape_me(i['href'])
    for j in scraper.links():
        if 'https://www.allrecipes.com/recipe/' not in j['href']:
            continue

        # Adds recipe to file
        recipe = scrape_me(j['href'])
        if recipe.title() not in ingredients:
            ingredients[recipe.title()] = recipe.ingredients()
            data.write("TITLE: " + str(recipe.title()) + " INGREDIENTS: " + str(recipe.ingredients()) + "\n")

data.close()