class User {
  final String userId;
  final String nickname;

  User({required this.userId, required this.nickname});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'],
      nickname: json['nickname'],
    );
  }
}
