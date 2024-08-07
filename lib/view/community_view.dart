import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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

    _searchController.addListener(() {
      _updateSearchQuery(_searchController.text);
    });
  }

  void _updateSearchQuery(String query) {
    setState(() {
      _searchQuery = query;
    });
    final communityViewModel = Provider.of<CommunityViewModel>(context, listen: false);
    communityViewModel.filterPostsBySearchQuery(_searchQuery);
  }

  String formatDateTime(String dateTime) {
    final parsedDate = DateTime.parse(dateTime);
    return DateFormat('yyyy-MM-dd HH:mm').format(parsedDate);
  }

  Future<void> _refreshPosts() async {
    final communityViewModel = Provider.of<CommunityViewModel>(context, listen: false);
    await communityViewModel.fetchPosts();
    communityViewModel.filterPostsByCategory(_selectedCategory);
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    return Scaffold(
      body: RefreshIndicator(
        color: Theme.of(context).primaryColor,
        backgroundColor: Colors.white,
        onRefresh: _refreshPosts,
        child: Padding(
          padding: const EdgeInsets.only(top: 50.0, left: 16.0, right: 16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: '게시물 검색',
                          prefixIcon: Icon(Icons.search),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Theme.of(context).primaryColor, width: 2),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
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
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Text(value),
                            ),
                          );
                        }).toList(),
                        dropdownColor: Colors.white,
                        style: TextStyle(color: Colors.black),
                        icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).primaryColor),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Consumer<CommunityViewModel>(
                  builder: (context, viewModel, child) {
                    if (viewModel.isLoading) {
                      return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),));
                    } else if (viewModel.filteredBoards.isEmpty) {
                      return Center(child: Text('No posts found'));
                    } else {
                      return ListView.builder(
                        itemCount: viewModel.filteredBoards.length,
                        itemBuilder: (context, index) {
                          Board board = viewModel.filteredBoards.reversed.toList()[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => PostDetailPage(postId: board.boardId),
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(color: Theme.of(context).primaryColor, width: 1),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    board.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    board.content.length > 30
                                        ? board.content.substring(0, 30) + '...'
                                        : board.content,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        board.writerNickname ?? 'Anonymous',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        formatDateTime(board.createdAt),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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
