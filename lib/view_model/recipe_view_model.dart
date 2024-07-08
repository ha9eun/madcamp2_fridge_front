import 'package:flutter/material.dart';
import '../model/recipe_model.dart';
import '../model/recipe_service.dart';
import '../model/recommend_service.dart';

class RecipeViewModel extends ChangeNotifier {
  List<Recipe> _allRecipes = [];
  List<Recipe> _recommendedRecipes = [];
  RecipeDetail? _selectedRecipe;
  bool _isLoading = false;
  bool _showRecommended = false;
  String _aiComment = '';
  List<RecipeIngredient> _recipeDetails = [];

  List<Recipe> get recipes => _showRecommended ? _recommendedRecipes : _allRecipes;
  RecipeDetail? get selectedRecipe => _selectedRecipe;
  bool get isLoading => _isLoading;
  String get aiComment => _aiComment;

  Future<void> fetchRecipes() async {
    _isLoading = true;
    notifyListeners();

    _allRecipes = await RecipeService.fetchRecipes();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchRecommendedRecipes(String kakaoId, String prompt) async {
    _isLoading = true;
    notifyListeners();

    _recommendedRecipes = await RecommendService.getRecommendation(kakaoId, prompt);
    _showRecommended = true;
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchRecipeDetail(int recipeId) async {
    _isLoading = true;
    notifyListeners();

    _selectedRecipe = await RecipeService.fetchRecipeDetail(recipeId);
    if (_selectedRecipe != null) {
      _recipeDetails = _selectedRecipe!.details;
    }
    
    _isLoading = false;
    notifyListeners();
  }

  void showAllRecipes() {
    _showRecommended = false;
    notifyListeners();
  }

  void selectRecipe(RecipeDetail recipe) {
    _selectedRecipe = recipe;
    notifyListeners();
  }

  void setAiComment(String comment) {
    _aiComment = comment;
    notifyListeners();
  }

  List<String> getIngredientNames() {
    if (_selectedRecipe != null) {
      return _selectedRecipe!.details.map((detail) => detail.foodName).toList();
    }
    return [];
  }
}
