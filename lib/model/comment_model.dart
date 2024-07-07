class Comment {
  final int commentId;
  final int boardId;
  final int? parentId;
  final String writerId;
  final String content;
  final String createdAt;

  Comment({
    required this.commentId,
    required this.boardId,
    this.parentId,
    required this.writerId,
    required this.content,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      commentId: json['comment_id'],
      boardId: json['board_id'],
      parentId: json['parent_id'],
      writerId: json['writer_id'],
      content: json['content'],
      createdAt: json['created_at'],
    );
  }
}
