import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/user_view_model.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('마이페이지'),
        backgroundColor: Colors.deepPurple, // 앱바 배경색
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // 설정 페이지로 이동
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 좌측 정렬
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                  onPressed: () {
                    // 로그아웃 기능 구현
                  },
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
