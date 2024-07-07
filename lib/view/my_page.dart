import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fridge/view_model/ingredient_view_model.dart';
import 'package:fridge/view_model/user_view_model.dart';
import 'package:fridge/view/add_ingredient_dialog.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  @override
  void initState() {
    super.initState();
    _loadIngredients();
  }

  void _loadIngredients() async {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final ingredientViewModel = Provider.of<IngredientViewModel>(context, listen: false);
    await ingredientViewModel.fetchIngredients(userViewModel.kakaoId);
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context);
    final ingredientViewModel = Provider.of<IngredientViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${userViewModel.nickname} 님의 냉장고'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // 설정 페이지로 이동
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '나의 냉장고 재료',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () async {
                    await ingredientViewModel.fetchAllIngredients();
                    showDialog(
                      context: context,
                      builder: (context) => AddIngredientDialog(),
                    ).then((_) {
                      // 다이얼로그가 닫힌 후 재료 목록을 다시 불러옴
                      _loadIngredients();
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: ingredientViewModel.ingredients.length,
              itemBuilder: (context, index) {
                final ingredient = ingredientViewModel.ingredients[index];
                return ListTile(
                  title: Text(ingredient.foodName),
                  subtitle: Text('양: ${ingredient.amount} ${ingredient.unit}, 유통기한: ${ingredient.expirationDate}'),
                  onTap: () {
                    // 상세 정보 보기
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
