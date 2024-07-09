import 'package:flutter/material.dart';
import 'package:fridge/view_model/user_view_model.dart';
import 'package:provider/provider.dart';
import 'package:fridge/view_model/ingredient_view_model.dart';
import 'package:fridge/view_model/recipe_view_model.dart';
import 'package:fridge/model/recipe_model.dart';

import '../model/ingredient.dart';

class MealDirectInputPage extends StatefulWidget {
  final int recipeId;

  MealDirectInputPage({required this.recipeId});

  @override
  _MealDirectInputPageState createState() => _MealDirectInputPageState();
}

class _MealDirectInputPageState extends State<MealDirectInputPage> {
  Map<int, int> selectedAmounts = {};
  Recipe? selectedRecipe;

  @override
  void initState() {
    super.initState();
    final recipeViewModel = Provider.of<RecipeViewModel>(context, listen: false);
    if (widget.recipeId != 0) {
      recipeViewModel.fetchRecipeDetail(widget.recipeId).then((_) {
        setState(() {
          selectedRecipe = recipeViewModel.recipes.firstWhere((recipe) => recipe.id == widget.recipeId);
          final selectedRecipeDetail = recipeViewModel.selectedRecipe;
          if (selectedRecipeDetail != null) {
            final ingredientViewModel = Provider.of<IngredientViewModel>(context, listen: false);
            for (var ingredient in selectedRecipeDetail.details) {
              final fridgeIngredient = ingredientViewModel.ingredients.firstWhere(
                    (fridgeItem) => fridgeItem.foodId == ingredient.foodId,
                orElse: () => Ingredient(
                  fridgeId: 0,
                  foodId: ingredient.foodId,
                  foodName: ingredient.foodName,
                  amount: 0,
                  expirationDate: '',
                  unit: ingredient.unit,
                  foodCategory: '',
                ),
              );
              if (fridgeIngredient.amount > 0) {
                selectedAmounts[fridgeIngredient.fridgeId] = fridgeIngredient.amount < ingredient.amount
                    ? fridgeIngredient.amount
                    : ingredient.amount;
              }
            }
          }
        });
      });
    } else {
      recipeViewModel.fetchRecipes();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ingredientViewModel = Provider.of<IngredientViewModel>(context);
    final userViewModel = Provider.of<UserViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('식사하기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '냉장고 재료 목록',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Consumer<RecipeViewModel>(
              builder: (context, recipeViewModel, child) {
                if (recipeViewModel.isLoading) {
                  return CircularProgressIndicator();
                } else if (recipeViewModel.recipes.isEmpty) {
                  return Text('레시피가 없습니다.');
                } else {
                  return DropdownButton<Recipe>(
                    hint: Text('레시피 선택'),
                    value: selectedRecipe,
                    onChanged: (Recipe? newValue) async {
                      if (newValue != null) {
                        await recipeViewModel.fetchRecipeDetail(newValue.id);
                        setState(() {
                          selectedRecipe = newValue;
                          final selectedRecipeDetail = recipeViewModel.selectedRecipe;
                          selectedAmounts.clear();
                          for (var ingredient in selectedRecipeDetail!.details) {
                            final fridgeIngredient = ingredientViewModel.ingredients.firstWhere(
                                  (fridgeItem) => fridgeItem.foodId == ingredient.foodId,
                              orElse: () => Ingredient(
                                fridgeId: 0,
                                foodId: ingredient.foodId,
                                foodName: ingredient.foodName,
                                amount: 0,
                                expirationDate: '',
                                unit: ingredient.unit,
                                foodCategory: '',
                              ),
                            );
                            if (fridgeIngredient.amount > 0) {
                              selectedAmounts[fridgeIngredient.fridgeId] = fridgeIngredient.amount < ingredient.amount
                                  ? fridgeIngredient.amount
                                  : ingredient.amount;
                            }
                          }
                        });
                      }
                    },
                    items: recipeViewModel.recipes.map((Recipe recipe) {
                      return DropdownMenuItem<Recipe>(
                        value: recipe,
                        child: Text(recipe.name),
                      );
                    }).toList(),
                  );
                }
              },
            ),
            Expanded(
              child: ListView.builder(
                itemCount: ingredientViewModel.ingredients.length,
                itemBuilder: (context, index) {
                  final ingredient = ingredientViewModel.ingredients[index];
                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 0.0),
                    leading: Checkbox(
                      value: selectedAmounts.containsKey(ingredient.fridgeId),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedAmounts[ingredient.fridgeId] = 1;
                          } else {
                            selectedAmounts.remove(ingredient.fridgeId);
                          }
                        });
                      },
                    ),
                    title: Text(
                      ingredient.foodName,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '남은 양: ${ingredient.amount} ${ingredient.unit}, 유통기한: ${ingredient.expirationDate}',
                    ),
                    trailing: selectedAmounts.containsKey(ingredient.fridgeId)
                        ? DropdownButton<int>(
                      value: selectedAmounts[ingredient.fridgeId],
                      onChanged: (int? newValue) {
                        setState(() {
                          selectedAmounts[ingredient.fridgeId] = newValue!;
                        });
                      },
                      items: List.generate(
                        ingredient.amount,
                            (index) => DropdownMenuItem(
                          value: index + 1,
                          child: Text('${index + 1} ${ingredient.unit}'),
                        ),
                      ),
                    )
                        : null,
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ingredientViewModel.recordMeal(context, userViewModel.kakaoId, selectedRecipe!.id, selectedAmounts);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('식사 기록 완료')),
                  );
                  Navigator.pop(context);
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('식사 기록 실패: $error')),
                  );
                }
              },
              child: Text('식사 완료'),
            ),
          ],
        ),
      ),
    );
  }
}
