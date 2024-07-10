import 'package:flutter/material.dart';
import 'package:fridge/view/meal_direct_input_page.dart';
import 'package:provider/provider.dart';
import 'package:fridge/view_model/ingredient_view_model.dart';
import 'package:fridge/view_model/user_view_model.dart';
import 'package:fridge/view/add_ingredient_dialog.dart';
import 'package:fridge/view/history_list_view.dart';
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
          backgroundColor: Colors.white,
          title: Text('로그아웃', style: TextStyle(fontSize: 20),),
          content: Text('로그아웃 하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: Text('취소',
              style: TextStyle(color: Theme.of(context).primaryColor),),
            ),
            TextButton(
              onPressed: () {
                final userViewModel = Provider.of<UserViewModel>(context, listen: false);
                userViewModel.logout(context);
                Navigator.of(context).pop(); // 다이얼로그 닫기
              },
              child: Text('확인',
                style: TextStyle(color: Theme.of(context).primaryColor),),
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

  Color _getFreshnessColor(String expirationDate) {
    final now = DateTime.now();
    final expiration = DateTime.parse(expirationDate);
    final difference = expiration.difference(now).inDays;

    if (difference < 0) {
      return Color(0xFF222831); // 검은색
    } else if (difference <= 3) {
      return Color(0xFFF05454); // 빨간색
    } else if (difference <= 7) {
      return Color(0xFFFFC107); // 노란색
    } else {
      return Color(0xFF4CAF50); // 초록색
    }
  }

  String _getCategoryIcon(String category) {
    switch (category) {
      case '과일':
        return 'assets/images/food/image1.png';
      case '채소':
        return 'assets/images/food/image2.png';
      case '쌀/잡곡/견과':
        return 'assets/images/food/image3.png';
      case '정육':
        return 'assets/images/food/image4.png';
      case '계란':
        return 'assets/images/food/image5.png';
      case '수산물':
        return 'assets/images/food/image6.png';
      case '유제품':
        return 'assets/images/food/image7.png';
      case '밀키트':
        return 'assets/images/food/image8.png';
      case '반찬':
        return 'assets/images/food/image9.png';
      case '양념/오일':
        return 'assets/images/food/image10.png';
      case '생수':
        return 'assets/images/food/image11.png';
      case '기타':
        return 'assets/images/food/image12.png';
      default:
        return 'assets/images/food/image12.png'; // 기타로 기본값 설정
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 50.0, left: 16.0, right: 16.0, bottom: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '나의 냉장고',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.history),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HistoryListView()),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (BuildContext context) {
                            return AddIngredientDialog();
                          },
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            Consumer<IngredientViewModel>(
              builder: (context, ingredientViewModel, child) {
                return Column(
                  children: ingredientViewModel.ingredients.map((ingredient) {
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      leading: Image.asset(
                        _getCategoryIcon(ingredient.foodCategory),
                        width: 40,
                        height: 40,
                      ),
                      title: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: ingredient.foodName,
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black),
                            ),
                            TextSpan(
                              text: ' ${ingredient.amount}${ingredient.unit}',
                              style: TextStyle(fontSize: 14, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                      subtitle: Text(
                        '${ingredient.expirationDate.split('-')[0]}년 ${ingredient.expirationDate.split('-')[1]}월 ${ingredient.expirationDate.split('-')[2]}일까지',
                        style: TextStyle(fontSize: 12),
                      ),
                      trailing: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _getFreshnessColor(ingredient.expirationDate),
                        ),
                      ),
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
                  }).toList(),
                );
              },
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                icon: Icon(Icons.logout),
                color: Color(0xFF222831),
                onPressed: _confirmLogout,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MealDirectInputPage(recipeId: 0),
            ),
          );
        },
        label: Text('식사하기'),
        icon: Icon(Icons.fastfood),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
