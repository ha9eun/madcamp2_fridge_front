import 'package:flutter/material.dart';
import 'package:fridge/view_model/user_view_model.dart';
import 'package:provider/provider.dart';
import '../view_model/community_view_model.dart';
import '../model/comment_model.dart';

class CommentPage extends StatefulWidget {
  final int postId;

  CommentPage({required this.postId});

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final TextEditingController commentController = TextEditingController();
  String? _replyTo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CommunityViewModel>(context, listen: false).fetchComments(widget.postId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final UserViewModel userViewModel = Provider.of<UserViewModel>(context);
    final userId = userViewModel.kakaoId;
    return Scaffold(
      appBar: AppBar(
        title: Text('Comments'),
      ),
      body: Consumer<CommunityViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          final comments = viewModel.comments.where((comment) => comment.boardId == widget.postId).toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      return _buildCommentTile(comment, userId);
                    },
                  ),
                ),
                TextField(
                  controller: commentController,
                  decoration: InputDecoration(
                    labelText: 'Add a comment',
                    suffixIcon: _replyTo != null
                        ? IconButton(
                      icon: Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _replyTo = null;
                          commentController.clear();
                        });
                      },
                    )
                        : null,
                  ),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    final content = commentController.text;
                    final newComment = Comment(
                      commentId: 0,
                      boardId: widget.postId,
                      parentId: _replyTo != null ? comments.firstWhere((comment) => comment.writerNickname == _replyTo).commentId : null,
                      writerId: userViewModel.kakaoId,
                      content: content,
                      createdAt: DateTime.now().toString(),
                    );

                    Provider.of<CommunityViewModel>(context, listen: false)
                        .addComment(newComment)
                        .then((_) {
                      commentController.clear();
                      setState(() {
                        _replyTo = null;
                      });
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

  Widget _buildCommentTile(Comment comment, String userId) {
    return Padding(
      padding: EdgeInsets.only(left: comment.parentId == null ? 0 : 16.0),
      child: ListTile(
        title: Text(comment.content),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(comment.writerNickname ?? 'Anonymous'),
            Text(comment.createdAt, style: TextStyle(color: Colors.grey)),
          ],
        ),
        trailing: comment.writerId == userId
            ? IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            Provider.of<CommunityViewModel>(context, listen: false)
                .deleteComment(comment.commentId, widget.postId)
                .then((_) {
              commentController.clear();
            });
          },
        )
            : null,
        onLongPress: () {
          setState(() {
            _replyTo = comment.writerNickname;
          });
          commentController.text = '@${comment.writerNickname} ';
        },
      ),
    );
  }
}
