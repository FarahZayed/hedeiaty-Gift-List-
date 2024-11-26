import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:hedieaty/colors.dart';
import 'package:hedieaty/appBar.dart';
import 'package:hedieaty/manageEvents.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class eventList extends StatefulWidget {
  final String userId;

  const eventList({super.key, required this.userId });

  @override
  State<eventList> createState() => _eventListState();
}

class _eventListState extends State<eventList> {
  late List<String> eventsId;
  late List<Map<String, dynamic>> events= [];
  late bool isLoggedIn;
  String sortOption = '';

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
        isLoggedIn = true;

        events = [];
        for (String eventId in eventsId) {
          final eventDoc = await FirebaseFirestore.instance.collection('event').doc(eventId).get();
          if (eventDoc.exists) {
            final eventData = eventDoc.data()!;
            events.add({
              ...eventData,
              'id': eventId, // Explicitly add the document ID
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




  void sortEvents(String option) {
    setState(() {
      sortOption = option;
      if (option == 'name') {
        events.sort((a, b) => a['name'].compareTo(b['name']));
      } else if (option == 'category') {
        events.sort((a, b) => a['category'].compareTo(b['category']));
      } else if (option == 'status') {
        events.sort((a, b) => a['status'].compareTo(b['status']));
      }
    });
  }

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
      print("new ref id::"+newEventRef.id);
      // Add the new event locally
      setState(() {
        events.add({
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
        int index = events.indexWhere((event) => event['id'] == eventId);
        if (index != -1) {
          events[index] = {
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


  Future<void> deleteEvent(String eventId) async {
    try {
      print("strin id:: "+eventId);
      await FirebaseFirestore.instance.collection('event').doc(eventId).delete();

      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'eventIds': FieldValue.arrayRemove([eventId])
      });


      setState(() {
        events.removeWhere((event) => event['id'] == eventId);
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
              // Handle filter selection
            },
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
            child: events.isEmpty?
                Container(
                  child: Center(child: Text("You have no events")),
                ):
            ListView.builder(
              itemCount: events.length,
              itemBuilder: (context, index) {
                var event = events[index];
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
                    onTap: isLoggedIn ? () {
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
                    trailing:  isLoggedIn? IconButton(
                      icon: const Icon(Icons.delete, color: myAppColors.primColor),
                      onPressed: () {
                        print("Event to delete: $event");
                        print("imsides::"+event['id'].toString());
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
        visible: isLoggedIn,
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
