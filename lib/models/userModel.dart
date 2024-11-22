class User {
  final int id;
  final String name;
  final String email;
  final String? preferences;
  final String password;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.preferences,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': name,
      'email': email,
      'preferences': preferences,
      'password':password
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      //preferences: map['preferences'],
    );
  }
}