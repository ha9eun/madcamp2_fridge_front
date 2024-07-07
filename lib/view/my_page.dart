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

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('로그아웃'),
          content: Text('로그아웃 하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                final userViewModel = Provider.of<UserViewModel>(context, listen: false);
                userViewModel.logout(context);
                Navigator.of(context).pop(); // 다이얼로그 닫기
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
    final userViewModel = Provider.of<UserViewModel>(context);
    final ingredientViewModel = Provider.of<IngredientViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${userViewModel.nickname} 님의 냉장고'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _confirmLogout,
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
            child: Consumer<IngredientViewModel>(
              builder: (context, ingredientViewModel, child) {
                return ListView.builder(
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
