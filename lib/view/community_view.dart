import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/community_view_model.dart';
import '../model/board_model.dart';

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
                  subtitle: Text(board.writerId),
                  onTap: () {
                    // Navigate to post details
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add post screen
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
