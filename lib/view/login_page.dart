import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fridge/view_model/user_view_model.dart';

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
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
            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
