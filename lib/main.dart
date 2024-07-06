import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Flutter와 네이티브 플랫폼 간의 상호작용
import 'package:fridge/view/login_page.dart';
import 'package:fridge/view_model/user_view_model.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:fridge/config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  KakaoSdk.init(nativeAppKey: Config.appKey); // 카카오 sdk 초기화

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LoginPage(viewModel: UserViewModel()),
    );
  }
}


