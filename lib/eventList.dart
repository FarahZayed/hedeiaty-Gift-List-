import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:hedieaty/colors.dart';
import 'package:hedieaty/appBar.dart';
import 'package:hedieaty/manageEvents.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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


  @override
  void initState() {
    super.initState();
    _fetchUserAndEvents();
  }

  Future<void> _fetchUserAndEvents() async {
    try {
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


        setState(() {});
      } else {
        print("User not found");
      }
    } catch (e) {
      print("Error fetching user and events: $e");
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
  Future<void> addEvent(String name, String category, String status, DateTime date, String location ,String description) async {
    try {
      final newEventRef = FirebaseFirestore.instance.collection('event').doc();
      await newEventRef.set({
        'name': name,
        'category': category,
        'status': status,
        'description': description??"",
        'location': location??"",
        'date': date.toIso8601String(),
        'userId': widget.userId,
      });

      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'eventIds': FieldValue.arrayUnion([newEventRef.id])
      });


      setState(() {
        originalEvents.add({
          'id': newEventRef.id,
          'name': name,
          'category': category,
          'location':location,
          'description':description,
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
  Future<void> editEvent(String eventId, String name, String category, String status, DateTime date, String location ,String description) async {
    try {
      await FirebaseFirestore.instance.collection('event').doc(eventId).update({
        'name': name,
        'category': category,
        'location':location,
        'description':description,
        'status': status,
        'date': date.toIso8601String(),
      });

      setState(() {
        int index = originalEvents.indexWhere((event) => event['id'] == eventId);
        if (index != -1) {
          originalEvents[index] = {
            'name': name,
            'category': category,
            'location':location,
            'description':description,
            'status': status,
            'date': date.toIso8601String(),
          };
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event updated successfully.")),
      );
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

      await FirebaseFirestore.instance.collection('event').doc(eventId).delete();

      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'eventIds': FieldValue.arrayRemove([eventId])
      });


      setState(() {
        originalEvents.removeWhere((event) => event['id'] == eventId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Event deleted successfully.")),
      );
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
      body: Column(
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
                                    subtitle: Text(event['category']?? null),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.info),
                                    title: Text('Status'),
                                    subtitle: Text(event['status']?? null),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.description),
                                    title: Text('Description'),
                                    subtitle: Text(event['description']?? null),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.location_on),
                                    title: Text('Location'),
                                    subtitle: Text(event['location']?? null),
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
                        // Navigator.pushNamed(
                        //   context,
                        //   '/giftList',
                        //   arguments: {
                        //     'friendId': widget.friendId,
                        //     'eventId': event['id'],
                        //   },
                        // );

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
