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

  // 유통기한을 DateTime 객체로 변환하는 메서드
  DateTime get expirationDateAsDateTime {
    return DateTime.parse(expirationDate);
  }
}