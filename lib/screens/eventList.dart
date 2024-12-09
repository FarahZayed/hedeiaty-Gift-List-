import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:hedieaty/widgets/colors.dart';
import 'package:hedieaty/widgets/appBar.dart';
import 'package:hedieaty/screens/manageEvents.dart';
import 'package:hedieaty/models/eventModel.dart';
import 'package:hedieaty/services/connectivityController.dart';
import 'package:hedieaty/data/db.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class eventList extends StatefulWidget {
  final String userId;
  final bool isLoggedIn;
  const eventList({super.key, required this.userId, required this.isLoggedIn});

  @override
  State<eventList> createState() => _eventListState();
}


class _eventListState extends State<eventList> {
  late List<String> eventsId;
  late List<Map<String, dynamic>> originalEvents = [];
  bool isLoading=true;


  @override
  void initState() {
    super.initState();
    _fetchUserAndEvents();
  }

  Future<void> _fetchUserAndEvents() async {
    try {
      bool online = await connectivityController.isOnline();
      print("online"+online.toString());

      if (online) {
        // Fetch from Firestore
        final userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();

        if (userDoc.exists) {
          eventsId = List<String>.from(userDoc.data()?['eventIds'] ?? []);

          originalEvents = [];
          for (String eventId in eventsId) {
            final eventDoc = await FirebaseFirestore.instance.collection('event').doc(eventId).get();
            if (eventDoc.exists) {
              final eventData = eventDoc.data()!;
              originalEvents.add({
                ...eventData,
                'id': eventId,
              });
            }
          }

          setState(() {
            isLoading = false;
          });
        } else {
          print("User not found");
          setState(() {
            isLoading = false;
          });
        }
      } else {
        // Fetch from SQLite
        print("FETCHING LOCALLY");
        final db = await LocalDatabase().database;
        final userEvents = await db.query('event', where: 'userId = ?', whereArgs: [widget.userId]);

        originalEvents = userEvents.map((event) {
          return {
            'id': event['id'],
            'name': event['name'],
            'category': event['category'],
            'status': event['status'],
            'description': event['description'],
            'location': event['location'],
            'date': event['date'],
            'userId': event['userId'],
          };
        }).toList();

        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching user and events: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  //sort events
  void sortEvents(String option) async{
    String sortOption = '';
    await _fetchUserAndEvents();
    setState(() {
      sortOption = option;

      if (option == 'name') {
        originalEvents.sort((a, b) => a['name'].toLowerCase().compareTo(b['name'].toLowerCase()));
      } else if (option == 'category') {
        originalEvents.sort((a, b) => a['category'].toLowerCase().compareTo(b['category'].toLowerCase()));
      } else if (option == 'all') {
        _fetchUserAndEvents();
      } else if (option == 'current') {
        originalEvents = originalEvents.where((event) {
          DateTime eventDate = DateTime.parse(event['date']);
          DateTime today = DateTime.now();
          return eventDate.year == today.year && eventDate.month == today.month && eventDate.day == today.day;
        }).toList();
      } else if (option == 'past') {
        originalEvents = originalEvents.where((event) {
          DateTime eventDate = DateTime.parse(event['date']);
          DateTime today = DateTime.now();
          return DateTime(eventDate.year, eventDate.month, eventDate.day).isBefore(DateTime(today.year, today.month, today.day));
        }).toList();
        originalEvents.sort((a, b) => DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])));
      } else if (option == 'upcoming') {
        originalEvents = originalEvents.where((event) {
          DateTime eventDate = DateTime.parse(event['date']);
          DateTime today = DateTime.now();
          return DateTime(eventDate.year, eventDate.month, eventDate.day).isAfter(DateTime(today.year, today.month, today.day));
        }).toList();
        originalEvents.sort((a, b) => DateTime.parse(a['date']).compareTo(DateTime.parse(b['date'])));
      }
    });
  }


