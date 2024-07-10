import 'package:flutter/material.dart';
import 'package:fridge/config.dart';
import 'package:fridge/view_model/community_view_model.dart';
import 'package:fridge/view_model/ingredient_view_model.dart';
import 'package:provider/provider.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'view_model/user_view_model.dart';
import 'view/login_page.dart';
import 'view/home_page.dart';
import 'view_model/recipe_view_model.dart';
import 'view_model/history_view_model.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  KakaoSdk.init(nativeAppKey: Config.appKey); // 카카오 SDK 초기화

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserViewModel()),
        ChangeNotifierProvider(
            create: (context) => RecipeViewModel()..fetchRecipes()),
        ChangeNotifierProvider(create: (context) => IngredientViewModel()),
        ChangeNotifierProvider(create: (context) => CommunityViewModel()),
        ChangeNotifierProvider(create: (context) => HistoryViewModel()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '냉장고를 부탁해',
      theme: ThemeData(
        textSelectionTheme: TextSelectionThemeData(cursorColor: Color(0xFF00ADB5)),
        primaryColor: Color(0xFF00ADB5),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Color(0xFF393E46),
        ),
        scaffoldBackgroundColor: Color(0xFFEEEEEE),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF222831)),
          bodyMedium: TextStyle(color: Color(0xFF222831)),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: Color(0xFF00ADB5),
          unselectedItemColor: Color(0xFF393E46),
          backgroundColor: Color(0xFFEEEEEE),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/home': (context) => HomePage(),
      },
    );
  }
}


