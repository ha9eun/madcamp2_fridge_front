import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/recipe_view_model.dart';
import '../model/recommend_service.dart';
import 'meal_direct_input_page.dart'; // MealDirectInputPage를 임포트

class RecipeDetailView extends StatefulWidget {
  final int recipeId;

  RecipeDetailView({required this.recipeId});

  @override
  _RecipeDetailViewState createState() => _RecipeDetailViewState();
}

class _RecipeDetailViewState extends State<RecipeDetailView> {
  Future<void>? _loadDataFuture;

  @override
  void initState() {
    super.initState();
    _loadDataFuture = _loadData();
  }

  Future<void> _loadData() async {
    final recipeViewModel = Provider.of<RecipeViewModel>(context, listen: false);
    await recipeViewModel.fetchRecipeDetail(widget.recipeId);
    if (recipeViewModel.selectedRecipe != null) {
      final comment = await RecommendService.getComment(recipeViewModel.selectedRecipe!.recipeName);
      recipeViewModel.setAiComment(comment);
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipeViewModel = Provider.of<RecipeViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '레시피 상세',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: FutureBuilder<void>(
        future: _loadDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('데이터를 불러오는 중 오류가 발생했습니다.'));
          } else {
            final recipe = recipeViewModel.selectedRecipe;
            final aiComment = recipeViewModel.aiComment;

            if (recipe == null) {
              return Center(child: Text('레시피를 불러올 수 없습니다.'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.recipeName,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '재료',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(height: 10),
                  for (var ingredient in recipe.details)
                    Text(
                      '${ingredient.foodName} ${ingredient.amount}${ingredient.unit}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  SizedBox(height: 20),
                  Text(
                    '조리 방법',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(height: 10),
                  for (var step in recipe.recipeContent.split('\n'))
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Text(
                        step,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  SizedBox(height: 20),
                  Text(
                    'AI의 한마디',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    aiComment,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MealDirectInputPage(recipeId: recipe.recipeId),
                        ),
                      );
                    },
                    child: Text('식사하기'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
