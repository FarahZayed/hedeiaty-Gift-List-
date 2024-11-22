import 'dart:async';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/widgets.dart' ;
import 'dart:developer';
import 'dart:io';
//import 'package:path_provider/path_provider.dart';
import 'models/eventModel.dart';
import 'models/friendModel.dart';
import 'models/giftModel.dart';
import 'models/userModel.dart';


class DatabaseService{
  static Database? _database;
  int version =1;

  Future<Database?> get database async{
    if(_database ==null){
      log('INTIALIZING\n');
      _database = await initialize();
    }
    return _database;
  }

  initialize() async{
    String mypath = await getDatabasesPath();
    log('MY PATH::'+mypath+'\n');
    String path = join(mypath,'database.db');
    log ('PATH::'+path+'\n');
    Database mydb = await openDatabase(path ,version: version, onCreate: _onCreate);
    return mydb;
  }



  void _onCreate(Database db, int version) async {
    log('ON CREATE\n');
    await db.execute(
      'CREATE TABLE Users('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'name TEXT, '
          'email TEXT, '
          'preferences TEXT, '
          'password TEXT'
          ')',
    );
    await db.execute(
      'CREATE TABLE Events('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'name TEXT, '
          'date TEXT, '
          'location TEXT, '
          'description TEXT, '
          'userId INTEGER, '
          'FOREIGN KEY(userId) REFERENCES Users(id)'
          ')',
    );
    await db.execute(
      'CREATE TABLE Gifts('
          'id INTEGER PRIMARY KEY AUTOINCREMENT, '
          'name TEXT, '
          'description TEXT, '
          'category TEXT, '
          'price REAL, '
          'status TEXT, '
          'eventId INTEGER, '
          'FOREIGN KEY(eventId) REFERENCES Events(id)'
          ')',
    );
    await db.execute(
      'CREATE TABLE Friends('
          'userId INTEGER, '
          'friendId INTEGER AUTOINCREMENT, '
          'PRIMARY KEY(userId, friendId), '
          'FOREIGN KEY(userId) REFERENCES Users(id), '
          'FOREIGN KEY(friendId) REFERENCES Users(id)'
          ')',
    );

    // Insert dummy data
    await db.insert('Users', {
      'username': 'Farah Zayed',
      'email': 'farah.zayed@example.com',
      'password': '123',
      'preferences': 'None',
    });
    await db.insert('Users', {
      'username': 'Jane Smith',
      'email': 'jane.smith@example.com',
      'password': 'password',
      'preferences': 'Gift Preferences',
    });
    log('Dummy data inserted');
  }


  //User CRUD
  Future<List<User>> getUsers() async {
    Database? db = await database;
    var data = await db!.rawQuery('SELECT * FROM Users');
    List<User> users = List.generate(data.length, (index) => User.fromMap(data[index]));
    print(users.length);
    return users;
  }

  Future<void> insertUser(User user) async {
    Database? db = await database;
    var data = await db!.rawInsert(
      'INSERT INTO Users(name, email, password,preferences) VALUES(?,?,?,?)',
      [user.name, user.email, user.preferences],
    );
    log('inserted:: $data');
  }

  Future<void> editUser(User user) async {
    Database? db = await database;
    var data = await db!.rawUpdate(
      'UPDATE Users SET name=?, email=?, preferences=? WHERE id=?',
      [user.name, user.email, user.preferences, user.id],
    );
    log('updated $data');
  }

  Future<void> deleteUser(int id) async {
    Database? db = await database;
    var data = await db!.rawDelete('DELETE FROM Users WHERE id=?', [id]);
    log('deleted $data');
  }

//Events CRUD
//   Future<List<Event>> getEvents() async {
//     Database? db = await database;
//     var data = await db!.rawQuery('SELECT * FROM Events');
//     List<Event> events = List.generate(data.length, (index) => Event.fromMap(data[index]));
//     print(events.length);
//     return events;
//   }
//
//   Future<void> insertEvent(Event event) async {
//     final db = await _databaseService.database;
//     var data = await db.rawInsert(
//       'INSERT INTO Events(name, date, location, description, userId) VALUES(?,?,?,?,?)',
//       [event.name, event.date, event.location, event.description, event.userId],
//     );
//     log('inserted $data');
//   }
//
//   Future<void> editEvent(Event event) async {
//     final db = await _databaseService.database;
//     var data = await db.rawUpdate(
//       'UPDATE Events SET name=?, date=?, location=?, description=?, userId=? WHERE id=?',
//       [event.name, event.date, event.location, event.description, event.userId, event.id],
//     );
//     log('updated $data');
//   }
//
//   Future<void> deleteEvent(int id) async {
//     final db = await _databaseService.database;
//     var data = await db.rawDelete('DELETE FROM Events WHERE id=?', [id]);
//     log('deleted $data');
//   }
//
// //Gift CRUD
//   Future<List<Gift>> getGifts() async {
//     final db = await _databaseService.database;
//     var data = await db.rawQuery('SELECT * FROM Gifts');
//     List<Gift> gifts = List.generate(data.length, (index) => Gift.fromMap(data[index]));
//     print(gifts.length);
//     return gifts;
//   }
//
//   Future<void> insertGift(Gift gift) async {
//     final db = await _databaseService.database;
//     var data = await db.rawInsert(
//       'INSERT INTO Gifts(name, description, category, price, status, eventId) VALUES(?,?,?,?,?,?)',
//       [gift.name, gift.description, gift.category, gift.price, gift.status, gift.eventId],
//     );
//     log('inserted $data');
//   }
//
//   Future<void> editGift(Gift gift) async {
//     final db = await _databaseService.database;
//     var data = await db.rawUpdate(
//       'UPDATE Gifts SET name=?, description=?, category=?, price=?, status=?, eventId=? WHERE id=?',
//       [gift.name, gift.description, gift.category, gift.price, gift.status, gift.eventId, gift.id],
//     );
//     log('updated $data');
//   }
//
//   Future<void> deleteGift(int id) async {
//     final db = await _databaseService.database;
//     var data = await db.rawDelete('DELETE FROM Gifts WHERE id=?', [id]);
//     log('deleted $data');
//   }
//
// //Friend CRUD
//   Future<List<Friend>> getFriends() async {
//     final db = await _databaseService.database;
//     var data = await db.rawQuery('SELECT * FROM Friends');
//     List<Friend> friends = List.generate(data.length, (index) => Friend.fromMap(data[index]));
//     print(friends.length);
//     return friends;
//   }
//
//   Future<void> insertFriend(Friend friend) async {
//     final db = await _databaseService.database;
//     var data = await db.rawInsert(
//       'INSERT INTO Friends(userId, friendId) VALUES(?,?)',
//       [friend.userId, friend.friendId],
//     );
//     log('inserted $data');
//   }
//
//   Future<void> deleteFriend(int userId, int friendId) async {
//     final db = await _databaseService.database;
//     var data = await db.rawDelete('DELETE FROM Friends WHERE userId=? AND friendId=?', [userId, friendId]);
//     log('deleted $data');
//   }
}




