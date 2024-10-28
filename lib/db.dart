class MockDatabase {
  static List<Map<String, dynamic>> friends = [
    {
      'id': 1,
      'name': 'Ahmed',
      'userName': 'Ahmed',
      'email': 'Ahmed@email.com',
      'profileImage': 'asset/profile.png',
      'events': [1, 2],
      'isLoggedin': false
    },
    {
      'id': 2,
      'name': 'Dina',
      'userName': 'Dina',
      'email': 'Dina@email.com',
      'profileImage': 'asset/profile.png',
      'events': [3],
      'isLoggedin': false
    },
    {
      'id': 3,
      'name': 'Joe',
      'userName': 'Joe',
      'email': 'Joe@email.com',
      'profileImage': 'asset/profile.png',
      'events': [],
      'isLoggedin': false
    },
    {
      'id': 4,
      'name': 'Farah',
      'userName': 'Farah',
      'email': 'farah@email.com',
      'profileImage': 'asset/profile.png',
      'events': [3, 1],
      'isLoggedin': true
    }
  ];

  static List<Map<String, dynamic>> events = [
    {
      'id': 1,
      'name': 'Birthday',
      'category': 'Birthday',
      'status': 'Upcoming',
      'date': DateTime.parse('2024-11-15'), // Changed to DateTime
      'gifts': [1, 2, 3]
    },
    {
      'id': 2,
      'name': 'Graduation',
      'category': 'Graduation',
      'status': 'Upcoming',
      'date': DateTime.parse('2025-05-20'),
      'gifts': [4, 5]
    },
    {
      'id': 3,
      'name': 'Wedding',
      'category': 'Wedding',
      'status': 'Upcoming',
      'date': DateTime.parse('2024-12-10'),
      'gifts': [6]
    },
    {
      'id': 4,
      'name': 'Engagement',
      'category': 'Engagement',
      'status': 'Past',
      'date': DateTime.parse('2023-08-30'),
      'gifts': [7, 8]
    },
  ];
  static List<Map<String, dynamic>> gifts = [
    {
      'id': 1,
      'eventId': 1,
      'name': 'Smartphone',
      'description': 'Latest smartphone model',
      'category': 'Electronics',
      'price': 500.00,
      'status': 'Available',

    },
    {
      'id': 2,
      'eventId': 1,
      'name': 'Book',
      'description': 'Bestselling book',
      'category': 'Books',
      'price': 15.00,
      'status': 'Pledged',
    },
    {
      'id': 3,
      'eventId': 1,
      'name': 'Headphones',
      'description': 'Noise-canceling headphones',
      'category': 'Electronics',
      'price': 150.00,
      'status': 'Available',
    },
    {
      'id': 4,
      'eventId': 2,
      'name': 'Laptop',
      'description': 'High-performance laptop',
      'category': 'Electronics',
      'price': 1000.00,
      'status': 'Pledged',
    },
    {
      'id': 5,
      'eventId': 2,
      'name': 'Backpack',
      'description': 'Durable travel backpack',
      'category': 'Accessories',
      'price': 80.00,
      'status': 'Available',
    },
    {
      'id': 6,
      'eventId': 3,
      'name': 'Jewelry Set',
      'description': 'Elegant jewelry set for wedding',
      'category': 'Jewelry',
      'price': 300.00,
      'status': 'Pledged',
    },
    {
      'id': 7,
      'eventId': 4,
      'name': 'Perfume',
      'description': 'Luxury fragrance',
      'category': 'Fragrances',
      'price': 120.00,
      'status': 'Available',
    },
    {
      'id': 8,
      'eventId': 4,
      'name': 'Watch',
      'description': 'Classic analog watch',
      'category': 'Accessories',
      'price': 250.00,
      'status': 'Pledged',
    },
  ];

  // Helper method to get gifts by event ID
  static List<Map<String, dynamic>> getGiftsByEventId(int eventId) {
    return gifts.where((gift) => gift['eventId'] == eventId).toList();
  }

  // Helper method to get events by friend ID
  static List<Map<String, dynamic>> getEventsByFriendId(int friendId) {
    var friend = friends.firstWhere((friend) => friend['id'] == friendId,
        orElse: () => {});
    if (friend.isNotEmpty) {
      return events.where((event) => friend['events'].contains(event['id']))
          .toList();
    }
    return [];
  }

  // Helper method to get pledged gifts for My Pledged Gifts page
  static List<Map<String, dynamic>> getPledgedGifts() {
    return gifts.where((gift) => gift['status'] == 'Pledged').toList();
  }

// New method to get gifts for a specific friend and event
  static List<Map<String, dynamic>> getGiftsForFriendEvent(int friendId,
      int eventId) {
    var friend = friends.firstWhere((friend) => friend['id'] == friendId,
        orElse: () => {});
    if (friend.isNotEmpty && friend['events'].contains(eventId)) {
      return getGiftsByEventId(eventId);
    }
    return [];
  }

  // New method to get gifts for a specific friend
  static List<Map<String, dynamic>> getGiftsForFriend(int friendId) {
    var friendEvents = getEventsByFriendId(friendId);
    var friendGifts = friendEvents.expand((event) =>
        getGiftsByEventId(event['id'])).toList();
    return friendGifts;
  }

  // New method to get event by event ID
  static Map<String, dynamic>? getEventById(int eventId) {
    return events.firstWhere((event) => event['id'] == eventId,
        orElse: () => {});
  }
}
