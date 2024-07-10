import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:fridge/view_model/ingredient_view_model.dart';
import 'package:fridge/view_model/user_view_model.dart';

class AddIngredientDialog extends StatefulWidget {
  @override
  _AddIngredientDialogState createState() => _AddIngredientDialogState();
}

class _AddIngredientDialogState extends State<AddIngredientDialog> {
  String? selectedCategory;
  int? selectedFoodId;
  String amount = '';
  String selectedUnit = ''; // 단위를 저장할 변수 추가
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
          backgroundColor: Colors.white,
          title: Text(title),
          content: Text(content),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                '확인',
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
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

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: Container(
        padding: EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              '재료 추가',
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left, // 텍스트 왼쪽 정렬
            ),
            SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              dropdownColor: Colors.white,
              decoration: InputDecoration(
                labelText: '카테고리 선택',
                prefixIcon: Icon(Icons.category, color: Theme.of(context).primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                ),
              ),
              value: selectedCategory,
              onChanged: (value) {
                setState(() {
                  selectedCategory = value;
                  selectedFoodId = null; // 선택된 음식 ID 초기화
                  selectedUnit = ''; // 선택된 단위 초기화
                  ingredientController.clear(); // 재료 텍스트 필드 초기화
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
            SizedBox(height: 16.0),
            TextField(
              controller: ingredientController,
              focusNode: ingredientFocusNode,
              decoration: InputDecoration(
                labelText: '재료',
                prefixIcon: Icon(Icons.fastfood, color: Theme.of(context).primaryColor),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                ),
              ),
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
            if (isIngredientFieldFocused)
              Container(
                height: 150.0, // 텍스트 입력 중일 때 높이를 고정
                child: filteredIngredients.isNotEmpty
                    ? ListView.builder(
                  itemCount: filteredIngredients.length,
                  itemBuilder: (context, index) {
                    final ingredient = filteredIngredients[index];
                    return ListTile(
                      title: Text(ingredient['food_name']),
                      onTap: () {
                        setState(() {
                          selectedFoodId = ingredient['food_id'];
                          selectedUnit = ingredient['unit']; // 단위 설정
                          ingredientController.text = ingredient['food_name'];
                          isIngredientFieldFocused = false;
                          ingredientFocusNode.unfocus(); // 포커스 제거
                        });
                      },
                    );
                  },
                )
                    : Center(child: Text('No ingredients found')), // 빈 상태일 때 표시할 내용
              ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Flexible(
                  flex: 3, // 줄어든 flex 값
                  child: TextField(
                    decoration: InputDecoration(
                      labelText: '양',
                      prefixIcon: Icon(Icons.scale, color: Theme.of(context).primaryColor),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).primaryColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                      ),
                    ),
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
                ),
                SizedBox(width: 8.0), // 텍스트 필드와 단위 사이의 간격
                Flexible(
                  flex: 1, // 단위 부분을 위한 flex 값
                  child: Text(
                    selectedUnit,
                    style: TextStyle(fontSize: 16, color: Theme.of(context).primaryColor),
                  ),
                ),
                // 단위 표시
              ],
            ),
            SizedBox(height: 16.0),
            Row(
              children: [
                Flexible(
                  flex: 2, // 줄어든 flex 값
                  child: DropdownButtonFormField<int>(
                    dropdownColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: '년',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).primaryColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                      ),
                    ),
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
                SizedBox(width: 8.0),
                Flexible(
                  flex: 2, // 줄어든 flex 값
                  child: DropdownButtonFormField<int>(
                    dropdownColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: '월',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).primaryColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                      ),
                    ),
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
                SizedBox(width: 8.0),
                Flexible(
                  flex: 2, // 줄어든 flex 값
                  child: DropdownButtonFormField<int>(
                    dropdownColor: Colors.white,
                    decoration: InputDecoration(
                      labelText: '일',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).primaryColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                      ),
                    ),
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
            SizedBox(height: 24.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.cancel, color: Theme.of(context).primaryColor),
                  label: Text(
                    '취소',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Theme.of(context).primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    if (selectedFoodId != null &&
                        amount.isNotEmpty &&
                        selectedYear != null &&
                        selectedMonth != null &&
                        selectedDay != null) {
                      final expirationDate =
                          '${selectedYear!}-${selectedMonth!.toString().padLeft(2, '0')}-${selectedDay!.toString().padLeft(2, '0')}';
                      bool success = await ingredientViewModel.addIngredient(
                        userViewModel.kakaoId,
                        selectedFoodId!,
                        int.parse(amount),
                        expirationDate,
                      );
                      if (success) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('재료가 성공적으로 추가되었습니다.'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                      } else {
                        _showAlertDialog('', '이미 냉장고에 존재하는 재료입니다.');
                      }
                    } else {
                      _showAlertDialog('', '모든 필드를 입력해 주세요.');
                    }
                  },
                  icon: Icon(Icons.add, color: Theme.of(context).primaryColor),
                  label: Text(
                    '추가',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: BorderSide(color: Theme.of(context).primaryColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void showAddIngredientDialog(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddIngredientDialog(),
      );
    },
  );
}
