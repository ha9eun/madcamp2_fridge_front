class Recipe {
  final int id;
  final String name;
  final String description;

  Recipe({required this.id, required this.name, required this.description});

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['recipe_id'],
      name: json['recipe_name'],
      description: json['recipe_content'],
      // ingredients: List<String>.from(json['ingredients']),
    );
  }
}

class RecipeDetail {
  final int recipeId;
  final String recipeName;
  final String recipeContent;
  final List<RecipeIngredient> details;

  RecipeDetail({
    required this.recipeId,
    required this.recipeName,
    required this.recipeContent,
    required this.details,
  });

  factory RecipeDetail.fromJson(Map<String, dynamic> json) {
    var list = json['details'] as List;
    List<RecipeIngredient> detailsList = list.map((i) => RecipeIngredient.fromJson(i)).toList();

    return RecipeDetail(
      recipeId: json['recipe_id'],
      recipeName: json['recipe_name'],
      recipeContent: json['recipe_content'],
      details: detailsList,
    );
  }
}

class RecipeIngredient {
  final int recipeId;
  final String foodName;
  final String unit;
  final int foodId;
  final int amount;

  RecipeIngredient({
    required this.recipeId,
    required this.foodName,
    required this.unit,
    required this.foodId,
    required this.amount,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      recipeId: json['recipe_id'],
      foodName: json['food_name'],
      unit: json['unit'],
      foodId: json['food_id'],
      amount: json['amount'],
    );
  }
}
