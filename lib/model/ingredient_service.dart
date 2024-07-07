import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fridge/config.dart';

import 'ingredient.dart';

class IngredientService {
  static Future<List<Ingredient>> fetchIngredients(String kakaoId) async {
    final response = await http.get(
      Uri.parse('${Config.apiUrl}/fridge/$kakaoId/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      print('재료 정보 불러오기 status code200');
      List<dynamic> json = jsonDecode(utf8.decode(response.bodyBytes));
      return json.map((e) => Ingredient.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load ingredients');
    }
  }

  static Future<List<Map<String, dynamic>>> fetchAllIngredients() async {
    final response = await http.get(
      Uri.parse('${Config.apiUrl}/ingredients/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> json = jsonDecode(utf8.decode(response.bodyBytes));
      return json.map((e) => {
        'food_id': e['food_id'] as int,
        'food_name': e['food_name'] ?? '',
        'food_category': e['food_category'] ?? '',
        'unit': e['unit'] ?? ''
      }).toList();
    } else {
      throw Exception('Failed to load all ingredients');
    }
  }

  static Future<void> addIngredient(String userId, int foodId, int amount, String expirationDate) async {
    final response = await http.post(
      Uri.parse('${Config.apiUrl}/fridge/$userId/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'food_id': foodId,
        'amount': amount,
        'expiration_date': expirationDate,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add ingredient');
    }
  }

  static Future<void> updateIngredient(String userId, int fridgeId, int amount, String expirationDate) async {
    final response = await http.put(
      Uri.parse('${Config.apiUrl}/fridge/ingredients/$fridgeId/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'amount': amount,
        'expiration_date': expirationDate,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update ingredient');
    }
  }

  static Future<void> deleteIngredient(String userId, int foodId) async {
    final response = await http.delete(
      Uri.parse('${Config.apiUrl}/fridge/$userId/$foodId/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete ingredient');
    }
  }

}
