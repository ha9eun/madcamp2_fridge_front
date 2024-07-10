import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/recipe_view_model.dart';
import '../view_model/user_view_model.dart';
import 'recipe_detail_view.dart';

class RecipeListView extends StatefulWidget {
  @override
  _RecipeListViewState createState() => _RecipeListViewState();
}

class _RecipeListViewState extends State<RecipeListView> {
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRecipes();
    });

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  Future<void> _loadRecipes() async {
    final recipeViewModel = Provider.of<RecipeViewModel>(context, listen: false);
    await recipeViewModel.fetchRecipes();
  }

  void _showRecommendationPrompt() {
    showDialog(
      context: context,
      builder: (context) {
        String prompt = '';
        return AlertDialog(
          backgroundColor: Colors.white, // 연한 배경색 설정
          title: Text('AI 레시피 추천',style: TextStyle(fontSize: 20),),
          content: TextField(
            onChanged: (value) {
              prompt = value;
            },
            decoration: InputDecoration(
              hintText: "고단백, 아침 식사, 된장 요리",
              fillColor: Colors.white,
              filled: true,
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: Text('취소'),
              onPressed: () {
                FocusScope.of(context).unfocus(); // 키보드 내리기
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: Text('제출', style: TextStyle(color: Colors.white)),
              onPressed: () {
                FocusScope.of(context).unfocus(); // 키보드 내리기
                Navigator.of(context).pop();
                _updateRecommendations(prompt);
              },
            ),
          ],
        );
      },
    );
  }

  void _updateRecommendations(String prompt) {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    final recipeViewModel = Provider.of<RecipeViewModel>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await recipeViewModel.fetchRecommendedRecipes(userViewModel.kakaoId, prompt);
    });
  }

  Future<void> _refreshRecipes() async {
    final recipeViewModel = Provider.of<RecipeViewModel>(context, listen: false);
    await recipeViewModel.fetchRecipes();
    setState(() {
      _searchQuery = '';
      _searchController.clear();
      recipeViewModel.showAllRecipes();
    });
  }

  void _showAllRecipes() {
    final recipeViewModel = Provider.of<RecipeViewModel>(context, listen: false);
    recipeViewModel.showAllRecipes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus(); // 키보드 내리기
        },
        child: RefreshIndicator(
          onRefresh: _refreshRecipes,
          color: Theme.of(context).primaryColor,
          backgroundColor: Colors.white,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50.0, left: 16.0, right: 16.0), // 텍스트 필드에만 패딩 적용
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: '레시피 검색',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2), // 비활성화 상태 테두리 색깔
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                      borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2), // 포커스 상태 테두리 색깔
                    ),
                    filled: true,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: Consumer<RecipeViewModel>(
                  builder: (context, viewModel, child) {
                    if (viewModel.isLoading) {
                      return Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
                        ),
                      );
                    }

                    final filteredRecipes = viewModel.recipes.where((recipe) {
                      return recipe.name.toLowerCase().contains(_searchQuery.toLowerCase());
                    }).toList();

                    return ListView.builder(
                      padding: EdgeInsets.only(bottom: 80, left: 16, right: 16),
                      itemCount: filteredRecipes.length,
                      itemBuilder: (context, index) {
                        final recipe = filteredRecipes[index];
                        return GestureDetector(
                          onTap: () {
                            FocusScope.of(context).unfocus(); // 키보드 내리기
                            viewModel.fetchRecipeDetail(recipe.id);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecipeDetailView(recipeId: recipe.id),
                              ),
                            ).then((_) {
                              FocusScope.of(context).unfocus(); // 상세 페이지에서 돌아왔을 때 키보드 내리기
                              setState(() {});
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 10.0),
                            child: Row(
                              children: [
                                Icon(Icons.restaurant_menu, color: Theme.of(context).primaryColor),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        recipe.name,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        recipe.ingredients.join(', '),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          FocusScope.of(context).unfocus(); // 키보드 내리기
          _showRecommendationPrompt();
        },
        label: Text('AI 추천 받기'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
