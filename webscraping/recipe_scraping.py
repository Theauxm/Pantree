# Need to install both of these libraries before the file can be run
# python3 -m pip install firebase_admin
# python3 -m pip install recipe_scrapers

from recipe_scrapers import scrape_me
from datetime import datetime
from firebase_admin import firestore
import firebase_admin

# Sets up firestore database
# **IMPORTANT**
# NEED LOCAL database_admin_key.json FROM FIRESTORE CONSOLE VIA PROJECT SETTINGS -> SERVICE ACCOUNTS -> GENERATE NEW PRIVATE KEY
cred = firebase_admin.credentials.Certificate('./webscraping/database_admin_key.json')
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

            # Each recipe requires its own entry
            entry = {
                u'CreationDate' : datetime.utcnow(),
                u'Creator' : db.collection(u'users').document(u'PanTreeOfficial'),
                u'Directions' : recipe.instructions().splitlines(),
                u'RecipeName' : recipe.title(),
                u'TotalTime' : recipe.total_time(),
                u'Ingredients' : []
            }

            for ingred in recipe.ingredients():
                words = ingred.split()
                ingredient_instance = {}
                ingredient = " "
                amount = words[0]
                if not len(words[1]) > 1:
                    for i in words[3:]:
                        ingredient += i + " "
                else:
                    for i in words[2:]:
                        ingredient += i + " "

                does_ingredient = db.collection(u'food').document(ingredient.lower()).get()
                if not does_ingredient.exists:
                    ingredient_dict = {}
                    ingredient_dict[u'ExpTime'] = 1
                    ingredient_dict[u'Weight'] = 24
                    db.collection(u'food').document(ingredient.lower()).set(ingredient_dict)

                ingredient_instance["Item"] = db.collection(u'food').document(ingredient.lower())
                ingredient_instance["Quantity"] = amount

                entry["Ingredients"].append(ingredient_instance)

            db.collection(u'recipes').add(entry)