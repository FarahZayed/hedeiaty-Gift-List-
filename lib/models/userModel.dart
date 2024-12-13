import 'dart:convert';

class UserlocalDB {
  final String uid;
  final String username;
  final String email;
  final String phone;
  final List<dynamic> friendIds;
  final List<dynamic>eventIds;
  final String photoURL;
  int pendingSync;

  UserlocalDB({
    required this.uid,
    required this.username,
    required this.email,
    required this.phone,
    required this.eventIds,
    required this.friendIds,
    required this.photoURL,
    this.pendingSync=0,
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
      'pendingSync':pendingSync
    };
  }

  factory UserlocalDB.fromMap(Map<String, dynamic> map) {
    return UserlocalDB(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      eventIds: map['eventIds'] is String
            ? jsonDecode(map['eventIds']) as List<dynamic>
            : List<dynamic>.from(map['eventIds'] ?? []),
      friendIds: map['friendIds'] is String
          ? jsonDecode(map['friendIds']) as List<dynamic>
          : List<dynamic>.from(map['friendIds'] ?? []),
      photoURL: map['photoURL'] ?? '',
      pendingSync: map['pendingSync'],
    );
  }
}