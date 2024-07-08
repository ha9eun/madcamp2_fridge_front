import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/community_view_model.dart';
import '../model/board_model.dart';
import 'add_post_page.dart';
import 'post_detail_page.dart';
import 'edit_post_page.dart';

class CommunityView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Community')),
      body: Consumer<CommunityViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (viewModel.boards.isEmpty) {
            return Center(child: Text('No posts found'));
          } else {
            return ListView.builder(
              itemCount: viewModel.boards.length,
              itemBuilder: (context, index) {
                Board board = viewModel.boards[index];
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
                  trailing: IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditPostPage(post: board),
                        ),
                      );
                    },
                  ),
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
              builder: (context) => AddPostPage(writerId: 'currentUserId'), // Replace with actual current user ID
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}