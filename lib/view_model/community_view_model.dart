import 'package:flutter/material.dart';
import '../model/board_model.dart';
import '../model/comment_model.dart';
import '../model/community_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CommunityViewModel extends ChangeNotifier {
  List<Board> _boards = [];
  List<Comment> _comments = [];
  bool _isLoading = false;

  List<Board> get boards => _boards;
  List<Comment> get comments => _comments;
  bool get isLoading => _isLoading;

  CommunityViewModel() {
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    _isLoading = true;
    notifyListeners();
    try {
      _boards = await CommunityService.getPosts();
    } catch (e) {
      print('Error fetching posts: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchComments(int postId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _comments = await CommunityService.getComments(postId);
    } catch (e) {
      print('Error fetching comments: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addPost(Board post) async {
    await CommunityService.addPost(post);
    fetchPosts();
    Fluttertoast.showToast(msg: 'Post added successfully');
  }

  Future<void> deletePost(int postId) async {
    await CommunityService.deletePost(postId);
    fetchPosts();
    Fluttertoast.showToast(msg: 'Post deleted successfully');
  }

  Future<void> addComment(Comment comment) async {
    await CommunityService.addComment(comment);
    fetchComments(comment.boardId);
    Fluttertoast.showToast(msg: 'Comment added successfully');
  }

  Future<void> deleteComment(int commentId, int boardId) async {
    await CommunityService.deleteComment(commentId);
    fetchComments(boardId);
    Fluttertoast.showToast(msg: 'Comment deleted successfully');
  }

  Future<void> editPost(Board post) async {
    await CommunityService.editPost(post);
    fetchPosts();
    Fluttertoast.showToast(msg: 'Post edited successfully');
  }
}
