import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/recipe_view_model.dart';
import '../view_model/user_view_model.dart';
import 'recipe_detail_view.dart';

class RecipeListView extends StatefulWidget {
  @override
  _RecipeListViewState createState() => _RecipeListViewState();
}

class _RecipeListViewState extends State<RecipeListView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRecipes();
    });
  }

  Future<void> _loadRecipes() async {
    final recipeViewModel = Provider.of<RecipeViewModel>(context, listen: false);
    await recipeViewModel.fetchRecipes();
  }

  void _showRecommendationPrompt() {
    showDialog(
      context: context,
      builder: (context) {
        String prompt = '';
        return AlertDialog(
          title: Text('Get Recommendations'),
          content: TextField(
            onChanged: (value) {
              prompt = value;
            },
            decoration: InputDecoration(hintText: "Enter your prompt (e.g., High protein, light meal)"),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Submit'),
              onPressed: () {
                Navigator.of(context).pop();
                _updateRecommendations(prompt);
              },
            ),
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _updateRecommendations(String prompt) {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final recipeViewModel = Provider.of<RecipeViewModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await recipeViewModel.fetchRecommendedRecipes(userViewModel.kakaoId, prompt);
    });
  }

  void _showAllRecipes() {
    final recipeViewModel = Provider.of<RecipeViewModel>(context, listen: false);
    recipeViewModel.showAllRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipes'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: RecipeSearchDelegate());
            },
          ),
          IconButton(
            icon: Icon(Icons.list),
            onPressed: _showAllRecipes,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Consumer<RecipeViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return Center(child: CircularProgressIndicator());
            }

            return ListView.builder(
              itemCount: viewModel.recipes.length,
              itemBuilder: (context, index) {
                final recipe = viewModel.recipes[index];
                return GestureDetector(
                  onTap: () {
                    viewModel.fetchRecipeDetail(recipe.id);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RecipeDetailView(recipeId: recipe.id)),
                    );
                  },
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(10),
                      title: Text(
                        recipe.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        recipe.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showRecommendationPrompt,
        child: Icon(Icons.recommend),
      ),
    );
  }
}

class RecipeSearchDelegate extends SearchDelegate {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Consumer<RecipeViewModel>(
      builder: (context, viewModel, child) {
        final results = viewModel.recipes.where((recipe) => recipe.name.toLowerCase().contains(query.toLowerCase())).toList();

        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final recipe = results[index];
            return ListTile(
              title: Text(recipe.name),
              onTap: () {
                close(context, null);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RecipeDetailView(recipeId: recipe.id)),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Consumer<RecipeViewModel>(
      builder: (context, viewModel, child) {
        final suggestions = query.isEmpty
            ? []
            : viewModel.recipes.where((recipe) => recipe.name.toLowerCase().contains(query.toLowerCase())).toList();

        return ListView.builder(
          itemCount: suggestions.length,
          itemBuilder: (context, index) {
            final recipe = suggestions[index];
            return ListTile(
              title: Text(recipe.name),
              onTap: () {
                query = recipe.name;
                showResults(context);
              },
            );
          },
        );
      },
    );
  }
}
