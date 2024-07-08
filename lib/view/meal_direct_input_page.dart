import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fridge/view_model/ingredient_view_model.dart';

class MealDirectInputPage extends StatefulWidget {
  @override
  _MealDirectInputPageState createState() => _MealDirectInputPageState();
}

class _MealDirectInputPageState extends State<MealDirectInputPage> {
  Map<int, int> selectedAmounts = {};

  @override
  Widget build(BuildContext context) {
    final ingredientViewModel = Provider.of<IngredientViewModel>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '냉장고 재료 목록',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: ingredientViewModel.ingredients.length,
              itemBuilder: (context, index) {
                final ingredient = ingredientViewModel.ingredients[index];
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(horizontal: 0.0), // 좌우 여백 최소화
                  leading: Checkbox(
                    value: selectedAmounts.containsKey(ingredient.fridgeId),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedAmounts[ingredient.fridgeId] = 1; // 기본값 설정
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
            onPressed: () {
              // 선택된 재료와 사용량을 서버로 전송하고, 냉장고 재료 업데이트 및 history 저장
              ingredientViewModel.recordMeal(context, selectedAmounts).then((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('식사 기록 완료')),
                );
                Navigator.pop(context); // 마이페이지로 돌아가기
              }).catchError((error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('식사 기록 실패: $error')),
                );
              });
            },
            child: Text('식사 완료'),
          ),
        ],
      ),
    );
  }
}
