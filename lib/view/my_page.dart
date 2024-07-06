import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fridge/view_model/user_view_model.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context);

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

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20), // 위쪽 여백 추가
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: Icon(Icons.settings, color: Colors.deepPurple),
                onPressed: () {
                  // 설정 페이지로 이동
                },
              ),
            ),
            SizedBox(height: 20), // 설정 버튼 아래 여백 추가
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
            Divider(), // 구분선 추가
            // 필요한 추가 내용 여기에 추가
          ],
        ),
      ),
    );
  }
}
