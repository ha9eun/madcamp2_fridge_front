import 'dart:convert';
import 'package:http/http.dart' as http;
import 'board_model.dart';
import 'comment_model.dart';

class CommunityService {
  static const String baseUrl = 'http://your-api-url';

  static Future<List<Board>> getPosts() async {
    final response = await http.get(Uri.parse('$baseUrl/community/posts/'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((post) => Board.fromJson(post)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }

  static Future<List<Comment>> getComments(int postId) async {
    final response = await http.get(Uri.parse('$baseUrl/community/posts/$postId/'));
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body)['comments'];
      return jsonResponse.map((comment) => Comment.fromJson(comment)).toList();
    } else {
      throw Exception('Failed to load comments');
    }
  }

  static Future<void> addPost(Board post) async {
    final response = await http.post(
      Uri.parse('$baseUrl/community/posts/${post.writerId}/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(post),
    );
    if (response.statusCode != 201) {
      throw Exception('Failed to add post');
    }
  }

  static Future<void> deletePost(int postId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/community/posts/$postId/'),
    );
    if (response.statusCode != 204) {
      throw Exception('Failed to delete post');
    }
  }
}
