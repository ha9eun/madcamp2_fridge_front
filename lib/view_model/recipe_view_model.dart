import 'package:flutter/material.dart';
import '../model/recipe_model.dart';
import '../model/recipe_service.dart';
import '../model/recommend_service.dart';

class RecipeViewModel extends ChangeNotifier {
  List<Recipe> _recipes = [];
  List<Recipe> _recommendedRecipes = [];
  RecipeDetail? _selectedRecipe;
  bool _isLoading = false;
  bool _showRecommended = true;

  List<Recipe> get recipes => _showRecommended ? _recommendedRecipes : _recipes;
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

  Future<void> fetchRecommendedRecipes(String kakaoId) async {
    _isLoading = true;
    notifyListeners();

    _recommendedRecipes = await RecommendService.getRecommendation(kakaoId);
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchData(String kakaoId) async {
    if (_showRecommended) {
      await fetchRecommendedRecipes(kakaoId);
    } else {
      await fetchRecipes();
    }
  }

  void toggleShowRecommended(String kakaoId) {
    _showRecommended = !_showRecommended;
    fetchData(kakaoId);
  }

  void selectRecipe(RecipeDetail recipe) {
    _selectedRecipe = recipe;
    notifyListeners();
  }
}