// class DatabaseService {
//   static final DatabaseService _databaseService = DatabaseService._internal();
//
//   factory DatabaseService() => _databaseService;
//
//   DatabaseService._internal();
//
//   static Database? _database;
//
//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await initDatabase();
//     return _database!;
//   }
//
//
//   Future initDatabase() async {
//     // Get the platform-specific directory for storing application data
//     final directory = Platform.isAndroid
//         ? await getDatabasesPath() // Android-specific database path
//         : Directory(
//         '${Directory.current.path}/Documents')
//         .path;
//
//     // Construct the path for your database
//     String path = join(directory, 'Hedieaty.db');
//     log('Database path: $path');
//
//     // Open the database
//     return await openDatabase(path, onCreate: _onCreate, version: 1);
//   }
//
//
//
//
// }



//
//   Future<Database> openMyDatabase() async {
//     return await openDatabase(
//       // join method is used to join the path of the database with the path of the app's document directory.
//         join(await getDatabasesPath(), 'HedieatyDatabase.db'),
//         // The version of the database. This is used to manage database schema changes.
//         version: 1,
//         // onCreate is a callback function that is called ONLY when the database is created for the first time.
//         onCreate: (db, version) {
//           return db.execute(
//             'CREATE TABLE todoList(id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, title TEXT, status  INTEGER)',
//           );
//           //Here we are creating a table named todoList with three columns: id, title, and status.
//           //The id column is the primary key and is set to autoincrement.
//           //We use INTEGER for the status column because SQLite does not have a boolean data type.
//           //Instead, we use 0 for false and 1 for true.
//         });
//   }
//
//   Future<void> insertTask(String title, bool status) async {
//     //db is the instance of the database that we get from the openMyDatabase function.
//     final db = await openMyDatabase();
//     //after getting the database instance, we insert the task into the todoList table.
//     //insert method takes three arguments: the name of the table, the data to be inserted, and the conflictAlgorithm.
//     //data is a map with the column names as keys and the values to be inserted as values.
//     //We use ConflictAlgorithm.replace to replace the task if it already exists.
//     //here we don't need to insert the id column because it is set to autoincrement.
//     db.insert(
//         'todoList',
//         {
//           'title': title,
//           'status': status ? 1 : 0,
//           //We use 1 for true and 0 for false.
//         },
//         conflictAlgorithm: ConflictAlgorithm.replace);
//   }
//
//   Future<void> deleteTask(int id) async {
//     final db = await openMyDatabase();
//     //delete method takes two arguments: the name of the table and the where clause.
//     //we are using unique id for each task as the where clause to delete the task with the given id.
//     db.delete('todoList', where: 'id = ?', whereArgs: [id]);
//   }
//
//   Future<void> updateTask(int id, bool status) async {
//     final db = await openMyDatabase();
//     //update method takes four arguments: the name of the table, the data to be updated, the where clause, and the whereArgs.
//     //In this case, we are updating the status of the task with the given id.
//     db.update(
//         'todoList',
//         {
//           'status': status ? 1 : 0,
//           //We use 1 for true and 0 for false.
//         },
//         where: 'id = ?',
//         whereArgs: [id]);
//   }
//
//   Future<List<Map<String, dynamic>>> getTasks() async {
//     final db = await openMyDatabase();
//     //query method is used to get the tasks from the todoList table.
//     //It takes the name of the table as an argument.
//     //and returns a list of maps where each map represents a task.
//     //like [{id: 1, title: 'Task 1', status: 1}, {id: 2, title: 'Task 2', status: 0}]
//     return await db.query('todoList');
//   }
// }
//
// }




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