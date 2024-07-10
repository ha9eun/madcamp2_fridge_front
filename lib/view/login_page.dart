import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fridge/view_model/user_view_model.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor, // 배경색을 primary 색으로 설정
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Spacer(flex: 2), // 상단 여백 추가
            Image.asset(
              'assets/images/냉장고를 부탁해 배너.png', // 업로드하신 이미지 경로로 변경
              width: 300,
              fit: BoxFit.contain,
            ),
            Spacer(flex: 1), // 이미지와 로그인 버튼 사이의 여백 추가
            GestureDetector(
              onTap: () => userViewModel.loginWithKakao(context),
              child: Container(
                width: 250,
                height: 38,
                child: Image.asset(
                  'assets/images/kakao_login_medium_wide.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Spacer(flex: 2), // 하단 여백 추가
          ],
        ),
      ),
    );
  }
}
