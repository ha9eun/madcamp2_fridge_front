import 'package:flutter/material.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fridge/model/user_service.dart';

class UserViewModel extends ChangeNotifier {
  String _nickname = '';
  String _kakaoId = '';
  bool _isLoggedIn = false;

  String get nickname => _nickname;
  String get kakaoId => _kakaoId;
  bool get isLoggedIn => _isLoggedIn;

  UserViewModel() {
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    _nickname = prefs.getString('nickname') ?? '';
    _kakaoId = prefs.getString('kakao_id') ?? '';
    _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    notifyListeners();
  }

  Future<void> _saveUserInfo(String nickname, String kakaoId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nickname', nickname);
    await prefs.setString('kakao_id', kakaoId);
    await prefs.setBool('is_logged_in', true);
    _nickname = nickname;
    _kakaoId = kakaoId;
    _isLoggedIn = true;
    notifyListeners();
  }

  Future<void> clearUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('nickname');
    await prefs.remove('kakao_id');
    await prefs.setBool('is_logged_in', false);
    _nickname = '';
    _kakaoId = '';
    _isLoggedIn = false;
    notifyListeners();
  }

  Future<void> fetchAndSaveUserInfo() async {
    try {
      User user = await UserApi.instance.me();
      await _saveUserInfo(user.kakaoAccount?.profile?.nickname ?? '', user.id.toString());
    } catch (error) {
      print('사용자 정보 요청 실패 $error');
    }
  }

  Future<void> loginWithKakao(BuildContext context) async {
    try {
      bool isInstalled = await isKakaoTalkInstalled();
      if (isInstalled) {
        OAuthToken token = await UserApi.instance.loginWithKakaoTalk();
        await _handleLoginSuccess(token, context);
      } else {
        OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
        await _handleLoginSuccess(token, context);
      }
    } catch (error) {
      print('카카오톡 설치 여부 확인 실패 $error');
    }
  }

  Future<void> _handleLoginSuccess(OAuthToken token, BuildContext context) async {
    bool success = await UserService.getUserInfoAndSendToServer(token);
    if (success) {
      await fetchAndSaveUserInfo();
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('서버로 사용자 정보 전송 실패. 다시 시도해주세요.')),
      );
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await UserApi.instance.logout();
      await clearUserInfo();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (error) {
      print('로그아웃 실패: $error');
    }
  }
}
