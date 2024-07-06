import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fridge/view_model/user_view_model.dart';

class LoginPage extends StatelessWidget {
  final UserViewModel viewModel;

  LoginPage({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            GestureDetector(
              onTap: viewModel.loginWithKakao,
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
