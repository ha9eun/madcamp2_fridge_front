import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config.dart';
import 'recipe_model.dart';
import 'ingredient.dart';
import 'recipe_service.dart';
import 'ingredient_service.dart';

class RecommendService {
  static Future<List<Recipe>> getRecommendation(String kakaoId) async {
    List<Ingredient> ingredients = await IngredientService.fetchIngredients(kakaoId);
    List<Recipe> recipes = await RecipeService.fetchRecipes();
    const apiKey = Config.geminiKey;

    List<Map<String, dynamic>> ingredientList = ingredients.map((e) => {
      'food_id': e.foodId,
      'food_name': e.foodName,
      'amount': e.amount,
      'unit': e.unit,
    }).toList(); 

    List<Map<String, dynamic>> recipeList = recipes.map((e) => {
      'recipe_id': e.id,
      'recipe_name': e.name,
      'ingredients_list': e.description,
    }).toList();

    if (apiKey == null) {
      print('No \$API_KEY environment variable');
      return [];
    }

    final prompt = """
      Given a list of ingredients and a list of recipes, recommend a recipe based on the ingredients.
      Returned text should be a list of recipe id.
      Ingredients: $ingredientList
      Recipes: $recipeList""";

    // The Gemini 1.5 models are versatile and work with both text-only and multimodal prompts
    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);

    // Check if response.text is null
    if (response.text == null) {
      print('Response text is null');
      return [];
    }

    // Extract JSON from response.text
    final jsonStr = response.text!.replaceAll(RegExp(r'[^0-9,\[\]]'), '');

    // Parse the JSON string to extract recipe IDs
    List<int> recommendedRecipeIds = List<int>.from(jsonDecode(jsonStr));

    // Filter the recipes based on the recommended recipe IDs
    List<Recipe> recommendedRecipes = recipes.where((recipe) => recommendedRecipeIds.contains(recipe.id)).toList();

    return recommendedRecipes;
  }
}
