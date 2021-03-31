from recipe_scrapers import scrape_me

top_level_website = scrape_me('https://allrecipes.com')

ingredients = {}

for i in top_level_website.links():
    if 'https://www.allrecipes.com/recipes' not in i['href']:
        continue

    scraper = scrape_me(i['href'])
    for j in scraper.links():
        if 'https://www.allrecipes.com/recipe/' not in j['href']:
            continue

        recipe = scrape_me(j['href'])
        if recipe.title() not in ingredients:
            ingredients[recipe.title()] = recipe.ingredients()

            print(len(ingredients))

        


print(ingredients)