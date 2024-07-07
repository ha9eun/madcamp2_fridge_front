import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../view_model/community_view_model.dart';
import '../model/comment_model.dart';

class PostDetailPage extends StatefulWidget {
  final int postId;

  PostDetailPage({required this.postId});

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch comments when the widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CommunityViewModel>(context, listen: false).fetchComments(widget.postId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Post Details')),
      body: Consumer<CommunityViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          final post = viewModel.boards.firstWhere((board) => board.boardId == widget.postId);
          final comments = viewModel.comments.where((comment) => comment.boardId == widget.postId).toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(post.content),
                SizedBox(height: 16),
                Text('Comments', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                Expanded(
                  child: ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return ListTile(
                        title: Text(comment.content),
                        subtitle: Text(comment.writerId),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            Provider.of<CommunityViewModel>(context, listen: false)
                                .deleteComment(comment.commentId);
                          },
                        ),
                      );
                    },
                  ),
                ),
                TextField(
                  controller: commentController,
                  decoration: InputDecoration(labelText: 'Add a comment'),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    final content = commentController.text;
                    final newComment = Comment(
                      commentId: 0,
                      boardId: widget.postId,
                      parentId: null,
                      writerId: 'currentUserId', // Replace with actual current user ID
                      content: content,
                      createdAt: DateTime.now().toString(),
                    );

                    Provider.of<CommunityViewModel>(context, listen: false)
                        .addComment(newComment)
                        .then((_) {
                      commentController.clear();
                    });
                  },
                  child: Text('Add Comment'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
