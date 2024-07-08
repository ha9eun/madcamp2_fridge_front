import 'package:flutter/material.dart';
import 'package:fridge/view/meal_direct_input_page.dart';
import 'package:fridge/view/meal_recipe_page.dart';

class MealPage extends StatefulWidget {
  @override
  _MealPageState createState() => _MealPageState();
}

class _MealPageState extends State<MealPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('식사하기'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: '직접 입력 모드'),
            Tab(text: '레시피 모드'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          MealDirectInputPage(),
          MealRecipePage(),
        ],
      ),
    );
  }
}
