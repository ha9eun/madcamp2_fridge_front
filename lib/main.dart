import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Flutter와 네이티브 플랫폼 간의 상호작용
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  KakaoSdk.init(nativeAppKey: '1c1884724b665157347d412727279fcb'); // 카카오 sdk 초기화

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
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  Future<void> _loginWithKakao() async {
    try {
      bool isInstalled = await isKakaoTalkInstalled();
      if (isInstalled) {
        try {
          OAuthToken token = await UserApi.instance.loginWithKakaoTalk();
          print('카카오톡으로 로그인 성공 ${token.accessToken}');
          await _getUserInfoAndSendToServer(token);
        } catch (error) {
          print('카카오톡으로 로그인 실패 $error');
          if (error is PlatformException && error.code == 'CANCELED') {
            return;
          }
        }
      } else {
        try {
          OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
          print('카카오계정으로 로그인 성공 ${token.accessToken}');
          await _getUserInfoAndSendToServer(token);
        } catch (error) {
          print('카카오계정으로 로그인 실패 $error');
        }
      }
    } catch (error) {
      print('카카오톡 설치 여부 확인 실패 $error');
    }
  }

  Future<void> _getUserInfoAndSendToServer(OAuthToken token) async {
    try {
      User user = await UserApi.instance.me();
      await _sendUserInfoToServer(user, token);
    } catch (error) {
      print('사용자 정보 요청 실패 $error');
    }
  }

  Future<void> _sendUserInfoToServer(User user, OAuthToken token) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/kakao/save_user/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'kakao_id': user.id.toString(),
        'nickname': user.kakaoAccount.profile.nickname ?? '',
      }),
    );

    if (response.statusCode == 200) {
      print('사용자 정보 저장 성공');
    } else {
      print('사용자 정보 저장 실패');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loginWithKakao,
              child: const Text('카카오 로그인'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
