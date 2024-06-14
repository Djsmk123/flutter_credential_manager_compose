class UserModel {
  String username;
  DateTime createdAt;
  DateTime updatedAt;
  String userId;

  UserModel({
    required this.username,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
  });
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      userId: json['userId'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'userId': userId,
    };
  }
}
