import 'package:flutter/material.dart';
import 'package:material_floating_search_bar/material_floating_search_bar.dart';
import 'package:pantree/pantreeUser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pantree/models/recipe_viewer.dart';

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

  static const historyLength = 5;

  List<String> _searchHistory = [];

  List<String> filteredSearchHistory;

  String selectedTerm;

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
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FloatingSearchBar(
        controller: controller,
        body: FloatingSearchBarScrollNotifier(
          child: Column(
            children: [
              SizedBox(height: 50),
              SearchResultsListView(
              searchTerm: selectedTerm,
            )],
          ),
        ),
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
        onQueryChanged: (query) {
          setState(() {
            filteredSearchHistory = filterSearchTerms(filter: query);
          });
        },
        onSubmitted: (query) {
          setState(() {
            addSearchTerm(query);
            selectedTerm = query;
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
    //return Text("F");
    //return Scaffold(
      // This is handled by the search bar itself.
   //   resizeToAvoidBottomInset: false,
   //   body: buildFloatingSearchBar( context)
   // );
  }



  Widget buildFloatingSearchBar(BuildContext context) {
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return FloatingSearchBar(
      hint: 'Search...',
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: isPortrait ? 600 : 500,
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (query) {
        // Call your model, bloc, controller here.
      },
      // Specify a custom transition to be used for
      // animating between opened and closed stated.
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction(
          showIfOpened: false,
          child: CircularButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ),
        FloatingSearchBarAction.searchToClear(
          showIfClosed: false,
        ),

      ],
      builder: (context, transition) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Material(
            color: Colors.white,
            elevation: 4.0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: Colors.accents.map((color) {
                return Container(height: 112, color: color);
              }).toList(),
            ),
          ),
        );
      },
    );
  }

class SearchResultsListView extends StatelessWidget {
  final String searchTerm;

  const SearchResultsListView({
    Key key,
    @required this.searchTerm,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              style: Theme
                  .of(context)
                  .textTheme
                  .headline5,
            )
          ],
        ),
      );
    }

    return Expanded(
        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('recipes')
                .where('Keywords', arrayContainsAny: ['$searchTerm']).snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<QuerySnapshot> querySnapshot) {
              if (querySnapshot.hasError)
                return Text(
                    "Could not show any recipes, please try again in a few seconds");

              if (querySnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              else {
                return ListView.builder(
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(querySnapshot.data.docs[index]["RecipeName"]),
                      subtitle: Text(index.toString()),
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => ViewRecipe(querySnapshot.data.docs[index])));
                      },
                    );
                  },

                  itemCount: querySnapshot.data.docs.length,
                );
              }
            }
        )
    );
  }
}