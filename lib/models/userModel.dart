import 'dart:convert';

class UserlocalDB {
  final String uid;
  final String username;
  final String email;
  final String phone;
  final List<String> friendIds;
  final List<String>eventIds;
  final String photoURL;
  int pendingSync;
  final String fcmToken;

  UserlocalDB({
    required this.uid,
    required this.username,
    required this.email,
    required this.phone,
    required this.eventIds,
    required this.friendIds,
    required this.photoURL,
    this.pendingSync=0,
    required this.fcmToken
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'email': email,
      'phone': phone,
      'friendIds': jsonEncode(friendIds),
      'eventIds': jsonEncode(eventIds),
      'photoURL': photoURL,
      'pendingSync': pendingSync,
      'fcmToken':fcmToken
    };
  }



  factory UserlocalDB.fromMap(Map<String, dynamic> map) {
    return UserlocalDB(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      friendIds: map['friendIds'] is String
          ? List<String>.from(jsonDecode(map['friendIds']))
          : List<String>.from(map['friendIds'] ?? []),
      eventIds: map['eventIds'] is String
          ? List<String>.from(jsonDecode(map['eventIds']))
          : List<String>.from(map['eventIds'] ?? []),
      photoURL: map['photoURL'] ?? '',
      pendingSync: map['pendingSync'] ?? 0,
      fcmToken: map['fcmToken']
    );
  }


}