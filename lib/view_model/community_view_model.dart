import 'package:flutter/material.dart';
import '../model/board_model.dart';
import '../model/comment_model.dart';
import '../model/community_service.dart';

class CommunityViewModel extends ChangeNotifier {
  List<Board> _boards = [];
  List<Comment> _comments = [];
  List<Board> _filteredBoards = [];
  bool _isLoading = false;

  List<Board> get boards => _boards;
  List<Board> get filteredBoards => _filteredBoards;
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
      _filteredBoards = _boards; // 처음에는 모든 게시물을 표시
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

  Future<void> deleteComment(int commentId, int boardId) async {
    await CommunityService.deleteComment(commentId);
    fetchComments(boardId);
  }

  Future<void> editPost(Board post) async {
    await CommunityService.editPost(post);
    fetchPosts();
  }

  void filterPostsByCategory(String category) {
    if (category == '전체') {
      _filteredBoards = _boards;
    } else {
      _filteredBoards = _boards.where((board) => board.category == category).toList();
    }
    notifyListeners();
  }

  void filterPostsBySearchQuery(String query) {
    if (query.isEmpty) {
      _filteredBoards = _boards;
    } else {
      _filteredBoards = _boards.where((board) =>
          board.title.toLowerCase().contains(query.toLowerCase())).toList();
    }
    notifyListeners();
  }
}
