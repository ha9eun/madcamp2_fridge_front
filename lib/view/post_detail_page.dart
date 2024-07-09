import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // 추가된 import
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
      appBar: AppBar(
        title: Text('글 상세보기'),
        actions: [
          Consumer<CommunityViewModel>(
            builder: (context, viewModel, child) {
              final post = viewModel.boards.firstWhere((board) => board.boardId == widget.postId);
              if (post.writerId == userId) {
                return IconButton(
                  icon: Icon(Icons.more_vert),
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text('글쓴이: ${post.writerNickname ?? 'Anonymous'}', style: TextStyle(color: Colors.grey)),
                    Spacer(),
                    Text(formatDateTime(post.createdAt), style: TextStyle(color: Colors.grey)),
                  ],
                ),
                SizedBox(height: 8),
                Divider(),
                Text(post.content, style: TextStyle(fontSize: 16)),
                SizedBox(height: 20),
                Divider(),
                Text('댓글', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
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
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
                  child: Text('댓글 추가'),
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
              comment.writerNickname ?? 'Anonymous',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(comment.content),
            SizedBox(height: 5),
            Text(formatDateTime(comment.createdAt), style: TextStyle(color: Colors.grey, fontSize: 12)),
            if (comment.writerId == userId)
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.delete, size: 20),
                  onPressed: () {
                    Provider.of<CommunityViewModel>(context, listen: false)
                        .deleteComment(comment.commentId, widget.postId)
                        .then((_) {
                      commentController.clear();
                    });
                  },
                ),
              ),
          ],
        ),
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
          backgroundColor: Color(0xFFEEEEEE), // 연한 배경색 설정
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<CommunityViewModel>(context, listen: false).deletePost(postId).then((_) {
                  Fluttertoast.showToast(msg: '삭제되었습니다');
                  Navigator.pop(context);
                  Navigator.pop(context);
                });
              },
              child: Text('삭제'),
            ),
          ],
        );
      },
    );
  }
}
