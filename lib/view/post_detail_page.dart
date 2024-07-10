import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../view_model/community_view_model.dart';
import '../model/board_model.dart';
import '../model/comment_model.dart';
import '../view_model/user_view_model.dart';
import 'edit_post_page.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final communityViewModel = Provider.of<CommunityViewModel>(context, listen: false);
      communityViewModel.fetchComments(widget.postId);
      communityViewModel.fetchPosts();
    });
  }

  String formatDateTime(String dateTime) {
    final parsedDate = DateTime.parse(dateTime);
    return DateFormat('yyyy-MM-dd HH:mm').format(parsedDate);
  }

  @override
  Widget build(BuildContext context) {
    final UserViewModel userViewModel = Provider.of<UserViewModel>(context);
    final userId = userViewModel.kakaoId;

    return Scaffold(
      body: Consumer<CommunityViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),));
          }
          final post = viewModel.boards.firstWhere((board) => board.boardId == widget.postId);
          final comments = viewModel.comments.where((comment) => comment.boardId == widget.postId).toList();

          return SingleChildScrollView(
            padding: EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(post.title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    if (post.writerId == userId)
                      IconButton(
                        icon: Icon(Icons.more_vert),
                        onPressed: () {
                          _showPostOptions(post);
                        },
                      ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text('글쓴이: ${post.writerNickname ?? 'Anonymous'}', style: TextStyle(color: Colors.grey)),
                    Spacer(),
                    Text(formatDateTime(post.createdAt), style: TextStyle(color: Colors.grey)),
                  ],
                ),
                SizedBox(height: 8),
                Divider(color: Theme.of(context).primaryColor,thickness: 2,),
                Text(post.content, style: TextStyle(fontSize: 16)),
                SizedBox(height: 20),
                Divider(color: Theme.of(context).primaryColor,thickness: 2,),
                Text('댓글', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ListView.builder(
                  physics: NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return _buildCommentTile(comment, userId);
                  },
                ),
                SizedBox(height: 20),
                TextField(
                  controller: commentController,
                  decoration: InputDecoration(
                    labelText: '댓글을 입력하세요',
                    labelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    final content = commentController.text;
                    final newComment = Comment(
                      commentId: 0,
                      boardId: widget.postId,
                      parentId: null,
                      writerId: userViewModel.kakaoId,
                      content: content,
                      createdAt: DateTime.now().toString(),
                    );

                    Provider.of<CommunityViewModel>(context, listen: false)
                        .addComment(newComment)
                        .then((_) {
                      commentController.clear();
                    });
                  },
                  child: Text(
                    '댓글 추가',
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCommentTile(Comment comment, String userId) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[300]!),
              ),
              padding: EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    comment.writerNickname ?? '익명',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(comment.content),
                  SizedBox(height: 5),
                  Text(formatDateTime(comment.createdAt), style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          ),
        ),
        if (comment.writerId == userId)
          IconButton(
            icon: Icon(Icons.more_vert, size: 20),
            onPressed: () {
              _showCommentOptions(comment.commentId);
            },
          )
        else
          SizedBox(width: 48),
      ],
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
              title: Text('수정'),
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
              title: Text('삭제'),
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
          title: Text('삭제 확인'),
          content: Text('이 글을 삭제하시겠습니까?'),
          backgroundColor: Colors.white,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('취소', style: TextStyle(color: Theme.of(context).primaryColor)),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<CommunityViewModel>(context, listen: false).deletePost(postId).then((_) {
                  Fluttertoast.showToast(msg: '삭제되었습니다');
                  Navigator.pop(context);
                  Navigator.pop(context);
                });
              },
              child: Text('삭제', style: TextStyle(color: Theme.of(context).primaryColor)),
            ),
          ],
        );
      },
    );
  }

  void _showCommentOptions(int commentId) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('삭제'),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteComment(commentId);
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteComment(int commentId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('댓글 삭제 확인'),
          content: Text('이 댓글을 삭제하시겠습니까?'),
          backgroundColor: Colors.white,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('취소', style: TextStyle(color: Theme.of(context).primaryColor)),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<CommunityViewModel>(context, listen: false)
                    .deleteComment(commentId, widget.postId)
                    .then((_) {
                  Fluttertoast.showToast(msg: '댓글이 삭제되었습니다');
                  Navigator.pop(context);
                });
              },
              child: Text('삭제', style: TextStyle(color: Theme.of(context).primaryColor)),
            ),
          ],
        );
      },
    );
  }
}
