class HistoryDetail {
  final int detailId;
  final int foodId;
  final int amount;
  final String foodName;
  final String unit;

  HistoryDetail({
    required this.detailId,
    required this.foodId,
    required this.amount,
    required this.foodName,
    required this.unit,
  });

  factory HistoryDetail.fromJson(Map<String, dynamic> json) {
    return HistoryDetail(
      detailId: json['detail_id'],
      foodId: json['food_id'],
      amount: json['amount'],
      foodName: json['food_name'],
      unit: json['unit'],
    );
  }
}

class History {
  final int historyId;
  final String userId;
  final int? recipeId;
  final DateTime time;
  final String recipeName;
  final List<HistoryDetail> ingredients;

  History({
    required this.historyId,
    required this.userId,
    this.recipeId,
    required this.time,
    required this.recipeName,
    required this.ingredients,
  });

  factory History.fromJson(Map<String, dynamic> json) {
    var ingredientsJson = json['ingredients'] as List;
    List<HistoryDetail> ingredientsList = ingredientsJson.map((i) => HistoryDetail.fromJson(i)).toList();

    return History(
      historyId: json['history_id'],
      userId: json['user_id'],
      recipeId: json['recipe_id'],
      time: DateTime.parse(json['time']),
      recipeName: json['recipe_name'],
      ingredients: ingredientsList,
    );
  }
}
