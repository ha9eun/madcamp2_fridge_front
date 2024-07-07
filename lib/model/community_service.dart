import 'dart:convert';
import 'package:http/http.dart' as http;
import 'board_model.dart';
import 'comment_model.dart';
import '../config.dart';

class CommunityService {
  static const String baseUrl = Config.apiUrl;

  static Future<List<Board>> getPosts() async {
    final response = await http.get(Uri.parse('$baseUrl/community/posts/'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((post) => Board.fromJson(post)).toList();
    } else {
      print('Failed to load posts: ${response.statusCode}');
      throw Exception('Failed to load posts');
    }
  }

  static Future<List<Comment>> getComments(int postId) async {
    final response = await http.get(Uri.parse('$baseUrl/community/posts/$postId/'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body)['comments'];
      return jsonResponse.map((comment) => Comment.fromJson(comment)).toList();
    } else {
      print('Failed to load comments: ${response.statusCode}');
      throw Exception('Failed to load comments');
    }
  }

  static Future<void> addPost(Board post) async {
    final response = await http.post(
      Uri.parse('$baseUrl/community/posts/${post.writerId}/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'title': post.title,
        'content': post.content,
        'category': post.category,
      }),
    );
    if (response.statusCode != 201) {
      print('Failed to add post: ${response.statusCode}');
      throw Exception('Failed to add post');
    }
  }

  static Future<void> deletePost(int postId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/community/posts/$postId/'),
    );
    if (response.statusCode != 204) {
      print('Failed to delete post: ${response.statusCode}');
      throw Exception('Failed to delete post');
    }
  }

  static Future<void> addComment(Comment comment) async {
    final response = await http.post(
      Uri.parse('$baseUrl/community/comments/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(comment),
    );
    if (response.statusCode != 201) {
      print('Failed to add comment: ${response.statusCode}');
      throw Exception('Failed to add comment');
    }
  }

  static Future<void> deleteComment(int commentId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/community/comments/$commentId/'),
    );
    if (response.statusCode != 204) {
      print('Failed to delete comment: ${response.statusCode}');
      throw Exception('Failed to delete comment');
    }
  }
}