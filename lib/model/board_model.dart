class Board {
  final int boardId;
  final String title;
  final String writerId;
  final String content;
  final String createdAt;
  final String category;

  Board({
    required this.boardId,
    required this.title,
    required this.writerId,
    required this.content,
    required this.createdAt,
    required this.category,
  });

  factory Board.fromJson(Map<String, dynamic> json) {
    return Board(
      boardId: json['board_id'],
      title: json['title'],
      writerId: json['writer_id'],
      content: json['content'],
      createdAt: json['created_at'],
      category: json['category'],
    );
  }
}