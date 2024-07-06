import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/recipe_model.dart';
import '../view_model/recipe_view_model.dart';

class RecipeDetailView extends StatelessWidget {
  final int recipeId;

  RecipeDetailView({required this.recipeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipe Detail'),
      ),
      body: Consumer<RecipeViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          final recipe = viewModel.selectedRecipe;

          if (recipe == null) {
            return Center(child: Text('No recipe selected'));
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(recipe.recipeName, style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
                SizedBox(height: 10.0),
                Text(recipe.recipeContent, style: TextStyle(fontSize: 18.0)),
                SizedBox(height: 20.0),
                Text('Ingredients:', style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
                for (var ingredient in recipe.details)
                  Text('${ingredient.foodName} - ${ingredient.amount} ${ingredient.unit}', style: TextStyle(fontSize: 16.0)),
              ],
            ),
          );
        },
      ),
    );
  }
}
