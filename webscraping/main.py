# Need to install both of these libraries before the file can be run
# python3 -m pip install firebase_admin
# python3 -m pip install recipe_scrapers

from recipe_scrapers import scrape_me
from datetime import datetime
from firebase_admin import firestore
import firebase_admin

measures = {
    'teaspoon', 
    'tablespoon', 
    'cups', 
    'cup', 
    'teaspoons', 
    'tablespoons', 
    'ounce', 
    'ounces',
    'unit'}

# List of visited sites to avoid duplicates
visited = set()

# Top level domain
site = 'https://hellofresh.com'

# Filters to define a given type of recipe
filters = {
    "american" : {"american", "burger", "fries"},
    "italian" : {"italian", "penne", "risotto", "agnolotti", "linguine", "piccata"},
    "asian" : {"asian", "korean", "chinese", "indian", "curry", "japanese", "stir-fry", "teriyaki", "lo mein", "hoisin", "thai", "sesame", "bulgogi", "kimchi"},
    "breakfast" : {"egg", "breakfast", "chorizo", "oatmeal", "smoothie"},
    "mexican" : {"mexican", "enchiladas", "chipotle", "quesadillas", "carne asada", "fajitas", "chorizo"},
    "hawaiian" : {"pineapple", "hawaiian", "luau", "tropical"},
    "lunch" : {"sandwich", "burrito", "soup", "lunch"},
    "dinner" : {"pizza", "pot roast", "oven roasted", "soup", "dinner"}
}

# ASCII fraction conversions
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
    firebase_admin.initialize_app(cred)

    # Database object to write to
    db = firestore.client()

    add_recipe(scrape_me('https://www.hellofresh.com/recipes/firecracker-meatballs-611d14d71fc432111c3865f6'), db)

    # Starts recursive calls
    #get_recipes(db, site, '/')


def get_recipes(db, link, h):
    """
    A web crawler that recurs through every link within a site and checks if any are recipes
    Args:
        db : Google Firestore database object
        link : Top level domain, such as "hellofresh.com" or "allrecipes.com"
        h : subheader, such as "/" or "/recipes/chicken-bowls"
    """
    global link_amt

    # Initializes recipe scraper 
    html = scrape_me(link + h)
    print("\n" + link + h)

    # If there are ingredients returned by the scraper, it is a recipe
    if len(html.ingredients()) > 0:

        # Checks title of recipe to see if it can be filtered
        y = ""
        for x in filters.keys():
            if bool(filters[x] & set([word.lower() for word in html.title().split()])):
                y = x
                break

        
        add_recipe(html, db, y)
        print(html.title())
        print("Filter: " + y)

    for i in html.links():
        # Checks to see if the link is potentially a recipe
        if 'href' in i and i['href'] not in visited and '/recipes' in i['href'] and 'http' not in i['href']:

                # Ensures no duplicates
                visited.add(i['href'])

                # Recurs down with the new sub url
                get_recipes(db, link, i['href'])


def add_recipe(recipe, db, filter = ""):
    """
    Adds recipe to a Google Firestore database
    Args:
        recipe : scrape_me object containing information about the recipe being added
        db : Google Firestore database object
        filter : filter to be added to, can be an empty string

    """
    global site

    # Recipes are added to 2 collections
    new_recipe_ref = db.collection(u'recipes').document()

    # user adding the recipe
    user = db.collection(u'users').document(u'PantreeOfficial')

    ingredients_keywords = set()

    # Parse each ingredient and add unique identifier to database
    for ingred in recipe.ingredients():
        words = ingred.split()
        print(ingred)

        # Get the ingredient name from the string along with the amount and type
        ingredient_and_unit = get_ingredients(words)
        ingredient = ingredient_and_unit[0]

        # Checks to make sure the parsing came back correctly to not cause an exception
        if ingredient == "":
            continue

        # Gets Keywords set for each ingredient, adds to 'master set'
        ingred_keywords = get_keywords(ingredient)
        ingredients_keywords |= ingred_keywords

        # Adds ingredient to database
        ingredient_instance = {}
        does_ingredient = db.collection(u'food').document(ingredient).get()
        if not does_ingredient.exists:
            db.collection(u'food').document(ingredient).set({
                u'Keywords' : list(ingred_keywords),
                u'Image' : ""})

        # Adds instance of ingredient with quantity and unit
        ingredient_instance['Item'] = db.collection(u'food').document(ingredient)
        ingredient_instance['Quantity'] = get_amount(words)
        if ingredient_and_unit != "":
            ingredient_instance['Unit'] = ingredient_and_unit[1]

        db.collection(u'food').document(ingredient).set({u'recipe_ids' : firestore.ArrayUnion([new_recipe_ref])},
                                                        merge=True)

        new_recipe_ref.collection(u'ingredients').add(ingredient_instance)

    # Information (except ingredient instances) about the recipe
    new_recipe_ref.set({
        u'CreationDate' : datetime.utcnow(),
        u'Creator' : user,
        u'Directions' : recipe.instructions().splitlines(),
        u'RecipeName' : recipe.title(),
        u'TotalTime' : recipe.total_time(),
        u'Credit' : site,
        u'Keywords' : list(ingredients_keywords | get_keywords(recipe.title())) # All ingredients keywords along with recipe title keywords
    })

    # Updates recipes for the specific user, along with its corresponding filters and recipe name for easier searching
    user.set({u'recipe_ids' : firestore.ArrayUnion([new_recipe_ref])},
             merge=True)

    # If a filter exists, it is appended to the given filter's list 
    if filter != "":
        filter_array = db.collection(u'filters').document(filter)
        filter_array.set({u'recipe_ids' : firestore.ArrayUnion([new_recipe_ref])},
                         merge=True)

        
def get_amount(words):
    """
    Translates ASCII fraction symbols into Python readable data
    Args:
        words : list of split strings containing an ingredient's information
    """

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
    """
    Splits the ingredient string along with the unit associated with it. I.e., "1 Cup Shallots" would return ['cup', 'shallots']
    Args:
        words : list of split strings containing and ingredient's information
    """
    ingredient = ""
    unit = ""
    for x in words[1:]:
        # All ingredients with comma will be an extra un-necessary parameter
        if "," in x:
            ingredient += x[:-1]
            break

        # Takes off extra 's' if necessary, then adds as unit
        if x in measures:
            if x[len(x) - 1] == 's':
                unit = x[:-1]
            else:
                unit = x
            continue

        # Any "and" is un-necessary
        if "and" in x:
            continue

        # Skips over unicode fractions, this is used in get_amount()
        try:
            if ord(x) in unicode_fractions.keys():
                continue
        except:
            ingredient += x + " "

    return (ingredient.lower(), unit)

def get_keywords(word):
    """
    Gets all substrings in order, adds them to a set, and returns
    Args:
        word : string(word) string to get substring for
    """
    keywords = set()
    for i in range(len(word)):
        for j in range(len(word)):
            keywords.add(word[i:j + 1])

    return keywords

if __name__ == "__main__":
    main()

