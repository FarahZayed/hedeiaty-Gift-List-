import 'dart:convert';

class Event {
  final String id;
  final String name;
  final String date;
  final String location;
  final String description;
  final String category;
  final List<String> giftIds;
  final String status;
  final String userId;

  Event({
    required this.id,
    required this.name,
    required this.date,
    required this.location,
    required this.description,
    required this.userId,
    required this.giftIds,
    required this.category,
    required this.status,
  });

  // Convert Event to a map for database storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'location': location,
      'description': description,
      'userId': userId,
      'giftIds': jsonEncode(giftIds),
      'category': category,
      'status': status,
    };
  }

  // Convert map retrieved from database to Event
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      date: map['date'] ?? '',
      location: map['location'] ?? '',
      description: map['description'] ?? '',
      userId: map['userId'] ?? '',
      giftIds: map['giftIds'] is String
          ? List<String>.from(jsonDecode(map['giftIds'])) // Decode JSON string
          : List<String>.from(map['giftIds'] ?? []),
      category: map['category'] ?? '',
      status: map['status'] ?? '',
    );
  }
}
