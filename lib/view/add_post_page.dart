import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/community_view_model.dart';
import '../model/board_model.dart';
import '../view_model/user_view_model.dart';

class AddPostPage extends StatelessWidget {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final String writerId;

  AddPostPage({required this.writerId});

  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Add Post')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: contentController,
              decoration: InputDecoration(labelText: 'Content'),
              maxLines: 5,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text;
                final content = contentController.text;
                final post = Board(
                  boardId: 0,
                  title: title,
                  writerId: userViewModel.kakaoId,
                  content: content,
                  createdAt: DateTime.now().toString(),
                  category: '자유',
                );

                Provider.of<CommunityViewModel>(context, listen: false)
                    .addPost(post)
                    .then((_) {
                  Navigator.pop(context);
                });
              },
              child: Text('Add Post'),
            ),
          ],
        ),
      ),
    );
  }
}
