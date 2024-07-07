import 'package:flutter/material.dart';
import 'package:fridge/model/ingredient_service.dart';

class IngredientViewModel extends ChangeNotifier {
  List<Ingredient> _ingredients = [];

  List<Ingredient> get ingredients => _ingredients;

  Future<void> fetchIngredients(String kakaoId) async {
    try {
      _ingredients = await IngredientService.fetchIngredients(kakaoId);
      notifyListeners();
    } catch (error) {
      print('재료 정보 불러오기 실패 $error');
    }
  }
}
