import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/recipe_view_model.dart';
import '../view_model/user_view_model.dart';
import 'recipe_detail_view.dart';

class RecipeListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipes'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              String kakaoId = Provider.of<UserViewModel>(context, listen: false).kakaoId;
              Provider.of<RecipeViewModel>(context, listen: false).toggleShowRecommended(kakaoId);
            },
            itemBuilder: (BuildContext context) {
              return {'Show All', 'Show Recommended'}.map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
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
    );
  }
}
