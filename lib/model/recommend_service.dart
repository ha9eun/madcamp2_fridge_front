import 'dart:convert';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../config.dart';
import 'recipe_model.dart';
import 'ingredient.dart';
import 'recipe_service.dart';
import 'ingredient_service.dart';

class RecommendService {
  static Future<List<Recipe>> getRecommendation(
      String kakaoId, String userPrompt) async {
    List<Ingredient> ingredients =
        await IngredientService.fetchIngredients(kakaoId);
    List<Recipe> recipes = await RecipeService.fetchRecipes();
    const apiKey = Config.geminiKey;

    List<Map<String, dynamic>> ingredientList = ingredients
        .map((e) => {
              'food_id': e.foodId,
              'food_name': e.foodName,
              'amount': e.amount,
              'unit': e.unit,
            })
        .toList();

    List<Map<String, dynamic>> recipeList = recipes
        .map((e) => {
              'recipe_id': e.id,
              'recipe_name': e.name,
              'ingredients_list': e.description,
            })
        .toList();

    final prompt = """
      Given a list of ingredients and a list of recipes, recommend a recipe based on the ingredients and the following prompt: $userPrompt.
      Returned text should be a list of recipe id.
      Ingredients: $ingredientList
      Recipes: $recipeList""";

    // The Gemini 1.5 models are versatile and work with both text-only and multimodal prompts
    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);

    final responseText = response.text;
    if (responseText == null) {
      print('Response text is null');
      return [];
    }

    // Extract JSON array from response.text
    final jsonMatch = RegExp(r'\[.*?\]').firstMatch(responseText);
    if (jsonMatch == null) {
      print('No JSON array found in response text');
      return [];
    }

    final jsonStr = jsonMatch.group(0);
    if (jsonStr == null) {
      print('JSON string is null');
      return [];
    }

    // Parse the JSON string to extract recipe IDs
    List<int> recommendedRecipeIds;
    try {
      recommendedRecipeIds = List<int>.from(jsonDecode(jsonStr));
    } catch (e) {
      print('Error parsing JSON: $e');
      return [];
    }

    // Filter the recipes based on the recommended recipe IDs
    List<Recipe> recommendedRecipes = recipes
        .where((recipe) => recommendedRecipeIds.contains(recipe.id))
        .toList();

    return recommendedRecipes;
  }

  static Future<String> getComment(String recipeName) async {
    const apiKey = Config.geminiKey;

    final prompt = """
      Given a recipe name, generate a comment about the recipe, in Korean.
      It would be better if the detailed reason for the recommendation is also given.
      Consider the season being summer, rainy season.
      Make sure that the response does not exceed two paragraphs.
      Recipe name: $recipeName.""";

    // The Gemini 1.5 models are versatile and work with both text-only and multimodal prompts
    final model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);

    return response.text ?? '';
  }
}
