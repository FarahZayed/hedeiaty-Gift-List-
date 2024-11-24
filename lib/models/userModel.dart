class UserlocalDB {
  final String id;
  final String name;
  final String email;
  final String? preferences;

  UserlocalDB({
    required this.id,
    required this.name,
    required this.email,
    this.preferences,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': name,
      'email': email,
      'preferences': preferences,
    };
  }

  factory UserlocalDB.fromMap(Map<String, dynamic> map) {
    return UserlocalDB(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      //preferences: map['preferences'],
    );
  }
}