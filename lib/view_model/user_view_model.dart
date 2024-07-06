import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fridge/model/user_service.dart';
import 'package:fridge/view/home_page.dart';
import 'package:fridge/view/login_page.dart';

class UserViewModel extends ChangeNotifier {
  int _counter = 0;
  int get counter => _counter;

  String _nickname = '';
  String _kakaoId = '';
  bool _isLoading = true;

  String get nickname => _nickname;
  String get kakaoId => _kakaoId;
  bool get isLoading => _isLoading;

  UserViewModel() {
    _loadUserInfo();
  }

  void incrementCounter() {
    _counter++;
    notifyListeners();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    _nickname = prefs.getString('nickname') ?? '';
    _kakaoId = prefs.getString('kakao_id') ?? '';
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _saveUserInfo(String nickname, String kakaoId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nickname', nickname);
    await prefs.setString('kakao_id', kakaoId);
  }

  Future<void> _clearUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('nickname');
    await prefs.remove('kakao_id');
  }

  Future<bool> _fetchAndSaveUserInfo() async {
    try {
      User user = await UserApi.instance.me();
      _nickname = user.kakaoAccount?.profile?.nickname ?? '';
      _kakaoId = user.id.toString();
      await _saveUserInfo(_nickname, _kakaoId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      print('사용자 정보 요청 실패 $error');
      return false;
    }
  }

  Future<void> checkLoginStatus(BuildContext context) async {
    try {
      var tokenInfo = await UserApi.instance.accessTokenInfo();
      if (tokenInfo != null) {
        // 액세스 토큰이 유효하면 홈 화면으로 이동
        bool success = await _fetchAndSaveUserInfo();
        if (success) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
      }
    } catch (error) {
      // 액세스 토큰이 유효하지 않으면 로그인 화면으로 이동
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  Future<bool> loginWithKakao() async {
    try {
      bool isInstalled = await isKakaoTalkInstalled();
      if (isInstalled) {
        try {
          OAuthToken token = await UserApi.instance.loginWithKakaoTalk();
          print('카카오톡으로 로그인 성공 ${token.accessToken}');
          bool success = await UserService.getUserInfoAndSendToServer(token);
          if (success) {
            return await _fetchAndSaveUserInfo();
          }
          return success;
        } catch (error) {
          print('카카오톡으로 로그인 실패 $error');
          if (error is PlatformException && error.code == 'CANCELED') {
            return false;
          }
        }
      } else {
        try {
          OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
          print('카카오계정으로 로그인 성공 ${token.accessToken}');
          bool success = await UserService.getUserInfoAndSendToServer(token);
          if (success) {
            return await _fetchAndSaveUserInfo();
          }
          return success;
        } catch (error) {
          print('카카오계정으로 로그인 실패 $error');
        }
      }
    } catch (error) {
      print('카카오톡 설치 여부 확인 실패 $error');
    }
    return false;
  }

  Future<void> logout(BuildContext context) async {
    try {
      await UserApi.instance.logout();
      await _clearUserInfo();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    } catch (error) {
      print('로그아웃 실패: $error');
    }
  }
}
