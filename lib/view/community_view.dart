import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/community_view_model.dart';
import '../model/board_model.dart';
import 'add_post_page.dart';
import 'post_detail_page.dart';
import '../view_model/user_view_model.dart';

class CommunityView extends StatefulWidget {
  @override
  _CommunityViewState createState() => _CommunityViewState();
}

class _CommunityViewState extends State<CommunityView> {
  String _selectedCategory = '전체';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final communityViewModel = Provider.of<CommunityViewModel>(context, listen: false);
      communityViewModel.fetchPosts().then((_) {
        communityViewModel.filterPostsByCategory(_selectedCategory);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text('Community'),
        actions: [
          DropdownButton<String>(
            value: _selectedCategory,
            onChanged: (String? newValue) {
              setState(() {
                _selectedCategory = newValue!;
                Provider.of<CommunityViewModel>(context, listen: false)
                    .filterPostsByCategory(_selectedCategory);
              });
            },
            items: <String>['전체', '자유', '질문', '공유']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            dropdownColor: Colors.grey[200], // 드롭다운 배경색 변경
            style: TextStyle(color: Colors.white), // 드롭다운 텍스트 색상 변경
          ),
        ],
      ),
      body: Consumer<CommunityViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (viewModel.filteredBoards.isEmpty) {
            return Center(child: Text('No posts found'));
          } else {
            return ListView.builder(
              itemCount: viewModel.filteredBoards.length,
              itemBuilder: (context, index) {
                Board board = viewModel.filteredBoards[index];
                return ListTile(
                  title: Text(board.title),
                  subtitle: Text(board.writerNickname ?? 'Anonymous'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PostDetailPage(postId: board.boardId),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPostPage(writerId: userViewModel.kakaoId), // Replace with actual current user ID
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
