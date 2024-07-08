import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/community_view_model.dart';
import '../model/board_model.dart';

class EditPostPage extends StatefulWidget {
  final Board post;

  EditPostPage({required this.post});

  @override
  _EditPostPageState createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  late TextEditingController titleController;
  late TextEditingController contentController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.post.title);
    contentController = TextEditingController(text: widget.post.content);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Post')),
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
                final updatedPost = Board(
                  boardId: widget.post.boardId,
                  title: title,
                  writerId: widget.post.writerId,
                  content: content,
                  createdAt: widget.post.createdAt,
                  category: widget.post.category,
                  writerNickname: widget.post.writerNickname,
                );

                Provider.of<CommunityViewModel>(context, listen: false)
                    .editPost(updatedPost)
                    .then((_) {
                  Navigator.pop(context);
                });
              },
              child: Text('Update Post'),
            ),
          ],
        ),
      ),
    );
  }
}
