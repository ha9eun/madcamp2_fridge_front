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
  int? selectedYear;
  int? selectedMonth;
  int? selectedDay;
  List<Map<String, dynamic>> filteredIngredients = [];
  bool isIngredientFieldFocused = false;
  TextEditingController ingredientController = TextEditingController();
  FocusNode ingredientFocusNode = FocusNode();

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
  void dispose() {
    ingredientController.dispose();
    ingredientFocusNode.dispose();
    super.dispose();
  }

  List<int> _getDaysInMonth(int year, int month) {
    return List<int>.generate(DateUtils.getDaysInMonth(year, month), (i) => i + 1);
  }

  void _showAlertDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
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
              controller: ingredientController,
              focusNode: ingredientFocusNode,
              decoration: InputDecoration(labelText: '재료'),
              onTap: () {
                setState(() {
                  isIngredientFieldFocused = true;
                });
              },
              onChanged: (value) {
                setState(() {
                  filteredIngredients = ingredientViewModel.allIngredients
                      .where((ingredient) =>
                  ingredient['food_category'] == selectedCategory &&
                      ingredient['food_name'].toLowerCase().contains(value.toLowerCase()))
                      .toList();
                });
              },
            ),
            if (isIngredientFieldFocused && filteredIngredients.isNotEmpty)
              Container(
                height: 150.0,
                child: ListView.builder(
                  itemCount: filteredIngredients.length,
                  itemBuilder: (context, index) {
                    final ingredient = filteredIngredients[index];
                    return ListTile(
                      title: Text(ingredient['food_name']),
                      onTap: () {
                        setState(() {
                          selectedFoodId = ingredient['food_id'];
                          ingredientController.text = ingredient['food_name'];
                          isIngredientFieldFocused = false;
                          ingredientFocusNode.unfocus(); // 포커스 제거
                        });
                      },
                    );
                  },
                ),
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
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    hint: Text('년'),
                    value: selectedYear,
                    onChanged: (value) {
                      setState(() {
                        selectedYear = value;
                        if (selectedMonth != null) {
                          selectedDay = null;
                        }
                      });
                    },
                    items: List.generate(11, (index) => DateTime.now().year + index)
                        .map((year) => DropdownMenuItem<int>(
                      value: year,
                      child: Text(year.toString()),
                    ))
                        .toList(),
                  ),
                ),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    hint: Text('월'),
                    value: selectedMonth,
                    onChanged: (value) {
                      setState(() {
                        selectedMonth = value;
                        selectedDay = null;
                      });
                    },
                    items: List.generate(12, (index) => index + 1)
                        .map((month) => DropdownMenuItem<int>(
                      value: month,
                      child: Text(month.toString()),
                    ))
                        .toList(),
                  ),
                ),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    hint: Text('일'),
                    value: selectedDay,
                    onChanged: (value) {
                      setState(() {
                        selectedDay = value;
                      });
                    },
                    items: selectedYear != null && selectedMonth != null
                        ? _getDaysInMonth(selectedYear!, selectedMonth!)
                        .map((day) => DropdownMenuItem<int>(
                      value: day,
                      child: Text(day.toString()),
                    ))
                        .toList()
                        : [],
                  ),
                ),
              ],
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
            if (selectedFoodId != null &&
                amount.isNotEmpty &&
                selectedYear != null &&
                selectedMonth != null &&
                selectedDay != null) {
              final expirationDate = '${selectedYear!}-${selectedMonth!.toString().padLeft(2, '0')}-${selectedDay!.toString().padLeft(2, '0')}';
              bool success = await ingredientViewModel.addIngredient(
                userViewModel.kakaoId,
                selectedFoodId!,
                int.parse(amount),
                expirationDate,
              );
              if (success) {
                Navigator.of(context).pop();
              } else {
                _showAlertDialog('경고', '이미 냉장고에 존재하는 재료입니다.');
              }
            } else {
              _showAlertDialog('경고', '모든 필드를 입력해 주세요.');
            }
          },
          child: Text('추가'),
        ),
      ],
    );
  }
}
