class Friend {
  final int userId;
  final int friendId;

  Friend({
    required this.userId,
    required this.friendId,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'friendId': friendId,
    };
  }

  factory Friend.fromMap(Map<String, dynamic> map) {
    return Friend(
      userId: map['userId'],
      friendId: map['friendId'],
    );
  }
}