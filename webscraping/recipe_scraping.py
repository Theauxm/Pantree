# Need to install both of these libraries before the file can be run
# python3 -m pip install firebase_admin
# python3 -m pip install recipe_scrapers

from recipe_scrapers import scrape_me
from datetime import datetime
from firebase_admin import firestore
import firebase_admin

# Measurements available within web scraper
measures = {'teaspoon', 'tablespoon', 'cups', 'cup', 'teaspoons', 'tablespoons', 'pinch', 'ounces', 'ounce', 'pound', 'pounds'}

# Converts unicode fractions to python readable fractions 
unicode_fractions = {
    int('00bc', 16) : 1/4,
    int('00bd', 16) : 1/2,
    int('00be', 16) : 3/4,
    int('2150', 16) : 1/7,
    int('2151', 16) : 1/9,
    int('2152', 16) : 1/10,
    int('2153', 16) : 1/3,
    int('2154', 16) : 2/3,
    int('2155', 16) : 1/5,
    int('2156', 16) : 2/5,
    int('2157', 16) : 3/5,
    int('2158', 16) : 4/5,
    int('2159', 16) : 1/6,
    int('215a', 16) : 5/6,
    int('215b', 16) : 1/8,
    int('215c', 16) : 3/8,
    int('215d', 16) : 5/8,
    int('215e', 16) : 7/8,
    int('215f', 16) : 1,
    int('2189', 16) : 0,
}

def main():
    # Sets up firestore database
    # **IMPORTANT**
    # NEED LOCAL database_admin_key.json FROM FIRESTORE CONSOLE VIA PROJECT SETTINGS -> SERVICE ACCOUNTS -> GENERATE NEW PRIVATE KEY
    cred = firebase_admin.credentials.Certificate('./database_admin_key.json')
    default_app = firebase_admin.initialize_app(cred)

    # Database object to write to
    db = firestore.client()

    # Sets up website to scrape
    top_level_website = scrape_me('https://allrecipes.com')

    # Uses a set to guarantee no duplicates
    recipes = set({})

    # Gets all recipe subsections
    for i in top_level_website.links():
        if 'https://www.allrecipes.com/recipes' not in i['href']:
            continue

        # For each subsection, gets all recipes
        scraper = scrape_me(i['href'])
        for j in scraper.links():
            if 'https://www.allrecipes.com/recipe/' not in j['href']:
                continue

            # Adds recipe to database
            recipe = scrape_me(j['href'])
            if recipe.title() not in recipes:
                recipes.add(recipe.title())
                new_recipe_ref = db.collection(u'recipes').document()

                # Each recipe requires its own entry
                entry = {
                    u'CreationDate' : datetime.utcnow(),
                    u'Creator' : db.collection(u'users').document(u'PanTreeOfficial'),
                    u'Directions' : recipe.instructions().splitlines(),
                    u'RecipeName' : recipe.title(),
                    u'TotalTime' : recipe.total_time(),
                    u'Credit' : 'allrecipes.com'
                }

                # Parse eachingredient and add unique identifier to database
                for ingred in recipe.ingredients():
                    words = ingred.split()

                    # Get the ingredient name from the string along with amount and type
                    ingredient_and_unit = get_ingredients(words)
                    ingredient = ingredient_and_unit[0].lower()

                    # Adds ingredient to database
                    ingredient_instance = {}
                    does_ingredient = db.collection(u'food').document(ingredient).get()
                    if not does_ingredient.exists:
                        ingredient_dict = {}
                        ingredient_dict[u'ExpTime'] = 1
                        ingredient_dict[u'Weight'] = 24
                        db.collection(u'food').document(ingredient).set(ingredient_dict)

                    ingredient_instance['Item'] = db.collection(u'food').document(ingredient)
                    ingredient_instance['Quantity'] = get_amount(words)
                    ingredient_instance['Unit'] = ingredient_and_unit[1]

                    new_recipe_ref.collection(u'ingredients').add(ingredient_instance)

                # Adds structured recipe to database
                new_recipe_ref.set(entry)


def get_amount(words):
    number = 0
    for x in words:
        try:
            if ord(x) in unicode_fractions.keys():
                x = unicode_fractions[ord(x)]
                number += x
            else:
                number += int(x)
        except:
            continue

    return number

def get_ingredients(words):
    ingredient = " "
    unit = " "
    for x in words[1:]:
        if "," in x:
            ingredient += x[:-1]
            break

        if x in measures:
            if x[len(x) - 1] == 's':
                unit = x[:-1]
            else:
                unit = x
            continue

        try:
            if ord(x) in unicode_fractions.keys():
                continue
        except:
            ingredient += x + " "

    return (ingredient[1:], unit)


if __name__ == '__main__':
    main()