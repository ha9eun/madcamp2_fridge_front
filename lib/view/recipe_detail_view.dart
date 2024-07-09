import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../view_model/recipe_view_model.dart';
import '../model/recommend_service.dart';
import '../model/youtube_service.dart';
import 'meal_direct_input_page.dart';
import '../model/recipe_model.dart';

class RecipeDetailView extends StatefulWidget {
  final int recipeId;

  RecipeDetailView({required this.recipeId});

  @override
  _RecipeDetailViewState createState() => _RecipeDetailViewState();
}

class _RecipeDetailViewState extends State<RecipeDetailView> {
  Future<void>? _loadDataFuture;
  String? _videoId;
  YoutubePlayerController? _youtubeController;
  bool _showAiComment = false;
  bool _isLoadingAiComment = false;

  @override
  void initState() {
    super.initState();
    _loadDataFuture = _loadData();
  }

  Future<void> _loadData() async {
    final recipeViewModel = Provider.of<RecipeViewModel>(context, listen: false);
    await recipeViewModel.fetchRecipeDetail(widget.recipeId);
    if (recipeViewModel.selectedRecipe != null) {
      final videoId = await YouTubeService.fetchVideoId('${recipeViewModel.selectedRecipe!.recipeName} 레시피');
      if (videoId != null) {
        setState(() {
          _videoId = videoId;
          _youtubeController = YoutubePlayerController(
            initialVideoId: _videoId!,
            flags: YoutubePlayerFlags(
              autoPlay: false,
              mute: false,
            ),
          );
        });
      }
    }
  }

  Future<void> _loadAiComment() async {
    final recipeViewModel = Provider.of<RecipeViewModel>(context, listen: false);
    setState(() {
      _isLoadingAiComment = true;
    });
    final comment = await RecommendService.getComment(recipeViewModel.selectedRecipe!.recipeName);
    recipeViewModel.setAiComment(comment);
    setState(() {
      _isLoadingAiComment = false;
      _showAiComment = true;
    });
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recipeViewModel = Provider.of<RecipeViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          recipeViewModel.selectedRecipe?.recipeName ?? '상세 레시피',
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

            if (recipe == null) {
              return Center(child: Text('레시피를 불러올 수 없습니다.'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _videoId != null
                      ? YoutubePlayer(
                    controller: _youtubeController!,
                    showVideoProgressIndicator: true,
                    onReady: () {
                      _youtubeController!.addListener(() {
                        if (_youtubeController!.value.isFullScreen) {
                          // 전체화면 상태가 변경될 때 필요한 작업을 수행합니다.
                        }
                      });
                    },
                  )
                      : Container(
                    height: 200,
                    color: Colors.black12,
                    child: Center(child: Text('YouTube Video Placeholder')),
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
                  _buildIngredients(recipe),
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
                  _buildRecipeSteps(recipe),
                  SizedBox(height: 20),
                  _isLoadingAiComment
                      ? Center(child: CircularProgressIndicator())
                      : _showAiComment
                      ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Gemini의 한마디',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        recipeViewModel.aiComment,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  )
                      : ElevatedButton(
                    onPressed: _loadAiComment,
                    child: Text('Gemini의 한마디 보기'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  SizedBox(height: 80), // 추가 패딩
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MealDirectInputPage(recipeId: recipeViewModel.selectedRecipe!.recipeId),
            ),
          );
        },
        label: Text('식사하기'),
        icon: Icon(Icons.fastfood),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildIngredients(RecipeDetail recipe) {
    return Table(
      border: TableBorder.all(color: Colors.grey),
      children: [
        TableRow(children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '재료명',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              '양',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ]),
        for (var ingredient in recipe.details)
          TableRow(children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(ingredient.foodName),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('${ingredient.amount}${ingredient.unit}'),
            ),
          ]),
      ],
    );
  }

  Widget _buildRecipeSteps(RecipeDetail recipe) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }
}
