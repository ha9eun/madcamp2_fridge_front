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
  TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });
    final communityViewModel = Provider.of<CommunityViewModel>(context, listen: false);
    communityViewModel.filterPostsBySearchQuery(_searchQuery);
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '커뮤니티',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
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
            dropdownColor: Colors.grey[200],
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '게시물 검색',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onChanged: _updateSearchQuery,
            ),
            SizedBox(height: 10),
            Expanded(
              child: Consumer<CommunityViewModel>(
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
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PostDetailPage(postId: board.boardId),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.all(10),
                              title: Text(
                                board.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                board.writerNickname ?? 'Anonymous',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPostPage(writerId: userViewModel.kakaoId),
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
