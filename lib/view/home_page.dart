import 'package:flutter/material.dart';
import 'package:fridge/view/community_view.dart';
import 'package:fridge/view/my_page.dart';
import 'package:fridge/view/recipe_list_view.dart';
import 'package:fridge/view_model/community_view_model.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fridge App',
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  PageController _pageController = PageController();

  static List<Widget> _widgetOptions = <Widget>[
    MyPage(),
    RecipeListView(),
    CommunityView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    _pageController.jumpToPage(index);
  }

  void _onPageChanged(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.kitchen),
            label: '나의 냉장고',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: '레시피',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: '커뮤니티',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
