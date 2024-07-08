import 'package:flutter/material.dart';
import 'package:fridge/view_model/user_view_model.dart';
import 'package:provider/provider.dart';
import '../view_model/community_view_model.dart';
import '../model/comment_model.dart';
import 'edit_post_page.dart';
import '../model/board_model.dart';

class PostDetailPage extends StatefulWidget {
  final int postId;

  PostDetailPage({required this.postId});

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  final TextEditingController commentController = TextEditingController();
  String? _replyTo;

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
    final UserViewModel userViewModel = Provider.of<UserViewModel>(context);
    final userId = userViewModel.kakaoId;
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Details'),
        actions: [
          Consumer<CommunityViewModel>(
            builder: (context, viewModel, child) {
              final post = viewModel.boards.firstWhere((board) => board.boardId == widget.postId);
              if (post.writerId == userId) {
                return IconButton(
                  icon: Icon(Icons.settings),
                  onPressed: () {
                    _showPostOptions(post);
                  },
                );
              }
              return Container();
            },
          ),
        ],
      ),
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
                        subtitle: Text(comment.writerNickname ?? 'Anonymous'),
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
                      );
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

  void _showPostOptions(Board post) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.edit),
              title: Text('Edit'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditPostPage(post: post),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Delete'),
              onTap: () {
                Navigator.pop(context);
                _confirmDeletePost(post.boardId);
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmDeletePost(int postId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Post'),
          content: Text('Are you sure you want to delete this post?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<CommunityViewModel>(context, listen: false).deletePost(postId).then((_) {
                  Navigator.pop(context);
                  Navigator.pop(context);
                });
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
