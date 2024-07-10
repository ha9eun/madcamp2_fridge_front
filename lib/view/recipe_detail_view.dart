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
      body: Container(
        color: Colors.grey[200], // 컨텐츠 배경 색상
        child: FutureBuilder<void>(
          future: _loadDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),));
            } else if (snapshot.hasError) {
              return Center(child: Text('데이터를 불러오는 중 오류가 발생했습니다.'));
            } else {
              final recipe = recipeViewModel.selectedRecipe;

              if (recipe == null) {
                return Center(child: Text('레시피를 불러올 수 없습니다.'));
              }

              return CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    backgroundColor: Colors.grey[200], // 앱바 색상을 컨텐츠 배경 색상과 통일
                    elevation: 0, // 그림자 제거
                    iconTheme: IconThemeData(color: Colors.black), // 아이콘 색상 변경
                    title: Text(
                      recipeViewModel.selectedRecipe?.recipeName ?? '상세 레시피',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _videoId != null
                              ? YoutubePlayer(
                            controller: _youtubeController!,
                            showVideoProgressIndicator: true,
                          )
                              : Container(
                            height: 200,
                            color: Colors.black12,
                            child: Center(child: Text('YouTube Video Placeholder')),
                          ),
                          SizedBox(height: 10),
                          _buildSectionTitle('재료'),
                          _buildIngredients(recipe),
                          _buildDottedDivider(),
                          _buildSectionTitle('조리 방법'),
                          _buildRecipeSteps(recipe),
                          _buildDottedDivider(),
                          _isLoadingAiComment
                              ? Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),))
                              : _showAiComment
                              ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('Gemini의 한마디'),
                              SizedBox(height: 10),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text(
                                  recipeViewModel.aiComment,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[800],
                                  ),
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
                    ),
                  ),
                ],
              );
            }
          },
        ),
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0, top: 5.0, bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 2.0),
            height: 2.0,
            width: 312.0,
            color: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }


  Widget _buildIngredients(RecipeDetail recipe) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Table(
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
      ),
    );
  }

  Widget _buildRecipeSteps(RecipeDetail recipe) {
    // 레시피 콘텐츠를 숫자와 점으로 분리하여 개별 항목으로 나눕니다.
    List<String> steps = recipe.recipeContent.split(RegExp(r'\d+\.\s')).where((s) => s.isNotEmpty).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < steps.length; i++)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                '${i + 1}. ${steps[i].trim()}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDottedDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0), // 위아래 패딩 조정
      child: Center(
        child: CustomPaint(
          size: Size(double.infinity, 1),
          painter: DashedLinePainter(),
        ),
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 1;

    const dashWidth = 5.0;
    const dashSpace = 3.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}