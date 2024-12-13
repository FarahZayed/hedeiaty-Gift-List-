import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:hedieaty/models/eventModel.dart';
import 'package:hedieaty/models/userModel.dart';
import 'package:hedieaty/models/giftModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty/services/connectivityController.dart';

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

    return await openDatabase(
      path,
      version: 5,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      print("Database closed.");
    }
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE user ADD COLUMN photoURL TEXT');
    }
    if (oldVersion < 3) {
      await db.execute('''
      CREATE TABLE IF NOT EXISTS event (
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
    if (oldVersion < 4) {
      await db.execute('ALTER TABLE user ADD COLUMN pendingSync INTEGER');
    }
    if (oldVersion < 5) {
      await db.execute('''
        CREATE TABLE gifts (
          id TEXT PRIMARY KEY,
          name TEXT,
          description TEXT,
          eventId TEXT,
          price FLOAT,
          category TEXT,
          status TEXT,
          image TEXT,
          pendingSync INTEGER DEFAULT 0
        );
      ''');

    }
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
        photoURL TEXT,
        pendingSync INTEGER DEFAULT 0
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
    //gift table
    await db.execute('''
    CREATE TABLE gifts (
      id TEXT PRIMARY KEY,
      name TEXT,
      description TEXT,
      eventId TEXT,
      price FLOAT,
      category TEXT,
      status TEXT,
      image TEXT,
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
    print('Event::'+event.toMap().toString());
    final eventMap = {
      ...event.toMap(),
      'pendingSync': pendingSync ? 1 : 0,
    };

    await db.insert('event', eventMap, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Event>> getPendingEvents() async {
    final db = await database;
    print("PENDING EVENTSS");
    final result = await db.query('event', where: 'pendingSync = ?', whereArgs: [1]);
    return result.map((e) => Event.fromMap(e)).toList();

  }

  Future<void> updateEventPendingSync( String eventId) async {
    final db= await database;
    await db.update(
      'event',
      {'pendingSync': 0},
      where: 'id = ?',
      whereArgs: [eventId],
    );
  }

  Future<void> updategiftPendingSync( String giftId) async {
    final db= await database;
    db.update('gifts', {'pendingSync': 0}, where: 'id = ?', whereArgs: [giftId]);
  }

  Future<void> insertGift( Map<String, dynamic> giftData) async {
    final db = await database;
    await db.insert(
      'gifts',
      {
        ...giftData,
        'pendingSync': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getDeleteSyncEvents() async {
    final db = await database;
    return await db.query(
      'event',
      where: 'pendingSync = ?',
      whereArgs: [2],
    );
  }


  //sync the databse with firestore
  Future<void> syncUnsyncedData(String userId) async {

    final db = await database;

    try {
      bool online = await connectivityController.isOnline();
      print("Database sync started. Online: $online");

      if (!online) {
        print("Offline mode: Skipping Firebase sync.");
        return;
      }

      // Sync User Data
      await _syncUserData(userId);

      // Sync Events
      await _syncEvents(userId);

      // Sync Gifts
      await _syncGifts(userId, db);

      print("Database sync completed.");
    } catch (e) {
      print("Error during sync: $e");
    }
  }

// Sync User Data
  Future<void> _syncUserData(String userId) async {
    final db = await LocalDatabase().database;

    try {
      final localUser = await db.query(
        'user',
        where: 'uid = ?',
        whereArgs: [userId],
      );

      if (localUser.isNotEmpty) {
        print("SYNCING TO FIREBASE");
        final userLocal = UserlocalDB.fromMap(localUser.first);
        print(userLocal.pendingSync);
        if (userLocal.pendingSync == 1) {
          // Update Firestore with local data
          print("Syncing user changes to Firestore for user: $userId");
          await FirebaseFirestore.instance.collection('users').doc(userId).set(userLocal.toMap());

          // Mark as synced locally
          await db.update(
            'user',
            {'pendingSync': 0},
            where: 'uid = ?',
            whereArgs: [userId],
          );
        } else {
          // Fetch latest data from Firestore
          print("Fetching latest user data from Firestore for user: $userId");
          final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

          if (userDoc.exists) {
            final userData = userDoc.data()!;
            final updatedUser = UserlocalDB.fromMap(userData);

            // Overwrite local user data
            await db.insert(
              'user',
              {
                ...updatedUser.toMap(),
                'pendingSync': 0,
              },
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }
      } else {
        // If no local user exists, fetch and save from Firestore
        print("No local user found. Fetching from Firestore for user: $userId");
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

        if (userDoc.exists) {
          final userData = userDoc.data()!;
          final newUser = UserlocalDB.fromMap(userData);

          await db.insert(
            'user',
            {
              ...newUser.toMap(),
              'pendingSync': 0,
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
    } catch (e) {
      print("Error syncing user data: $e");
    }
  }


// Sync Events
  Future<void> _syncEvents(String userId) async {
    try {
      //sync the change
      final pendingEvents = await getPendingEvents();
      for (var event in pendingEvents) {
        await _syncEventToFirestore(event);
      }

      // Sync pending deletions
      final pendingDeletions = await getDeleteSyncEvents();
      for (var eventData in pendingDeletions) {
        await deleteEvent(eventData['id'].toString(), userId, syncWithServer: true);
      }

      //for first time get and the adds
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      final eventIds = List<String>.from(userDoc.data()?['eventIds'] ?? []);

      for (String eventId in eventIds) {
        final eventDoc = await FirebaseFirestore.instance.collection('event').doc(eventId).get();

        if (eventDoc.exists) {
          final eventData = Event.fromMap(eventDoc.data()!);

          await saveEvent(eventData, pendingSync: false);

          await _syncGiftsForEvent(eventId, eventData.giftIds);
        }
      }

    } catch (e) {
      print("Error syncing events: $e");
    }
  }

// Sync Gifts
  Future<void> _syncGifts(String userId, Database db) async {
    try {
      final pendingGifts = await db.query('gifts', where: 'pendingSync = ?', whereArgs: [1]);
      for (var giftData in pendingGifts) {
        final giftId = giftData['id'] as String;
        await FirebaseFirestore.instance.collection('gifts').doc(giftId).set(
          giftData,
          SetOptions(merge: true),
        );

        await updategiftPendingSync(giftId);
      }
    } catch (e) {
      print("Error syncing gifts: $e");
    }
  }

// Sync Gifts for Specific Event
  Future<void> _syncGiftsForEvent(String eventId, List<dynamic> giftIds) async {
    for (String giftId in giftIds) {
      final giftDoc = await FirebaseFirestore.instance.collection('gifts').doc(giftId).get();

      if (giftDoc.exists) {
        final giftData = giftDoc.data()!;
        await insertGift(giftData);
      }
    }
  }

// Sync Event to Firestore
  Future<void> _syncEventToFirestore(Event event) async {
    try {
      print("EVENT location ::"+event.location);
      final eventRef = FirebaseFirestore.instance.collection('event').doc(event.id);
      await eventRef.set(event.toMap(), SetOptions(merge: true));

      await FirebaseFirestore.instance.collection('users').doc(event.userId).update({
        'eventIds': FieldValue.arrayUnion([event.id]),
      });
      await updateEventPendingSync(event.id);
    } catch (e) {
      print("Error syncing event to Firestore: $e");
    }
  }

  Future<void> deleteEvent(String eventId, String userId, {bool syncWithServer = false}) async {
    final db = await database;

    if (syncWithServer) {
      try {
        await FirebaseFirestore.instance.collection('event').doc(eventId).delete();
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'eventIds': FieldValue.arrayRemove([eventId]),
        });
      } catch (e) {
        print("Error deleting event from Firestore: $e");
      }
    }

    await db.delete('event', where: 'id = ?', whereArgs: [eventId]);
  }







// Future<void> syncUnsyncedData() async {
  //   final db = await database;
  //   print("Database sync... ");
  //
  //   final pendingEvents = await getPendingEvents();
  //   print(pendingEvents.toString());
  //
  //   for (var event in pendingEvents) {
  //     try {
  //       final newEventRef = FirebaseFirestore.instance.collection('event').doc(event.id);
  //       await newEventRef.set(event.toMap());
  //
  //       await FirebaseFirestore.instance.collection('users').doc(event.userId).update({
  //         'eventIds': FieldValue.arrayUnion([event.id]),
  //       });
  //     } catch (e) {
  //       print("Error syncing event: $e");
  //     }
  //   }
  //
  //   // Sync Pending Events
  //   for (var event in pendingEvents) {
  //     try {
  //       // Sync event to Firebase
  //       final eventRef = FirebaseFirestore.instance.collection('event').doc(event.id);
  //       await eventRef.set(event.toMap(), SetOptions(merge: true));
  //
  //       // Update user's event list in Firebase
  //       await FirebaseFirestore.instance.collection('users').doc(event.userId).update({
  //         'eventIds': FieldValue.arrayUnion([event.id]),
  //       });
  //
  //       // Mark as synced locally
  //       //await db.delete('event', where: 'id = ?', whereArgs: [event.id]);
  //     } catch (e) {
  //       print("Error syncing event: $e");
  //     }
  //   }
  //
  //   // Sync pending deletions
  //   final pendingDeletions = await db.query('event', where: 'pendingSync = ?', whereArgs: [2]);
  //
  //   for (var eventData in pendingDeletions) {
  //     try {
  //       final eventId = eventData['id'] as String;
  //
  //       // Delete from Firebase
  //       await FirebaseFirestore.instance.collection('event').doc(eventId).delete();
  //
  //       await FirebaseFirestore.instance.collection('users').doc(eventData['userId'] as String?).update({
  //         'eventIds': FieldValue.arrayRemove([eventId]),
  //       });
  //
  //       // Remove from local database
  //       await db.delete('event', where: 'id = ?', whereArgs: [eventId]);
  //     } catch (e) {
  //       print("Error syncing event deletion: $e");
  //     }
  //   }
  //
  //   // Sync other pending events
  //   for (var event in pendingEvents) {
  //     try {
  //       // Save to Firebase
  //       final eventRef = FirebaseFirestore.instance.collection('event').doc(event.id);
  //       await eventRef.set(event.toMap(), SetOptions(merge: true));
  //
  //       await FirebaseFirestore.instance.collection('users').doc(event.userId).update({
  //         'eventIds': FieldValue.arrayUnion([event.id]),
  //       });
  //
  //       await db.delete('event', where: 'id = ?', whereArgs: [event.id]);
  //     } catch (e) {
  //       print("Error syncing event: $e");
  //     }
//     }
//   //
  //
  //   // Sync User Profile
  //   final unsyncedUsers = await db.query('user', where: 'pendingSync = ?', whereArgs: [1]);
  //   for (var user in unsyncedUsers) {
  //     try {
  //       final userId = user['uid'];
  //       final updatedData = {
  //         'username': user['username'],
  //         'phone': user['phone'],
  //       };
  //
  //       await FirebaseFirestore.instance.collection('users').doc(userId as String?).update(updatedData);
  //
  //       await db.update(
  //         'user',
  //         {...user, 'pendingSync': 0},
  //         where: 'uid = ?',
  //         whereArgs: [userId],
  //       );
  //     } catch (e) {
  //       print("Error syncing user profile: $e");
  //     }
  //   }
  //
  //   // Sync Gifts (example)
  //   // final unsyncedGifts = await db.query('gift', where: 'pendingSync = ?', whereArgs: [1]);
  //   // for (var gift in unsyncedGifts) {
  //   //   try {
  //   //     final giftData = Gift.fromMap(gift);
  //   //
  //   //     // Save gift to Firebase
  //   //     final newGiftRef = FirebaseFirestore.instance.collection('gift').doc(giftData.id);
  //   //     await newGiftRef.set(giftData.toMap());
  //   //
  //   //     // Mark gift as synced
  //   //     await db.delete('gift', where: 'id = ?', whereArgs: [giftData.id]);
  //   //   } catch (e) {
  //   //     print("Error syncing gift: $e");
  //   //   }
  //   // }
  // }


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