import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:pantree/models/custom_fab.dart';
import 'package:pantree/models/modules.dart';
import 'package:pantree/models/recipe_creation.dart';
import 'package:pantree/pantreeUser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pantree/models/recipe_viewer.dart';
import 'package:pantree/models/drawer.dart';

// Created by ResoCoder https://resocoder.com/2021/01/23/search-bar-in-flutter-logic-material-ui/
// Edited by Brandon Wong and Theaux Masquelier

class recipes extends StatefulWidget {
  PantreeUser user;

  recipes({this.user});

  @override
  _recipeState createState() => _recipeState(user: user);
}

class _recipeState extends State<recipes> {
  PantreeUser user;

  _recipeState({this.user});

  DocumentReference currentPPID;

  static const historyLength = 5;

  List<String> _searchHistory = [];

  List<String> filteredSearchHistory;

  List<dynamic> filteredRecipes = [];

  String selectedTerm = "";

  List<String> filterSearchTerms({
    @required String filter,
  }) {
    if (filter != null && filter.isNotEmpty) {
      return _searchHistory.reversed
          .where((term) => term.startsWith(filter))
          .toList();
    } else {
      return _searchHistory.reversed.toList();
    }
  }

  void addSearchTerm(String term) {
    if (_searchHistory.contains(term)) {
      putSearchTermFirst(term);
      return;
    }

    _searchHistory.add(term);
    if (_searchHistory.length > historyLength) {
      _searchHistory.removeRange(0, _searchHistory.length - historyLength);
    }

    filteredSearchHistory = filterSearchTerms(filter: null);
  }

  void deleteSearchTerm(String term) {
    _searchHistory.removeWhere((t) => t == term);
    filteredSearchHistory = filterSearchTerms(filter: null);
  }

  void putSearchTermFirst(String term) {
    deleteSearchTerm(term);
    addSearchTerm(term);
  }

  FloatingSearchBarController controller;

  @override
  void initState() {
    super.initState();
    controller = FloatingSearchBarController();
    filteredSearchHistory = filterSearchTerms(filter: null);
    currentPPID = this.user.PPID;
    setListener();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Set<String> getData(List<QueryDocumentSnapshot> shots) {
    Set<String> pantryIngredients = {};
        for (int i = 0; i < shots.length; i++)
          pantryIngredients.add(shots[i]["Item"].path.toString().trim());

      return pantryIngredients;
  }

  setListener() {
    FirebaseFirestore.instance
        .collection("users")
        .doc(user.uid)
        .snapshots()
        .listen((event) {
      if (event.data()['PPID'].toString() != this.currentPPID.toString()) {
        print("INSIDE LISTENER --> PPID peach emoji");
        user.PPID = event.data()['PPID'];
        this.currentPPID = event.data()['PPID'];

        setState(() {});
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    if (this.currentPPID == null) {
      return createLandingPage(user, "Pantry", context);
    }

    return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection(this.currentPPID.path + "/ingredients").snapshots(),
        builder: (BuildContext context,
        AsyncSnapshot<QuerySnapshot> querySnapshot) {
      if (querySnapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      } else {

        return Scaffold(
          drawer: PantreeDrawer(user: this.user),
          floatingActionButton: CustomFAB(
              color: Colors.red[400],
              icon: const Icon(Icons.add),
              onPressed: (() => {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RecipeCreator(user: this.user)))
              })),
          body: FloatingSearchBar(
            controller: controller,
            body: Column(children: [
              SizedBox(height: 75),
              Container(
                  height: MediaQuery.of(context).size.height * 0.1,
                  child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('filters')
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<QuerySnapshot> querySnapshot) {
                        if (querySnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        } else {
                          return Container(
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) {
                                  QueryDocumentSnapshot filter =
                                  querySnapshot.data.docs[index];
                                  return Container(
                                      width: MediaQuery.of(context).size.width * 0.4,
                                      child: Card(
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(50)),
                                          color: Colors.red[400],
                                          margin: const EdgeInsets.only(
                                              top: 12.0, right: 8.0, left: 8.0),
                                          child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  addSearchTerm("");
                                                  selectedTerm = "";
                                                });

                                                List<dynamic> idStrings = [];
                                                for (DocumentReference ref
                                                in filter["recipe_ids"]) {
                                                  idStrings.add(ref.id);
                                                  if (idStrings.length == 10) {
                                                    break;
                                                  }
                                                }
                                                filteredRecipes = idStrings;
                                              },
                                              child: Center(
                                                child: Text(filter.id,
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        color: Colors.white)),
                                              ))));
                                },
                                itemCount: querySnapshot.data.docs.length,
                              ));
                        }
                      })),
              FloatingSearchBarScrollNotifier(
                child: SearchResultsListView(
                    pantryIngredients: getData(querySnapshot.data.docs),
                    user: this.user,
                    searchTerm: selectedTerm.toLowerCase(),
                    filters: filteredRecipes),
              )
            ]),
            transition: CircularFloatingSearchBarTransition(),
            physics: BouncingScrollPhysics(),
            title: Text(
              selectedTerm ?? 'Search for Recipes',
              style: Theme.of(context).textTheme.headline6,
            ),
            hint: 'Begin by typing a recipe...',
            actions: [
              FloatingSearchBarAction.searchToClear(),
            ],
            // onQueryChanged: (query) {
            //   setState(() {
            //     filteredSearchHistory = filterSearchTerms(filter: query);
            //     filteredRecipes = [];
            //   });
            // },
            onSubmitted: (query) {
              setState(() {
                addSearchTerm(query);
                selectedTerm = query;
                filteredRecipes = [];
              });
              controller.close();
            },
            builder: (context, transition) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Material(
                  color: Colors.white,
                  elevation: 4,
                  child: Builder(
                    builder: (context) {
                      if (filteredSearchHistory.isEmpty &&
                          controller.query.isEmpty) {
                        return Container(
                          height: 56,
                          width: double.infinity,
                          alignment: Alignment.center,
                          child: Text(
                            'Click Above to Start Searching Recipes',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.caption,
                          ),
                        );
                      } else if (filteredSearchHistory.isEmpty) {
                        return ListTile(
                          title: Text(controller.query),
                          leading: const Icon(Icons.search),
                          onTap: () {
                            setState(() {
                              addSearchTerm(controller.query);
                              selectedTerm = controller.query;
                            });
                            controller.close();
                          },
                        );
                      } else {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: filteredSearchHistory
                              .map(
                                (term) => ListTile(
                              title: Text(
                                term,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              leading: const Icon(Icons.history),
                              trailing: IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    deleteSearchTerm(term);
                                  });
                                },
                              ),
                              onTap: () {
                                setState(() {
                                  putSearchTermFirst(term);
                                  selectedTerm = term;
                                });
                                controller.close();
                              },
                            ),
                          )
                              .toList(),
                        );
                      }
                    },
                  ),
                ),
              );
            },
          ),
        );
      }
    });
  }
}

