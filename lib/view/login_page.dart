import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fridge/view_model/user_view_model.dart';
import 'package:fridge/view/home_page.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context);

    void _loginAndNavigate() async {
      bool success = await userViewModel.loginWithKakao();
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

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            GestureDetector(
              onTap: _loginAndNavigate,
              child: Container(
                width: 250,
                height: 38,
                child: Image.asset(
                  'assets/images/kakao_login_button.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
