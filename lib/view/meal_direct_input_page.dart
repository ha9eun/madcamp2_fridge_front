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
  Map<int, String> errorMessages = {};
  Recipe? selectedRecipe;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    final recipeViewModel = Provider.of<RecipeViewModel>(context, listen: false);
    if (widget.recipeId != 0) { // 레시피탭에서 들어간 경우
      recipeViewModel.fetchRecipeDetail(widget.recipeId).then((_) {
        setState(() {
          selectedRecipe = recipeViewModel.recipes.firstWhere((recipe) => recipe.id == widget.recipeId);
          _setSelectedRecipeDetail(recipeViewModel);
        });
      });
    } else { // 마이페이지탭
      recipeViewModel.fetchRecipes();
    }
  }

  void _setSelectedRecipeDetail(RecipeViewModel recipeViewModel) {
    final selectedRecipeDetail = recipeViewModel.selectedRecipe;
    if (selectedRecipeDetail != null) {
      final ingredientViewModel = Provider.of<IngredientViewModel>(context, listen: false);
      for (var ingredient in selectedRecipeDetail.details) { //레시피에 들어가는 재료 for문
        final fridgeIngredient = ingredientViewModel.ingredients.firstWhere( // 일치하는 재료 있으면 저장
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
        if (fridgeIngredient.amount > 0) { // 일치하는 재료이면
          //레시피 양보다 냉장고 양이 적을 때 처리해서 기본값으로 저장
          selectedAmounts[fridgeIngredient.fridgeId] = fridgeIngredient.amount < ingredient.amount
              ? fridgeIngredient.amount
              : ingredient.amount;
        }
      } //for
    }
  }

  void _validateAmount(int fridgeId, int maxAmount, String value) {
    int? newValue = int.tryParse(value);
    setState(() {
      if (newValue == null || newValue <= 0) {
        errorMessages[fridgeId] = '올바른 값을 입력해 주세요';
      } else if (newValue > maxAmount) {
        errorMessages[fridgeId] = '남은 양을 초과할 수 없습니다';
      } else {
        errorMessages[fridgeId] = '';
        selectedAmounts[fridgeId] = newValue;
      }
    });
  }

  bool _hasValidationErrors() {
    return errorMessages.values.any((message) => message.isNotEmpty);
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
        child: Form(
          key: _formKey,
          child: Column( //자식을 수직으로 표시
            crossAxisAlignment: CrossAxisAlignment.start, //왼쪽 정렬
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
                            _setSelectedRecipeDetail(recipeViewModel);
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
                            if (value == true) { //check
                              selectedAmounts[ingredient.fridgeId] = 0;
                              errorMessages[ingredient.fridgeId] = '';
                            } else {
                              selectedAmounts.remove(ingredient.fridgeId);
                              errorMessages.remove(ingredient.fridgeId);
                            }
                          });
                        },
                      ),
                      title: Text(
                        ingredient.foodName,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('남은 양: ${ingredient.amount} ${ingredient.unit}, 유통기한: ${ingredient.expirationDate}'),
                          if (errorMessages.containsKey(ingredient.fridgeId) && errorMessages[ingredient.fridgeId]!.isNotEmpty)
                            Text(
                              errorMessages[ingredient.fridgeId]!,
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                        ],
                      ),
                      trailing: selectedAmounts.containsKey(ingredient.fridgeId)
                          ? SizedBox(
                        width: 100,
                        child: TextField(
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '양',
                            suffixText: ingredient.unit,
                          ),
                          onChanged: (value) {
                            _validateAmount(ingredient.fridgeId, ingredient.amount, value);
                          },
                        ),
                      )
                          : null,
                    );
                  },
                ),
              ),
               ElevatedButton(
                onPressed: () async {
                  if (!_hasValidationErrors()) {
                    try {
                      await ingredientViewModel.recordMeal(context, userViewModel.kakaoId, selectedRecipe?.id, selectedAmounts);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('식사 기록 완료')),
                      );
                      Navigator.pop(context);
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('식사 기록 실패: $error')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('입력한 값에 오류가 있습니다.')),
                    );
                  }
                },
                child: Text('식사 완료'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
