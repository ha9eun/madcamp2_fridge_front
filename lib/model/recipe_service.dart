import 'dart:convert';
import 'package:http/http.dart' as http;
import 'recipe_model.dart';
import '../config.dart';

class RecipeService {
  static Future<List<Recipe>> fetchRecipes() async {
    final response = await http.get(Uri.parse('${Config.apiUrl}/recipes/'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((recipe) => Recipe.fromJson(recipe)).toList();
    } else {
      throw Exception('Failed to load recipes');
    }
  }

  static Future<RecipeDetail> fetchRecipeDetail(int recipeId) async {
    final response = await http.get(Uri.parse('${Config.apiUrl}/recipes/$recipeId'));

    if (response.statusCode == 200) {
      return RecipeDetail.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load recipe detail');
    }
  }
}
