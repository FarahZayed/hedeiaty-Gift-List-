import 'dart:convert';

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
    final eventMap = {
      ...event.toMap(),
      'pendingSync': pendingSync ? 1 : 0,
    };

    await db.insert('event', eventMap, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Event>> getPendingEvents() async {
    final db = await database;
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
      // Sync Gifts
      await _syncGifts(userId);

      // Sync User Data
      await _syncUserData(userId);

      // Sync Events
      await _syncEvents(userId);

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

        final userLocal = UserlocalDB.fromMap(localUser.first);
        if (userLocal.pendingSync == 1) {
          print("Syncing user changes to Firestore for user: $userId");

          await FirebaseFirestore.instance.collection('users').doc(userId).set({
            ...userLocal.toMap(),
            'friendIds': userLocal.friendIds,
            'eventIds': userLocal.eventIds,
          });

          // Mark as synced locally
          await db.update(
            'user',
            {'pendingSync': 0},
            where: 'uid = ?',
            whereArgs: [userId],
          );
        }
        else {
          print("Fetching latest user data from Firestore for user: $userId");

          final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

          if (userDoc.exists) {
            final userData = userDoc.data()!;

            final updatedUser = UserlocalDB(
              uid: userData['uid'] ?? '',
              username: userData['username'] ?? '',
              email: userData['email'] ?? '',
              phone: userData['phone'] ?? '',
              friendIds: List<String>.from(userData['friendIds'] ?? []),
              eventIds: List<String>.from(userData['eventIds'] ?? []),
              photoURL: userData['photoURL'] ?? '',
              pendingSync: 0,
            );


            await db.insert(
              'user',
              updatedUser.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }

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
  Future<void> _syncGifts(String userId) async {
    try {
      final db = await database;

      // Sync gifts marked for addition or update (pendingSync = 1)
      final pendingGifts = await db.query('gifts', where: 'pendingSync = ?', whereArgs: [1]);
      for (var giftData in pendingGifts) {
        final giftId = giftData['id'] as String;

        // Sync to Firestore
        await FirebaseFirestore.instance.collection('gifts').doc(giftId).set(
          {
            'name': giftData['name'],
            'category': giftData['category'],
            'description': giftData['description'],
            'price': giftData['price'],
            'status': giftData['status'],
            'image': giftData['image'],
            'eventId': giftData['eventId'],
          },
          SetOptions(merge: true),
        );

        // Mark as synced locally
        await db.update('gifts', {'pendingSync': 0}, where: 'id = ?', whereArgs: [giftId]);

        // Update event's giftIds in Firestore
        await FirebaseFirestore.instance.collection('event').doc(giftData['eventId'].toString()).update({
          'giftIds': FieldValue.arrayUnion([giftId]),
        });

        // Update local event to ensure giftIds remain an array
        final eventDoc = await db.query('event', where: 'id = ?', whereArgs: [giftData['eventId']]);
        if (eventDoc.isNotEmpty) {
          List<dynamic> giftIds = jsonDecode(eventDoc.first['giftIds'].toString());
          if (!giftIds.contains(giftId)) giftIds.add(giftId);

          await db.update(
            'event',
            {'giftIds': jsonEncode(giftIds), 'pendingSync': 0}, // Keep as JSON locally
            where: 'id = ?',
            whereArgs: [giftData['eventId']],
          );
        }
      }

      // Sync gifts marked for deletion (pendingSync = 2)
      final pendingDeletions = await db.query('gifts', where: 'pendingSync = ?', whereArgs: [2]);
      for (var giftData in pendingDeletions) {
        final giftId = giftData['id'] as String;

        // Remove from Firestore
        await FirebaseFirestore.instance.collection('gifts').doc(giftId).delete();

        // Update event's giftIds in Firestore
        await FirebaseFirestore.instance.collection('event').doc(giftData['eventId'].toString()).update({
          'giftIds': FieldValue.arrayRemove([giftId]),
        });

        // Update local event to remove giftId
        final eventDoc = await db.query('event', where: 'id = ?', whereArgs: [giftData['eventId']]);
        if (eventDoc.isNotEmpty) {
          List<dynamic> giftIds = jsonDecode(eventDoc.first['giftIds'].toString());
          giftIds.remove(giftId);

          await db.update(
            'event',
            {'giftIds': jsonEncode(giftIds), 'pendingSync': 0}, // Keep as JSON locally
            where: 'id = ?',
            whereArgs: [giftData['eventId']],
          );
        }

        // Remove from local database
        await db.delete('gifts', where: 'id = ?', whereArgs: [giftId]);
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
        giftData['id'] = giftId;
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


}


