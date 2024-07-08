import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fridge/view_model/ingredient_view_model.dart';
import 'package:fridge/view_model/user_view_model.dart';
import 'package:fridge/view/add_ingredient_dialog.dart';

import '../model/ingredient.dart';
import '../model/ingredient_service.dart';
import 'edit_ingredient_dialog.dart';

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

  void _editIngredient(BuildContext context, Ingredient ingredient) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditIngredientDialog(ingredient: ingredient);
      },
    );
  }

  void _deleteIngredient(BuildContext context, Ingredient ingredient) {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final ingredientViewModel = Provider.of<IngredientViewModel>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('삭제'),
          content: Text('정말로 이 재료를 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                await ingredientViewModel.deleteIngredient(userViewModel.kakaoId, ingredient.fridgeId);
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
                    showDialog(
                      context: context,
                      builder: (context) => AddIngredientDialog(),
                    );
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
                      onLongPress: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  ListTile(
                                    leading: Icon(Icons.edit),
                                    title: Text('수정'),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      _editIngredient(context, ingredient);
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.delete),
                                    title: Text('삭제'),
                                    onTap: () {
                                      Navigator.of(context).pop();
                                      _deleteIngredient(context, ingredient);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        );
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
