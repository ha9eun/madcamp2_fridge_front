import 'package:http/http.dart' as http;
import 'dart:convert';

import '../config.dart';

class HistoryService {
  static Future<void> addMealHistory(String userId, int recipeId, String dateTime, Map<int, int> selectedAmounts)  async {
    final response = await http.post(
      Uri.parse('${Config.apiUrl}/history/$userId/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'recipe_id': recipeId,
        'time': dateTime,
        'details': selectedAmounts.entries.map((entry) {
          return {
            'food_id': entry.key,
            'amount': entry.value,
          };
        }).toList(),
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add meal history');
    }
  }
}
