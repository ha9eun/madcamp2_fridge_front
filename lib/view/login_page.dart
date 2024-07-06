import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fridge/view_model/user_view_model.dart';
import 'package:fridge/view/home_page.dart';

class LoginPage extends StatelessWidget {
  final UserViewModel viewModel;

  LoginPage({required this.viewModel});

  void _loginAndNavigate(BuildContext context) async {
    bool success = await viewModel.loginWithKakao();
    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      // 로그인 실패 처리 (예: 에러 메시지 표시)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인에 실패했습니다. 다시 시도해주세요.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            GestureDetector(
              onTap: () => _loginAndNavigate(context),
              child: Image.asset('assets/images/kakao_login_medium_wide.png',
                width: 300,
                height: 45,
              ),
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
