import 'package:flutter/material.dart';
import '../model/recipe_model.dart';
import '../model/recipe_service.dart';

class RecipeViewModel extends ChangeNotifier {
  List<Recipe> _recipes = [];
  RecipeDetail? _selectedRecipe;
  bool _isLoading = false;

  List<Recipe> get recipes => _recipes;
  RecipeDetail? get selectedRecipe => _selectedRecipe;
  bool get isLoading => _isLoading;

  Future<void> fetchRecipes() async {
    _isLoading = true;
    notifyListeners();

    _recipes = await RecipeService.fetchRecipes();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchRecipeDetail(int recipeId) async {
    _isLoading = true;
    notifyListeners();

    _selectedRecipe = await RecipeService.fetchRecipeDetail(recipeId);
    
    _isLoading = false;
    notifyListeners();
  }

  void selectRecipe(RecipeDetail recipe) {
    _selectedRecipe = recipe;
    notifyListeners();
  }
}
