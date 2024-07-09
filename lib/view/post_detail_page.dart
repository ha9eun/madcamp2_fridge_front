import 'package:flutter/material.dart';
import 'package:fridge/view_model/user_view_model.dart';
import 'package:provider/provider.dart';
import '../view_model/community_view_model.dart';
import '../model/board_model.dart';
import 'edit_post_page.dart';
import 'comment_page.dart';
import 'package:fluttertoast/fluttertoast.dart';

class PostDetailPage extends StatefulWidget {
  final int postId;

  PostDetailPage({required this.postId});

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
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

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text(post.createdAt, style: TextStyle(color: Colors.grey)),
                SizedBox(height: 8),
                Text(post.content),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CommentPage(postId: widget.postId),
            ),
          );
        },
        label: Text('댓글 보기'),
        icon: Icon(Icons.comment),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
