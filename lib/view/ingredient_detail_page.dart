import 'package:flutter/material.dart';
import 'package:fridge/model/ingredient_service.dart';

import '../model/ingredient.dart';

class IngredientDetailPage extends StatelessWidget {
  final Ingredient ingredient;

  IngredientDetailPage({required this.ingredient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('재료 상세 정보'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              ingredient.foodName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('유통기한: ${ingredient.expirationDate}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('남은 양: ${ingredient.amount} ${ingredient.unit}', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
