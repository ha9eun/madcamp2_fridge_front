import 'package:flutter/material.dart';
import 'package:fridge/view_model/ingredient_view_model.dart';
import 'package:provider/provider.dart';
import 'package:fridge/view_model/user_view_model.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context);
    final ingredientViewModel = Provider.of<IngredientViewModel>(context);

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

    // 페이지 로드 시 재료 정보 불러오기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (userViewModel.kakaoId.isNotEmpty) {
        ingredientViewModel.fetchIngredients(userViewModel.kakaoId);
      }
    });

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20),
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(Icons.settings, color: Colors.deepPurple),
                onPressed: () {
                  // 설정 페이지로 이동
                },
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  '${userViewModel.nickname} 님',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.logout, color: Colors.deepPurple),
                  onPressed: _confirmLogout,
                ),
              ],
            ),
            SizedBox(height: 20),
            Divider(),
            // "나의 냉장고 재료" 리스트 표시
            Text('나의 냉장고 재료', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: ingredientViewModel.ingredients.length,
                itemBuilder: (context, index) {
                  final ingredient = ingredientViewModel.ingredients[index];
                  return ListTile(
                    title: Text(ingredient.foodName),
                    onTap: () {
                      // 재료 상세 정보 페이지로 이동 (필요시 구현)
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
