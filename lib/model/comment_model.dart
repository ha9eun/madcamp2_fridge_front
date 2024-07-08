class Comment {
  final int commentId;
  final int boardId;
  final int? parentId;
  final String writerId;
  final String content;
  final String createdAt;
  final String? writerNickname;

  Comment({
    required this.commentId,
    required this.boardId,
    this.parentId,
    required this.writerId,
    required this.content,
    required this.createdAt,
    this.writerNickname,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      commentId: json['comment_id'],
      boardId: json['board_id'],
      parentId: json['parent_id'],
      writerId: json['writer_id'],
      content: json['content'],
      createdAt: json['created_at'],
      writerNickname: json['writer_nickname'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'comment_id': commentId,
      'board_id': boardId,
      'parent_id': parentId,
      'writer_id': writerId,
      'content': content,
      'created_at': createdAt,
    };
  }
}
