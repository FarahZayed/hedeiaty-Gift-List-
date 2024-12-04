class UserlocalDB {
  final String uid;
  final String username;
  final String email;
  final String phone;
  final List<dynamic> friendIds;
  final List<dynamic>eventIds;
  final String photoURL;

  UserlocalDB({
    required this.uid,
    required this.username,
    required this.email,
    required this.phone,
    required this.eventIds,
    required this.friendIds,
    required this.photoURL
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'phone': phone,
      'friendIds': friendIds.toString(),
      'eventIds': eventIds.toString(),
      'photoURL':photoURL,
    };
  }

  factory UserlocalDB.fromMap(Map<String, dynamic> map) {
    return UserlocalDB(
      uid: map['id'],
      username: map['username'],
      email: map['email'],
      phone: map['phone'],
      photoURL: map['photoURL'],
      eventIds: List<dynamic>.from(map['eventIds']),
      friendIds: List<dynamic>.from(map['friendIds']),
    );
  }
}