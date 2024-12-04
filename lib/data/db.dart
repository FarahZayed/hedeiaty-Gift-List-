import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:hedieaty/models/eventModel.dart';
import 'package:hedieaty/models/userModel.dart';

class LocalDatabase {
  static final LocalDatabase _instance = LocalDatabase._();
  static Database? _database;

  LocalDatabase._();

  factory LocalDatabase() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB("app_database.db");
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    //user table
    await db.execute('''
      CREATE TABLE user (
        uid TEXT PRIMARY KEY,
        username TEXT,
        email TEXT,
        phone TEXT,
        eventIds TEXT,
        friendIds TEXT,
        photoURL TEXT
      );
    ''');

    // Event table
    await db.execute('''
    CREATE TABLE event (
      id TEXT PRIMARY KEY,
      name TEXT,
      date TEXT,
      location TEXT,
      description TEXT,
      userId TEXT,
      giftIds TEXT,
      category TEXT,
      status TEXT,
      pendingSync INTEGER DEFAULT 0
    );
  ''');

  }

  Future<void> saveUser(UserlocalDB user) async {
    final db = await database;
    await db.insert('user', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<UserlocalDB?> getUser() async {
    final db = await database;
    final result = await db.query('user');
    return result.isNotEmpty ? UserlocalDB.fromMap(result.first) : null;
  }

  Future<void> clearUser() async {
    final db = await database;
    await db.delete('user');
  }

  Future<void> saveEvent(Event event, {bool pendingSync = false}) async {
    final db = await database;
    await db.insert('event', {
      ...event.toMap(),
      'pendingSync': pendingSync ? 1 : 0,
    });
  }

  Future<List<Event>> getPendingEvents() async {
    final db = await database;
    final result = await db.query('event', where: 'pendingSync = ?', whereArgs: [1]);
    return result.map((e) => Event.fromMap(e)).toList();
  }

}






















// import 'dart:async';
//
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'package:flutter/widgets.dart' ;
// import 'dart:developer';
// import 'dart:io';
//
// import 'models/eventModel.dart';
// import 'models/friendModel.dart';
// import 'models/giftModel.dart';
// import 'models/userModel.dart';
//
//
// class DatabaseService{
//   static Database? _database;
//   final int version = 1;
//
//   Future<Database?> get database async {
//     if (_database == null) {
//       log('Initializing Database\n');
//       _database = await initialize();
//     }
//     return _database;
//   }
//
//   Future<Database> initialize() async {
//     String mypath = await getDatabasesPath();
//     String path = join(mypath, 'database.db');
//
//     // Open the database
//     Database mydb = await openDatabase(
//       path,
//       version: version,
//       onCreate: _onCreate,
//       onUpgrade: _onUpgrade,
//       //onConfigure: _onConfigure,
//     );
//
//     return mydb;
//   }
//
//   Future<void> _onCreate(Database db, int version) async {
//     log('Creating Tables\n');
//
//     await db.execute(
//       'CREATE TABLE Users('
//           'id TEXT PRIMARY KEY, '
//           'name TEXT, '
//           'email TEXT UNIQUE, '
//           'preferences TEXT'
//           ')',
//     );
//
//     await db.execute(
//       'CREATE TABLE Events('
//           'id INTEGER PRIMARY KEY AUTOINCREMENT, '
//           'name TEXT, '
//           'date TEXT, '
//           'location TEXT, '
//           'description TEXT, '
//           'userId INTEGER, '
//           'FOREIGN KEY(userId) REFERENCES Users(id)'
//           ')',
//     );
//
//     await db.execute(
//       'CREATE TABLE Gifts('
//           'id INTEGER PRIMARY KEY AUTOINCREMENT, '
//           'name TEXT, '
//           'description TEXT, '
//           'category TEXT, '
//           'price REAL, '
//           'status TEXT, '
//           'eventId INTEGER, '
//           'FOREIGN KEY(eventId) REFERENCES Events(id)'
//           ')',
//     );
//
//     await db.execute(
//       'CREATE TABLE Friends('
//           'userId INTEGER, '
//           'friendId INTEGER PRIMARY KEY AUTOINCREMENT, '
//           'FOREIGN KEY(userId) REFERENCES Users(id), '
//           'FOREIGN KEY(friendId) REFERENCES Users(id)'
//           ')',
//     );
//     await db.insert('Users', {
//       'id': 'kpjGp8UbDze494c1ml6xkCJEg8s2',
//       'name': 'Farah Zayed',
//       'email': 'farahzayed@email.com',
//       'preferences': 'None',
//     });
//
//     log('Tables Created\n');
//   }
//
//   Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
//     log('Upgrading Database\n');
//     await _dropAllTables(db);
//     await _onCreate(db, version);
//   }
//
//   // Future<void> _onConfigure(Database db) async {
//   //   log('Configuring Database: Dropping Existing Database\n');
//   //   await _dropAllTables(db);
//   // }
//
//   Future<void> _dropAllTables(Database db) async {
//     log('Dropping Tables\n');
//     await db.execute('DROP TABLE IF EXISTS UserlocalDB');
//     await db.execute('DROP TABLE IF EXISTS Users');
//     await db.execute('DROP TABLE IF EXISTS Events');
//     await db.execute('DROP TABLE IF EXISTS Gifts');
//     await db.execute('DROP TABLE IF EXISTS Friends');
//   }
//
//
//   //User CRUD
//   Future<List<UserlocalDB>> getUsers() async {
//     Database? db = await database;
//     var data = await db!.rawQuery('SELECT * FROM Users');
//     List<UserlocalDB> users = List.generate(data.length, (index) => UserlocalDB.fromMap(data[index]));
//     print(users.length);
//     return users;
//   }
//
//   Future<void> insertUser(UserlocalDB user) async {
//     Database? db = await database;
//     var data = await db!.rawInsert(
//       'INSERT INTO Users(name, email, password,preferences) VALUES(?,?,?,?)',
//       [user.name, user.email, user.preferences],
//     );
//     log('inserted:: $data');
//   }
//
//   Future<void> editUser(UserlocalDB user) async {
//     Database? db = await database;
//     var data = await db!.rawUpdate(
//       'UPDATE Users SET name=?, email=?, preferences=? WHERE id=?',
//       [user.name, user.email, user.preferences, user.id],
//     );
//     log('updated $data');
//   }
//
//   Future<void> deleteUser(String id) async {
//     Database? db = await database;
//     var data = await db!.rawDelete('DELETE FROM Users WHERE id=?', [id]);
//     log('deleted $data');
//   }
//
//   Future<UserlocalDB?> getUserByEmail(String email) async {
//     Database? db = await database;
//     List<Map<String, dynamic>> result = await db!.query(
//       'Users',
//       where: 'email = ?',
//       whereArgs: [email],
//     );
//
//     if (result.isNotEmpty) {
//       print("User found in DB: ${result.first}");
//       return UserlocalDB.fromMap(result.first);
//     } else {
//       print("No user found with email: $email");
//       return null;
//     }
//   }
//
// //Events CRUD
// //   Future<List<Event>> getEvents() async {
// //     Database? db = await database;
// //     var data = await db!.rawQuery('SELECT * FROM Events');
// //     List<Event> events = List.generate(data.length, (index) => Event.fromMap(data[index]));
// //     print(events.length);
// //     return events;
// //   }
// //
// //   Future<void> insertEvent(Event event) async {
// //     final db = await _databaseService.database;
// //     var data = await db.rawInsert(
// //       'INSERT INTO Events(name, date, location, description, userId) VALUES(?,?,?,?,?)',
// //       [event.name, event.date, event.location, event.description, event.userId],
// //     );
// //     log('inserted $data');
// //   }
// //
// //   Future<void> editEvent(Event event) async {
// //     final db = await _databaseService.database;
// //     var data = await db.rawUpdate(
// //       'UPDATE Events SET name=?, date=?, location=?, description=?, userId=? WHERE id=?',
// //       [event.name, event.date, event.location, event.description, event.userId, event.id],
// //     );
// //     log('updated $data');
// //   }
// //
// //   Future<void> deleteEvent(int id) async {
// //     final db = await _databaseService.database;
// //     var data = await db.rawDelete('DELETE FROM Events WHERE id=?', [id]);
// //     log('deleted $data');
// //   }
// //
// // //Gift CRUD
// //   Future<List<Gift>> getGifts() async {
// //     final db = await _databaseService.database;
// //     var data = await db.rawQuery('SELECT * FROM Gifts');
// //     List<Gift> gifts = List.generate(data.length, (index) => Gift.fromMap(data[index]));
// //     print(gifts.length);
// //     return gifts;
// //   }
// //
// //   Future<void> insertGift(Gift gift) async {
// //     final db = await _databaseService.database;
// //     var data = await db.rawInsert(
// //       'INSERT INTO Gifts(name, description, category, price, status, eventId) VALUES(?,?,?,?,?,?)',
// //       [gift.name, gift.description, gift.category, gift.price, gift.status, gift.eventId],
// //     );
// //     log('inserted $data');
// //   }
// //
// //   Future<void> editGift(Gift gift) async {
// //     final db = await _databaseService.database;
// //     var data = await db.rawUpdate(
// //       'UPDATE Gifts SET name=?, description=?, category=?, price=?, status=?, eventId=? WHERE id=?',
// //       [gift.name, gift.description, gift.category, gift.price, gift.status, gift.eventId, gift.id],
// //     );
// //     log('updated $data');
// //   }
// //
// //   Future<void> deleteGift(int id) async {
// //     final db = await _databaseService.database;
// //     var data = await db.rawDelete('DELETE FROM Gifts WHERE id=?', [id]);
// //     log('deleted $data');
// //   }
// //
// // //Friend CRUD
// //   Future<List<Friend>> getFriends() async {
// //     final db = await _databaseService.database;
// //     var data = await db.rawQuery('SELECT * FROM Friends');
// //     List<Friend> friends = List.generate(data.length, (index) => Friend.fromMap(data[index]));
// //     print(friends.length);
// //     return friends;
// //   }
// //
// //   Future<void> insertFriend(Friend friend) async {
// //     final db = await _databaseService.database;
// //     var data = await db.rawInsert(
// //       'INSERT INTO Friends(userId, friendId) VALUES(?,?)',
// //       [friend.userId, friend.friendId],
// //     );
// //     log('inserted $data');
// //   }
// //
// //   Future<void> deleteFriend(int userId, int friendId) async {
// //     final db = await _databaseService.database;
// //     var data = await db.rawDelete('DELETE FROM Friends WHERE userId=? AND friendId=?', [userId, friendId]);
// //     log('deleted $data');
// //   }
// }
//
//
//
//
//
// class MockDatabase {
//   static List<Map<String, dynamic>> friends = [
//     {
//       'id': 1,
//       'name': 'Ahmed',
//       'userName': 'Ahmed',
//       'email': 'Ahmed@email.com',
//       'profileImage': 'asset/profile.png',
//       'events': [1, 2],
//       'isLoggedin': false
//     },
//     {
//       'id': 2,
//       'name': 'Dina',
//       'userName': 'Dina',
//       'email': 'Dina@email.com',
//       'profileImage': 'asset/profile.png',
//       'events': [3],
//       'isLoggedin': false
//     },
//     {
//       'id': 3,
//       'name': 'Joe',
//       'userName': 'Joe',
//       'email': 'Joe@email.com',
//       'profileImage': 'asset/profile.png',
//       'events': [],
//       'isLoggedin': false
//     },
//     {
//       'id': 4,
//       'name': 'Farah',
//       'userName': 'Farah',
//       'email': 'farah@email.com',
//       'profileImage': 'asset/profile.png',
//       'events': [3, 1],
//       'isLoggedin': true
//     }
//   ];
//
//   static List<Map<String, dynamic>> events = [
//     {
//       'id': 1,
//       'name': 'Birthday',
//       'category': 'Birthday',
//       'status': 'Upcoming',
//       'date': DateTime.parse('2024-11-15'), // Changed to DateTime
//       'gifts': [1, 2, 3]
//     },
//     {
//       'id': 2,
//       'name': 'Graduation',
//       'category': 'Graduation',
//       'status': 'Upcoming',
//       'date': DateTime.parse('2025-05-20'),
//       'gifts': [4, 5]
//     },
//     {
//       'id': 3,
//       'name': 'Wedding',
//       'category': 'Wedding',
//       'status': 'Upcoming',
//       'date': DateTime.parse('2024-12-10'),
//       'gifts': [6]
//     },
//     {
//       'id': 4,
//       'name': 'Engagement',
//       'category': 'Engagement',
//       'status': 'Past',
//       'date': DateTime.parse('2023-08-30'),
//       'gifts': [7, 8]
//     },
//   ];
//   static List<Map<String, dynamic>> gifts = [
//     {
//       'id': 1,
//       'eventId': 1,
//       'name': 'Smartphone',
//       'description': 'Latest smartphone model',
//       'category': 'Electronics',
//       'price': 500.00,
//       'status': 'Available',
//
//     },
//     {
//       'id': 2,
//       'eventId': 1,
//       'name': 'Book',
//       'description': 'Bestselling book',
//       'category': 'Books',
//       'price': 15.00,
//       'status': 'Pledged',
//     },
//     {
//       'id': 3,
//       'eventId': 1,
//       'name': 'Headphones',
//       'description': 'Noise-canceling headphones',
//       'category': 'Electronics',
//       'price': 150.00,
//       'status': 'Available',
//     },
//     {
//       'id': 4,
//       'eventId': 2,
//       'name': 'Laptop',
//       'description': 'High-performance laptop',
//       'category': 'Electronics',
//       'price': 1000.00,
//       'status': 'Pledged',
//     },
//     {
//       'id': 5,
//       'eventId': 2,
//       'name': 'Backpack',
//       'description': 'Durable travel backpack',
//       'category': 'Accessories',
//       'price': 80.00,
//       'status': 'Available',
//     },
//     {
//       'id': 6,
//       'eventId': 3,
//       'name': 'Jewelry Set',
//       'description': 'Elegant jewelry set for wedding',
//       'category': 'Jewelry',
//       'price': 300.00,
//       'status': 'Pledged',
//     },
//     {
//       'id': 7,
//       'eventId': 4,
//       'name': 'Perfume',
//       'description': 'Luxury fragrance',
//       'category': 'Fragrances',
//       'price': 120.00,
//       'status': 'Available',
//     },
//     {
//       'id': 8,
//       'eventId': 4,
//       'name': 'Watch',
//       'description': 'Classic analog watch',
//       'category': 'Accessories',
//       'price': 250.00,
//       'status': 'Pledged',
//     },
//   ];
//
//   // Helper method to get gifts by event ID
//   static List<Map<String, dynamic>> getGiftsByEventId(int eventId) {
//     return gifts.where((gift) => gift['eventId'] == eventId).toList();
//   }
//
//   // Helper method to get events by friend ID
//   static List<Map<String, dynamic>> getEventsByFriendId(int friendId) {
//     var friend = friends.firstWhere((friend) => friend['id'] == friendId,
//         orElse: () => {});
//     if (friend.isNotEmpty) {
//       return events.where((event) => friend['events'].contains(event['id']))
//           .toList();
//     }
//     return [];
//   }
//
//   // Helper method to get pledged gifts for My Pledged Gifts page
//   static List<Map<String, dynamic>> getPledgedGifts() {
//     return gifts.where((gift) => gift['status'] == 'Pledged').toList();
//   }
//
// // New method to get gifts for a specific friend and event
//   static List<Map<String, dynamic>> getGiftsForFriendEvent(int friendId,
//       int eventId) {
//     var friend = friends.firstWhere((friend) => friend['id'] == friendId,
//         orElse: () => {});
//     if (friend.isNotEmpty && friend['events'].contains(eventId)) {
//       return getGiftsByEventId(eventId);
//     }
//     return [];
//   }
//
//   // New method to get gifts for a specific friend
//   static List<Map<String, dynamic>> getGiftsForFriend(int friendId) {
//     var friendEvents = getEventsByFriendId(friendId);
//     var friendGifts = friendEvents.expand((event) =>
//         getGiftsByEventId(event['id'])).toList();
//     return friendGifts;
//   }
//
//   // New method to get event by event ID
//   static Map<String, dynamic>? getEventById(int eventId) {
//     return events.firstWhere((event) => event['id'] == eventId,
//         orElse: () => {});
//   }
// }