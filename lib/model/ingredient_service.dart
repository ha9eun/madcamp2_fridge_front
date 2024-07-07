import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fridge/config.dart';

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

}


// Ingredient 모델 클래스 추가
class Ingredient {
  final int foodId;
  final String foodName;
  final String foodCategory;
  final int amount;
  final String expirationDate;
  final String unit;

  Ingredient({
    required this.foodId,
    required this.foodName,
    required this.foodCategory,
    required this.amount,
    required this.expirationDate,
    required this.unit,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      foodId: json['food_id'] as int,
      foodName: json['food_name'],
      foodCategory: json['food_category'],
      amount: json['amount'] as int,
      expirationDate: json['expiration_date'],
      unit: json['unit'],
    );
  }
}