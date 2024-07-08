import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/recipe_view_model.dart';
import '../model/recommend_service.dart'; // RecommendService를 임포트

class RecipeDetailView extends StatefulWidget {
  final int recipeId;

  RecipeDetailView({required this.recipeId});

  @override
  _RecipeDetailViewState createState() => _RecipeDetailViewState();
}

class _RecipeDetailViewState extends State<RecipeDetailView> {
  String _aiComment = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadData();
    });
  }

  Future<void> _loadData() async {
    final recipeViewModel = Provider.of<RecipeViewModel>(context, listen: false);
    await recipeViewModel.fetchRecipeDetail(widget.recipeId);
    if (recipeViewModel.selectedRecipe != null) {
      final comment = await RecommendService.getComment(recipeViewModel.selectedRecipe!.recipeName);
      if (mounted) {
        setState(() {
          _aiComment = comment;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipeViewModel = Provider.of<RecipeViewModel>(context);
    final recipe = recipeViewModel.selectedRecipe;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          recipe != null ? recipe.recipeName : '레시피 상세',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : recipe == null
              ? Center(child: Text('레시피를 불러올 수 없습니다.'))
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                          _aiComment,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
