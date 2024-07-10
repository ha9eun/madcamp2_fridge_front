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
  Map<int, TextEditingController> controllers = {};
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
        if (fridgeIngredient.fridgeId != 0) { // 일치하는 재료이면
          //레시피 양보다 냉장고 양이 적을 때 처리해서 기본값으로 저장
          selectedAmounts[fridgeIngredient.foodId] = fridgeIngredient.amount < ingredient.amount
              ? fridgeIngredient.amount
              : ingredient.amount;

          // TextEditingController 생성 및 기본값 설정
          controllers[fridgeIngredient.foodId] = TextEditingController(
            text: selectedAmounts[fridgeIngredient.foodId].toString(),
          );
        }
      } //for
    }
  }

  void _validateAmount(int foodId, int maxAmount, String value) {
    int? newValue = int.tryParse(value);
    setState(() {
      if (newValue == null || newValue <= 0) {
        errorMessages[foodId] = '올바른 값을 입력해 주세요';
      } else if (newValue > maxAmount) {
        errorMessages[foodId] = '남은 양을 초과할 수 없습니다';
      } else {
        errorMessages[foodId] = '';
        selectedAmounts[foodId] = newValue;
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
      body: Padding(
        padding: const EdgeInsets.only(top: 50.0, left: 16.0, right: 16.0, bottom: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer<RecipeViewModel>(
                builder: (context, recipeViewModel, child) {
                  if (recipeViewModel.isLoading) {
                    return CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                    );
                  } else if (recipeViewModel.recipes.isEmpty) {
                    return Text('레시피가 없습니다.');
                  } else {
                    return DropdownButtonFormField<Recipe>(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12), // 모서리 둥글게
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12), // 모서리 둥글게
                          borderSide: BorderSide(color: Theme.of(context).primaryColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12), // 모서리 둥글게
                          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                        ),
                      ),
                      dropdownColor: Colors.white,
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
                        activeColor: Theme.of(context).primaryColor,
                        value: selectedAmounts.containsKey(ingredient.foodId),
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) { //check
                              selectedAmounts[ingredient.foodId] = 1;
                              errorMessages[ingredient.foodId] = '';
                              controllers[ingredient.foodId] = TextEditingController(
                                text: '1',
                              );
                            } else {
                              selectedAmounts.remove(ingredient.foodId);
                              errorMessages.remove(ingredient.foodId);
                              controllers.remove(ingredient.foodId);
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
                          Text('남은 양: ${ingredient.amount}${ingredient.unit}'),
                          if (errorMessages.containsKey(ingredient.foodId) && errorMessages[ingredient.foodId]!.isNotEmpty)
                            Text(
                              errorMessages[ingredient.foodId]!,
                              style: TextStyle(color: Colors.red, fontSize: 12),
                            ),
                        ],
                      ),
                      trailing: selectedAmounts.containsKey(ingredient.foodId)
                          ? SizedBox(
                        width: 50,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0), // 오른쪽에 8.0의 패딩 추가
                          child: TextField(
                            controller: controllers[ingredient.foodId],
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: '양',
                              suffixText: ingredient.unit,
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2), // 기본 테두리 색과 굵기
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2), // 포커스된 테두리 색과 굵기
                              ),
                            ),
                            onChanged: (value) {
                              _validateAmount(ingredient.foodId, ingredient.amount, value);
                            },
                          ),
                        ),
                      )
                          : null,
                    );
                  },
                ),
              ),
              Align(
                alignment: Alignment.centerRight, // 버튼을 오른쪽으로 정렬
                child: ElevatedButton(
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
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: Theme.of(context).primaryColor, // 글자 색상
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16), // 패딩
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // 모서리 둥글게
                    ),
                    elevation: 5, // 그림자
                  ),
                  child: Text(
                    '식사 완료',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              )


            ],
          ),
        ),
      ),
    );
  }
}
