import 'package:flutter/material.dart';
import 'package:fridge/model/ingredient_service.dart';
import 'package:fridge/model/ingredient.dart';

class IngredientViewModel extends ChangeNotifier {
  List<Ingredient> _ingredients = [];
  List<Map<String, dynamic>> _allIngredients = [];

  List<Ingredient> get ingredients => _ingredients;
  List<Map<String, dynamic>> get allIngredients => _allIngredients;

  Future<void> fetchIngredients(String kakaoId) async {
    try {
      _ingredients = await IngredientService.fetchIngredients(kakaoId);
      _ingredients.sort((a, b) => a.expirationDateAsDateTime.compareTo(b.expirationDateAsDateTime));
      notifyListeners();
    } catch (error) {
      print('나의 재료 정보 불러오기 실패 $error');
    }
  }

  Future<void> fetchAllIngredients() async {
    try {
      _allIngredients = await IngredientService.fetchAllIngredients();
      notifyListeners();
    } catch (error) {
      print('모든 재료 정보 불러오기 실패 $error');
    }
  }

  Future<void> updateIngredient(String userId, int fridgeId, int amount, String expirationDate) async {
    try {
      await IngredientService.updateIngredient(userId, fridgeId, amount, expirationDate);
      await fetchIngredients(userId); // 재료 수정 후 다시 불러오기
      notifyListeners();
    } catch (error) {
      print('재료 수정 실패 $error');
    }
  }

  Future<void> deleteIngredient(String userId, int fridgeId) async {
    try {
      await IngredientService.deleteIngredient(fridgeId);
      await fetchIngredients(userId); // 재료 삭제 후 다시 불러오기
      notifyListeners();
    } catch (error) {
      print('재료 삭제 실패 $error');
    }
  }

  Future<void> addIngredient(String userId, int foodId, int amount, String expirationDate) async {
    try {
      await IngredientService.addIngredient(userId, foodId, amount, expirationDate);
      // 재료 추가 후 다시 불러오기
      await fetchIngredients(userId);
      notifyListeners();
    } catch (error) {
      print('재료 추가 실패 $error');
    }
  }

  List<String> get categories {
    return _allIngredients.map((ingredient) => ingredient['food_category'] as String).toSet().toList();
  }
}
