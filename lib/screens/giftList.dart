import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hedieaty/widgets/colors.dart';
import 'package:hedieaty/widgets/appBar.dart';
import 'package:hedieaty/screens/giftDetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty/services/connectivityController.dart';
import 'package:hedieaty/data/db.dart';
import 'package:uuid/uuid.dart';




class giftList extends StatefulWidget {
  final String userId;
  final String? eventId;
  final bool isLoggedin;


  const giftList({super.key, required this.userId, this.eventId, required this.isLoggedin});

  @override
  _giftListPageState createState() => _giftListPageState();
}

class _giftListPageState extends State<giftList> {
  late List<Map<String, dynamic>> gifts = [];
  String sortOption = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserAndGifts();
  }

  Future<void> _fetchUserAndGifts() async {
    try {
      bool online = await connectivityController.isOnline();
      final db = await LocalDatabase().database;

      if (online) {
        // Online: Fetch data from Firestore
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();

        if (userDoc.exists) {
          print(userDoc.data().toString());
          List<String> eventIds = List<String>.from(userDoc.data()?['eventIds'] ?? []);
          List<Map<String, dynamic>> allGifts = [];

          for (String eventId in eventIds) {
            final eventDoc = await FirebaseFirestore.instance.collection('event').doc(eventId).get();

            if (eventDoc.exists) {

              final giftIds = List<dynamic>.from(eventDoc.data()?['giftIds'] ?? []);

              for (dynamic giftId in giftIds) {
                  if (giftId!=[]) {
                    final giftDoc = await FirebaseFirestore.instance.collection(
                        'gifts').doc(giftId).get();
                    if (giftDoc.exists) {
                      final giftData = giftDoc.data()!;
                      allGifts.add({
                        ...giftData,
                        'id': giftId,
                        'eventId': eventId,
                        'eventname': eventDoc.data()?['name'],
                      });
                    }
                }
              }
            }


          }

          setState(() {
            gifts = allGifts;
            isLoading = false;
          });
        } else {
          print("User not found");
          isLoading = false;
        }
      } else {

        final userLocal = await db.query('user', where: 'uid = ?', whereArgs: [widget.userId]);

        if (userLocal.isNotEmpty) {
          List<dynamic> eventIds = jsonDecode(userLocal.first['eventIds'].toString());
          List<Map<String, dynamic>> allGifts = [];

          for (String eventId in eventIds) {
            final eventLocal = await db.query('event', where: 'id = ?', whereArgs: [eventId]);
            if (eventLocal.isNotEmpty) {
              final eventName = eventLocal.first['name'];
              final giftIds = jsonDecode(eventLocal.first['giftIds'].toString());
              for (String giftId in giftIds) {
                final giftLocal = await db.query('gifts', where: 'id = ?', whereArgs: [giftId]);
                if (giftLocal.isNotEmpty) {
                  allGifts.add({
                    ...giftLocal.first,
                    'eventId': eventId,
                    'eventname': eventName,
                  });
                }
              }
            }
          }

          setState(() {
            gifts = allGifts;
            isLoading = false;
          });
        } else {
          print("User not found in local database");
          isLoading = false;
        }
      }
    } catch (e) {
      print("Error fetching user and gifts: $e");
      isLoading = false;
    }
  }



  void sortGifts(String option) {
    setState(() {
      sortOption = option;
      if (option == 'name') {
        gifts.sort((a, b) => a['name'].compareTo(b['name']));
      } else if (option == 'category') {
        gifts.sort((a, b) => a['category'].compareTo(b['category']));
      } else if (option == 'status') {
        gifts.sort((a, b) => a['status'].compareTo(b['status']));
      }
    });
  }


  Future<void> addGift(String name, String category, String description, double price, String? imagePath, String eventId) async {
    try {
      bool online = await connectivityController.isOnline();
      final db = await LocalDatabase().database;

      String giftId;
      String eventName = '';
      String imageUrl = "";

      if (online) {

        final newGiftRef = FirebaseFirestore.instance.collection('gifts').doc();
        giftId = newGiftRef.id;


        final eventDoc = await FirebaseFirestore.instance.collection('event').doc(eventId).get();
        if (eventDoc.exists) {
          eventName = eventDoc.data()?['name'] ?? 'Unknown Event';
        }

        await newGiftRef.set({
          'name': name,
          'category': category,
          'description': description,
          'price': price,
          'status': 'Available',
          'image': imagePath,
          'eventId': eventId,
        });


        await FirebaseFirestore.instance.collection('event').doc(eventId).update({
          'giftIds': FieldValue.arrayUnion([giftId]),
        });


        await db.insert('gifts', {
          'id': giftId,
          'name': name,
          'category': category,
          'description': description,
          'price': price,
          'status': 'Available',
          'image': imagePath,
          'eventId': eventId,
          'pendingSync': 0,
        });
      } else {
        // Offline: Save gift locally
        giftId = const Uuid().v4();

        final eventDoc = await db.query('event', where: 'id = ?', whereArgs: [eventId]);
        if (eventDoc.isNotEmpty) {
          eventName = eventDoc.first['name'].toString() ?? 'Unknown Event';

          List<String> giftIds = jsonDecode(eventDoc.first['giftIds'].toString() ?? '[]');
          giftIds.add(giftId);

          await db.update(
            'event',
            {'giftIds': jsonEncode(giftIds), 'pendingSync': 1},
            where: 'id = ?',
            whereArgs: [eventId],
          );
        }

        // Save gift locally
        await db.insert('gifts', {
          'id': giftId,
          'name': name,
          'category': category,
          'description': description,
          'price': price,
          'status': 'Available',
          'image': imagePath,
          'eventId': eventId,
          'pendingSync': 1,
        });
      }


      setState(() {
        gifts.add({
          'id': giftId,
          'name': name,
          'category': category,
          'description': description,
          'price': price,
          'status': 'Available',
          'image': imagePath,
          'eventId': eventId,
          'eventname': eventName,
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gift added ${online ? 'successfully' : 'locally. Will sync when online.'}")),
      );
    } catch (e) {
      print("Error adding gift: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding gift: $e")),
      );
    }
  }



  Future<void> editGift(String giftId, String name, String category, String description, double price, String? imagePath, String newEventId) async {
    try {
      bool online = await connectivityController.isOnline();
      final db = await LocalDatabase().database;

      if (online) {
        final giftDoc = await FirebaseFirestore.instance.collection('gifts').doc(giftId).get();
        if (!giftDoc.exists) throw "Gift not found";

        final giftData = giftDoc.data()!;
        final oldEventId = giftData['eventId'];

        await FirebaseFirestore.instance.collection('gifts').doc(giftId).update({
          'name': name,
          'category': category,
          'description': description,
          'price': price,
          'image': imagePath,
          'eventId': newEventId,
        });

        if (oldEventId != newEventId) {
          await FirebaseFirestore.instance.collection('event').doc(oldEventId).update({
            'giftIds': FieldValue.arrayRemove([giftId]),
          });

          await FirebaseFirestore.instance.collection('event').doc(newEventId).update({
            'giftIds': FieldValue.arrayUnion([giftId]),
          });
        }

        await db.update(
          'gifts',
          {
            'name': name,
            'category': category,
            'description': description,
            'price': price,
            'image': imagePath,
            'eventId': newEventId,
            'pendingSync': 0,
          },
          where: 'id = ?',
          whereArgs: [giftId],
        );
      } else {
        final localGift = await db.query('gifts', where: 'id = ?', whereArgs: [giftId]);
        if (localGift.isEmpty) throw "Gift not found locally";

        final giftData = localGift.first;
        final oldEventId = giftData['eventId'];

        await db.update(
          'gifts',
          {
            'name': name,
            'category': category,
            'description': description,
            'price': price,
            'image': imagePath,
            'eventId': newEventId,
            'pendingSync': 1,
          },
          where: 'id = ?',
          whereArgs: [giftId],
        );

        if (oldEventId != newEventId) {

          final oldEvent = await db.query('event', where: 'id = ?', whereArgs: [oldEventId]);
          if (oldEvent.isNotEmpty) {
            List<String> giftIds = jsonDecode(oldEvent.first['giftIds'].toString());
            giftIds.remove(giftId);

            await db.update(
              'event',
              {'giftIds': jsonEncode(giftIds), 'pendingSync': 1},
              where: 'id = ?',
              whereArgs: [oldEventId],
            );
          }

          final newEvent = await db.query('event', where: 'id = ?', whereArgs: [newEventId]);
          if (newEvent.isNotEmpty) {
            List<String> giftIds = jsonDecode(newEvent.first['giftIds'].toString());
            giftIds.add(giftId);

            await db.update(
              'event',
              {'giftIds': jsonEncode(giftIds), 'pendingSync': 1},
              where: 'id = ?',
              whereArgs: [newEventId],
            );
          }
        }
      }

      // Update the UI
      setState(() {
        int index = gifts.indexWhere((gift) => gift['id'] == giftId);
        if (index != -1) {
          gifts[index] = {
            'id': giftId,
            'name': name,
            'category': category,
            'description': description,
            'price': price,
            'status': gifts[index]['status'],
            'image': imagePath,
            'eventId': newEventId,
            'eventname': gifts[index]['eventname'],
          };
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gift updated ${online ? 'successfully' : 'locally. Will sync when online.'}")),
      );
    } catch (e) {
      print("Error updating gift: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating gift: $e")),
      );
    }
  }

  Future<void> deleteGift(String giftId, String? eventId) async {
    try {
      bool online = await connectivityController.isOnline();
      final db = await LocalDatabase().database;

      if (online) {
        // Online deletion
        await FirebaseFirestore.instance.collection('gifts').doc(giftId).delete();

        await FirebaseFirestore.instance.collection('event').doc(eventId).update({
          'giftIds': FieldValue.arrayRemove([giftId]),
        });

        // Remove from local DB
        await db.delete('gifts', where: 'id = ?', whereArgs: [giftId]);
      } else {
        // Mark the gift for deletion (pendingSync = 2)
        await db.update(
          'gifts',
          {'pendingSync': 2},
          where: 'id = ?',
          whereArgs: [giftId],
        );

        // Update the local event's gift list
        final eventDoc = await db.query('event', where: 'id = ?', whereArgs: [eventId]);
        if (eventDoc.isNotEmpty) {
          // Parse the giftIds as an array
          List<dynamic> giftIds = jsonDecode(eventDoc.first['giftIds'].toString());
          giftIds.remove(giftId);

          // Update the event table locally
          await db.update(
            'event',
            {'giftIds': jsonEncode(giftIds), 'pendingSync': 1}, // Store as JSON string locally
            where: 'id = ?',
            whereArgs: [eventId],
          );
        }
      }

      // Update UI
      setState(() {
        gifts.removeWhere((gift) => gift['id'] == giftId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gift deleted ${online ? 'successfully' : 'locally. Will sync when online.'}")),
      );
    } catch (e) {
      print("Error deleting gift: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting gift: $e")),
      );
    }
  }



  void navigateToGiftDetails(Map<String, dynamic>? gift, String? eventId) async {
    if (gift != null && gift['status'] == 'Pledged') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot edit a pledged gift.")),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GiftDetailsPage(
          gift: gift,
          eventId: eventId,
          userId: widget.userId,
        ),
      ),
    );

    if (result != null) {
      if (gift != null) {

        await editGift(
          gift['id'],
          result['name'],
          result['category'],
          result['description'],
          double.parse(result['price']),
          result['image'],
          result['eventId'],

        );
      } else {
        await addGift(
          result['name'],
          result['category'],
          result['description'],
          double.parse(result['price']),
          result['image'],
          result['eventId'],
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: "Gift List",
        isDarkMode: isDarkMode,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: myAppColors.darkBlack),
            onSelected: sortGifts,
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'name',
                  child: Text('Sort by Name'),
                ),
                const PopupMenuItem<String>(
                  value: 'category',
                  child: Text('Sort by Category'),
                ),
                const PopupMenuItem<String>(
                  value: 'status',
                  child: Text('Sort by Status'),
                ),
              ];
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()):
      Column(
        children: [
          Expanded(
            child: gifts.isEmpty
                ? const Center(child: Text("You have no gifts"))
                : ListView.builder(
              itemCount: gifts.length,
              itemBuilder: (context, index) {
                var gift = gifts[index];
                bool isPledged = gift['status'] == 'Pledged';

                return Card(
                  color: isPledged
                      ? myAppColors.wrongColor.withOpacity(0.4)
                      : (isDarkMode ? Colors.black : myAppColors.lightWhite),
                  margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                  elevation: 15.0,
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: gift['image'] != null && gift['image'].isNotEmpty
                          ? Image.network(
                        gift['image'],
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(
                            'assets/default_image.png',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          );
                        },
                      )
                          : Image.asset(
                        'asset/img.png',
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      gift['name']??"No Name",
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? myAppColors.lightWhite : myAppColors.darkBlack,
                      ),
                    ),
                    subtitle: Text(
                      gift['eventname'] ?? "No assigned event",
                      style: TextStyle(
                        color: isDarkMode
                            ? myAppColors.lightWhite.withOpacity(0.7)
                            : myAppColors.darkBlack.withOpacity(0.7),
                      ),
                    ),
                    trailing: isPledged
                        ? const SizedBox()
                        : IconButton(
                      icon: const Icon(Icons.delete, color: myAppColors.primColor),
                      onPressed: () {
                        deleteGift(gift['id'],gift['eventId']);
                      },
                    ),
                    onTap: isPledged
                        ? null
                        : () {
                       navigateToGiftDetails(gift, gift['eventId']);
                    },
                    onLongPress: (){
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(gift['name']),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: <Widget>[
                                  ListTile(
                                    leading: Icon(Icons.category),
                                    title: Text('Category'),
                                    subtitle: Text(gift['category']?? "No available category"),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.info),
                                    title: Text('Price'),
                                    subtitle: Text(
                                      gift['price']?.toString() ?? "No available price",
                                    ),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.description),
                                    title: Text('Description'),
                                    subtitle: Text(gift['description']?? "No available description"),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.location_on),
                                    title: Text('Event'),
                                    subtitle: Text(gift['eventname']?? "No avaulable location "),
                                  ),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: Text('Close'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: widget.isLoggedin
          ? FloatingActionButton(
        onPressed: () {
          navigateToGiftDetails(null, widget.eventId);
        },
        backgroundColor: myAppColors.secondaryColor.withOpacity(0.7),
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}
