import 'package:flutter/material.dart';
import '../model/board_model.dart';
import '../model/comment_model.dart';
import '../model/community_service.dart';

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
  }

  Future<void> deletePost(int postId) async {
    await CommunityService.deletePost(postId);
    fetchPosts();
  }

  Future<void> addComment(Comment comment) async {
    await CommunityService.addComment(comment);
    fetchComments(comment.boardId);
  }

  Future<void> deleteComment(int commentId) async {
    await CommunityService.deleteComment(commentId);
    fetchComments(1); // Replace 1 with actual boardId associated with the comment
  }
}