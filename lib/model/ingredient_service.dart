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
      List<dynamic> json = jsonDecode(utf8.decode(response.bodyBytes));
      return json.map((e) => Ingredient.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load ingredients');
    }
  }
}

// Ingredient 모델 클래스 추가
class Ingredient {
  final int foodId;
  final String foodName;
  final int amount;
  final String expirationDate;
  final String unit;

  Ingredient({
    required this.foodId,
    required this.foodName,
    required this.amount,
    required this.expirationDate,
    required this.unit,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) {
    return Ingredient(
      foodId: json['food_id'],
      foodName: json['food_name'],
      amount: json['amount'],
      expirationDate: json['expiration_date'],
      unit: json['unit'],
    );
  }
}
