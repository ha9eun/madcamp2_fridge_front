import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fridge/view_model/ingredient_view_model.dart';
import 'package:fridge/view_model/user_view_model.dart';
import 'package:flutter/services.dart';

class AddIngredientDialog extends StatefulWidget {
  @override
  _AddIngredientDialogState createState() => _AddIngredientDialogState();
}

class _AddIngredientDialogState extends State<AddIngredientDialog> {
  String? selectedCategory;
  int? selectedFoodId;
  String amount = '';
  String expirationDate = '';
  List<Map<String, dynamic>> filteredIngredients = [];

  @override
  void initState() {
    super.initState();
    _loadIngredients();
  }

  void _loadIngredients() async {
    final ingredientViewModel = Provider.of<IngredientViewModel>(context, listen: false);
    await ingredientViewModel.fetchAllIngredients();
    setState(() {
      filteredIngredients = ingredientViewModel.allIngredients;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ingredientViewModel = Provider.of<IngredientViewModel>(context);
    final userViewModel = Provider.of<UserViewModel>(context);

    return AlertDialog(
      title: Text('재료 추가'),
      content: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            DropdownButtonFormField<String>(
              hint: Text('카테고리 선택'),
              value: selectedCategory,
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                  selectedFoodId = null; // 선택된 음식 ID 초기화
                  filteredIngredients = ingredientViewModel.allIngredients
                      .where((ingredient) => ingredient['food_category'] == value)
                      .toList();
                });
              },
              items: ingredientViewModel.categories
                  .map((category) => DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              ))
                  .toList(),
            ),
            TextField(
              decoration: InputDecoration(labelText: '검색'),
              onChanged: (value) {
                setState(() {
                  filteredIngredients = ingredientViewModel.allIngredients
                      .where((ingredient) =>
                  ingredient['food_category'] == selectedCategory &&
                      ingredient['food_name'].contains(value))
                      .toList();
                });
              },
            ),
            DropdownButtonFormField<int>(
              hint: Text('재료 선택'),
              value: selectedFoodId,
              onChanged: (value) {
                setState(() {
                  selectedFoodId = value;
                });
              },
              items: filteredIngredients
                  .map((ingredient) => DropdownMenuItem<int>(
                value: ingredient['food_id'] as int,
                child: Text(ingredient['food_name'] as String),
              ))
                  .toList(),
            ),
            TextField(
              decoration: InputDecoration(labelText: '양'),
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              onChanged: (value) {
                setState(() {
                  amount = value;
                });
              },
            ),
            TextField(
              decoration: InputDecoration(labelText: '유통기한 (yyyy-mm-dd)'),
              onChanged: (value) {
                setState(() {
                  expirationDate = value;
                });
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('취소'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (selectedFoodId != null && amount.isNotEmpty && expirationDate.isNotEmpty) {
              await ingredientViewModel.addIngredient(
                userViewModel.kakaoId,
                selectedFoodId!,
                int.parse(amount),
                expirationDate,
              );
              Navigator.of(context).pop();
            }
          },
          child: Text('추가'),
        ),
      ],
    );
  }
}