class SearchResultsListView extends StatelessWidget {
  final String searchTerm;
  final List<dynamic> filters;
  final PantreeUser user;
  Set<String> pantryIngredients;

  SearchResultsListView({
    Key key,
    @required this.pantryIngredients,
    @required this.searchTerm,
    @required this.filters,
    @required this.user,
  }) : super(key: key);

  int getMissingIngredients(QuerySnapshot ingredients) {
    int numIngredients = 0;

    for (int i = 0; i < ingredients.docs.length; i++) {
      if (!this.pantryIngredients.contains(ingredients.docs[i]["Item"].path.toString().trim())) {
        numIngredients++;
      }
    }
    return numIngredients;
  }

  @override
  Widget build(BuildContext context) {
    if (this.pantryIngredients == null) {
      return CircularProgressIndicator();
    }

    if (searchTerm == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.wine_bar,
              size: 64,
            ),
            Text(
              //text in the middle
              '',
              style: Theme.of(context).textTheme.headline5,
            )
          ],
        ),
      );
    }

    Stream<QuerySnapshot> query;
    if (filters.length > 0) {
      query = FirebaseFirestore.instance
          .collection('recipes')
          .limit(10)
          .where('DocumentID', arrayContainsAny: filters)
          .snapshots();
    } else {
      query = FirebaseFirestore.instance
          .collection('recipes')
          .limit(20)
          .where('Keywords', arrayContainsAny: ['$searchTerm']).snapshots();
    }

    return Expanded(
        child: StreamBuilder<QuerySnapshot>(
            stream: query,
            builder: (BuildContext context,
                AsyncSnapshot<QuerySnapshot> querySnapshot) {
              if (querySnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              } else {
                return ListView.builder(
                  itemBuilder: (context, index) {
                    QueryDocumentSnapshot recipe =
                        querySnapshot.data.docs[index];

                    Stream<QuerySnapshot> ingredients = FirebaseFirestore.instance
                        .collection(recipe.reference.path + "/ingredients").snapshots();

                    return StreamBuilder<QuerySnapshot>(
                     stream: ingredients,
                      builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> ingredientsSnapshot) {
                       if (ingredientsSnapshot.connectionState == ConnectionState.waiting) {
                         return Container();
                       }

                        int missingIngred = getMissingIngredients(ingredientsSnapshot.data);
                        Color cardColor = missingIngred < 3 ? Colors.green : missingIngred >= 3 && missingIngred <= 5 ? Colors.yellow[700] : Colors.red[400];
                        return Card(
                            margin: const EdgeInsets.only(
                                top: 12.0, right: 8.0, left: 8.0),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5.0)),
                              title: Text(
                                recipe["RecipeName"],
                                style: TextStyle(fontSize: 20.0),
                              ),
                              subtitle: SizedBox(
                                  width: MediaQuery.of(context).size.width,
                                  height: MediaQuery.of(context).size.height * 0.18,
                                  child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Card(
                                            color: cardColor,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(5.0)),
                                            child: Container(
                                                padding: const EdgeInsets.only(
                                                    top: 5.0,
                                                    right: 5.0,
                                                    left: 5.0,
                                                    bottom: 5.0),
                                                child: Text(
                                                    recipe["TotalTime"].toString() +
                                                        " minutes",
                                                    style: TextStyle(
                                                      fontSize: 18.0,
                                                      color: Colors.white,
                                                    )))),
                                        Card(
                                            color: cardColor,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(5.0)),
                                            child: Container(
                                                padding: const EdgeInsets.only(
                                                    top: 5.0,
                                                    right: 5.0,
                                                    left: 5.0,
                                                    bottom: 5.0),
                                                child: Text(recipe["Credit"].toString(),
                                                    style: TextStyle(
                                                      fontSize: 18.0,
                                                      color: Colors.white,
                                                    )))),
                                        Card(
                                            color: cardColor,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                BorderRadius.circular(5.0)),
                                            child: Container(
                                                padding: const EdgeInsets.only(
                                                    top: 5.0,
                                                    right: 5.0,
                                                    left: 5.0,
                                                    bottom: 5.0),
                                                child: Text("Missing Ingredients: " + missingIngred.toString(),
                                                    style: TextStyle(
                                                      fontSize: 18.0,
                                                      color: Colors.white,
                                                    ))))
                                      ])),
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => ViewRecipe(
                                        user: this.user,
                                        recipe: querySnapshot.data.docs[index])));
                              },
                            ));
                      });


                  },
                  itemCount: querySnapshot.data.docs.length,
                );
              }
            }));
  }
}