  //add event
  Future<void> addEvent(String name, String category, String status, DateTime date, String location, String description) async {
    try {
      final Uuid uuid = Uuid();
      bool online = await connectivityController.isOnline();
      final newEvent = Event(
        id: uuid.v4(),
        name: name,
        date: date.toIso8601String(),
        location: location,
        description: description,
        userId: widget.userId,
        giftIds: [],
        category: category,
        status: status,
      );
      print('online::' + online.toString());

      String eventId;

      if (online) {
        final newEventRef = FirebaseFirestore.instance.collection('event').doc();
        await newEventRef.set({
          'name': name,
          'category': category,
          'status': status,
          'description': description ?? "",
          'location': location ?? "",
          'date': date.toIso8601String(),
          'userId': widget.userId,
        });

        await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
          'eventIds': FieldValue.arrayUnion([newEventRef.id])
        });

        eventId = newEventRef.id;
      } else {
        await LocalDatabase().saveEvent(newEvent, pendingSync: true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Event saved locally. Will sync when online.")),
        );

        eventId = newEvent.id;
      }

      setState(() {
        originalEvents.add({
          'id': eventId,
          'name': name,
          'category': category,
          'location': location,
          'description': description,
          'status': status,
          'date': date.toIso8601String(),
          'userId': widget.userId,
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event added successfully.")),
      );
    } catch (e) {
      print("Error adding event: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding event: $e")),
      );
    }
  }

  // edit event
  Future<void> editEvent(String eventId, String name, String category, String status, DateTime date, String location, String description) async {
    try {
      // Check for connectivity
      bool online = await connectivityController.isOnline();

      if (online) {
        // Update directly in Firebase
        await FirebaseFirestore.instance.collection('event').doc(eventId).update({
          'name': name,
          'category': category,
          'location': location,
          'description': description,
          'status': status,
          'date': date.toIso8601String(),
        });

        setState(() {
          int index = originalEvents.indexWhere((event) => event['id'] == eventId);
          if (index != -1) {
            originalEvents[index] = {
              'id': eventId, // Ensure the ID stays intact
              'name': name,
              'category': category,
              'location': location,
              'description': description,
              'status': status,
              'date': date.toIso8601String(),
            };
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Event updated successfully.")),
        );
      } else {
        // Save changes locally for later sync
        final db = await LocalDatabase().database;

        final existingEvent = await db.query(
          'event',
          where: 'id = ?',
          whereArgs: [eventId],
        );

        if (existingEvent.isNotEmpty) {
          print ("EXISTS");
          // Update the local event
          await db.update(
            'event',
            {
              'name': name,
              'category': category,
              'location': location,
              'description': description,
              'status': status,
              'date': date.toIso8601String(),
              'userId': widget.userId,
              'pendingSync': 1,
          },
            where: 'id = ?',
            whereArgs: [eventId],
          );
        } else {
          await db.insert(
            'event',
            {
              'id': eventId,
              'name': name,
              'category': category,
              'location': location,
              'description': description,
              'status': status,
              'date': date.toIso8601String(),
              'userId': widget.userId,
              'giftIds': null,
              'pendingSync': 1,
            },
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Event changes saved locally. Will sync when online.")),
        );
      }
    } catch (e) {
      print("Error updating event: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating event: $e")),
      );
    }
  }

  // delete event
  Future<void> deleteEvent(String eventId) async {
    try {
      // Check if the device is online
      bool online = await connectivityController.isOnline();
      print("ONLINE ::"+online.toString());

      if (online) {
        await FirebaseFirestore.instance.collection('event').doc(eventId).delete();

        await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
          'eventIds': FieldValue.arrayRemove([eventId]),
        });

        setState(() {
          originalEvents.removeWhere((event) => event['id'] == eventId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Event deleted successfully.")),
        );
      } else {
        // Save the deletion locally
        final db = await LocalDatabase().database;

        await db.insert(
          'event',
          {
            'id': eventId,
            'pendingSync': 2,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        setState(() {
          originalEvents.removeWhere((event) => event['id'] == eventId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Event marked for deletion locally. Will sync when online.")),
        );
      }
    } catch (e) {
      print("Error deleting event: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting event: $e")),
      );
    }
  }




  // void showEditDialog(int index) {
  //   TextEditingController nameController = TextEditingController(text: events[index]['name']);
  //   TextEditingController categoryController = TextEditingController(text: events[index]['category']);
  //   TextEditingController statusController = TextEditingController(text: events[index]['status']);
  //
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Edit Event'),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             TextField(
  //               controller: nameController,
  //               decoration: InputDecoration(labelText: 'Name'),
  //             ),
  //             TextField(
  //               controller: categoryController,
  //               decoration: InputDecoration(labelText: 'Category'),
  //             ),
  //             TextField(
  //               controller: statusController,
  //               decoration: InputDecoration(labelText: 'Status'),
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: Text('Cancel'),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               editEvent(index, nameController.text, categoryController.text, statusController.text,date);
  //               Navigator.of(context).pop();
  //             },
  //             child: Text('Save'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  //direct to mange event page
  void goToEditEvents({Map<String, dynamic>? event}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManageEventsPage(event: event),
      ),
    );

    if (result != null) {
      if (event != null) {

        await editEvent(
          event['id'],
          result['name'],
          result['category'],
          result['status'],
          DateTime.parse(result['date']),
          result['location'],
          result['description'],
        );
      } else {

        await addEvent(
          result['name'],
          result['category'],
          result['status'],
          DateTime.parse(result['date']),
          result['location'],
          result['description'],
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: CustomAppBar(
        title: "Events",
        isDarkMode: isDarkMode,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: myAppColors.darkBlack),
            onSelected: (String value) {
              sortEvents(value);
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem<String>(
                  value: 'all',
                  child: Text('Get all the events'),
                ),
                const PopupMenuItem<String>(
                  value: 'name',
                  child: Text('Sort by Name'),
                ),
                const PopupMenuItem<String>(
                  value: 'category',
                  child: Text('Sort by Category'),
                ),
                const PopupMenuItem<String>(
                  value: 'current',
                  child: Text('Current Events'),
                ),
                const PopupMenuItem<String>(
                  value: 'past',
                  child: Text('Past Events'),
                ),
                const PopupMenuItem<String>(
                  value: 'upcoming',
                  child: Text('Upcoming Events'),
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
          const Padding(padding: EdgeInsets.only(top: 10.0)),
          Expanded(
            child: originalEvents.isEmpty?
                Container(
                  child: Center(child: Text("You have no events")),
                ):
            ListView.builder(
              itemCount: originalEvents.length,
              itemBuilder: (context, index) {
                var event = originalEvents[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    title: Text(event['name']),
                    subtitle: Text(
                      DateFormat('yyyy-MM-dd').format(DateTime.parse(event['date'])),
                      style: TextStyle(color: myAppColors.correctColor),
                    ),
                    onTap: widget.isLoggedIn ? () {
                      goToEditEvents(event: event);
                    } : null,
                    onLongPress: (){
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(event['name']),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: <Widget>[
                                  ListTile(
                                    leading: Icon(Icons.category),
                                    title: Text('Category'),
                                    subtitle: Text(event['category']?? "No available category"),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.info),
                                    title: Text('Status'),
                                    subtitle: Text(event['status']?? "No available status"),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.description),
                                    title: Text('Description'),
                                    subtitle: Text(event['description']?? "No available description"),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.location_on),
                                    title: Text('Location'),
                                    subtitle: Text(event['location']?? "No avaulable location "),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.date_range),
                                    title: Text('Date'),
                                    subtitle: Text(DateFormat('yyyy-MM-dd').format(DateTime.parse(event['date']))),
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
                    trailing:  widget.isLoggedIn ? IconButton(
                      icon: const Icon(Icons.delete, color: myAppColors.primColor),
                      onPressed: () {
                        deleteEvent(event['id'].toString());},)
                    : IconButton(
                      icon: const Icon(Icons.arrow_forward_ios_rounded, color: myAppColors.primColor,),
                      onPressed: () {
                        print('user id '+ widget.userId);
                        print("event id "+event['id']);
                        Navigator.pushNamed(
                          context,
                          '/friendGiftPage',
                          arguments: {
                            'friendId': widget.userId,
                            'eventId': event['id'],
                            //'isLoggedin':false,
                          },
                        );

                      },
                    ),
                  ),
                  );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Visibility(
        visible: widget.isLoggedIn ,
        child: FloatingActionButton(
          onPressed: () {
            goToEditEvents();
          },
          backgroundColor: myAppColors.secondaryColor.withOpacity(0.7),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
