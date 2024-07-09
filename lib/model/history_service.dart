import 'package:http/http.dart' as http;
import 'dart:convert';
import '../model/history_model.dart';
import '../config.dart';

class HistoryService {
  static Future<void> addMealHistory(String userId, int? recipeId, String dateTime, Map<int, int> selectedAmounts)  async {
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

    if (response.statusCode < 200 && response.statusCode >= 300) { // &은 비트 연산자
      throw Exception('Failed to add meal history');
    }
  }

  Future<List<History>> fetchHistory(String userId) async {
    final response = await http.get(Uri.parse('${Config.apiUrl}/history/$userId/'));

    if (response.statusCode == 200) {
      List jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
      return jsonResponse.map((history) => History.fromJson(history)).toList();
    } else {
      throw Exception('Failed to load history');
    }
  }
}
