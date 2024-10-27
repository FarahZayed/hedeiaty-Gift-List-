import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:hedieaty/colors.dart';
import 'package:hedieaty/appBar.dart';
import 'package:hedieaty/manageEvents.dart';

class eventList extends StatefulWidget {

  const eventList({super.key});

  @override
  State<eventList> createState() => _eventListState();
}

class _eventListState extends State<eventList> {
  List<Map<String, dynamic>> events = [
    {
      'name': 'Tech Conference',
      'date': DateTime(2024, 5, 15),
      'category': 'Technology',
      'status': 'Upcoming',
    },
    {
      'name': 'Music Festival',
      'date': DateTime(2023, 12, 28),
      'category': 'Entertainment',
      'status': 'Upcoming',
    },
    {
      'name': 'Art Exhibition',
      'date': DateTime(2024, 2, 10),
      'category': 'Art',
      'status': 'Upcoming',
    },
    {
      'name': 'Food Festival',
      'date': DateTime(2023, 11, 5),
      'category': 'Food',
      'status': 'Upcoming',
    },
    {
      'name': 'Sports Tournament',
      'date': DateTime(2024, 3, 22),
      'category': 'Sports',
      'status': 'Upcoming',
    },
    {
      'name': 'Book Fair',
      'date': DateTime.now(), // Current date
      'category': 'Literature',
      'status': 'Current',
    },
    {
      'name': 'Holiday Celebration',
      'date': DateTime.now().add(Duration(days: 2)),
      'category': 'Festive',
      'status': 'Current',
    },
    {
      'name': 'Product Launch',
      'date': DateTime(2023, 10, 20),
      'category': 'Business',
      'status': 'Past',
    },
    {
      'name': 'Workshop',
      'date': DateTime(2023, 9, 12),
      'category': 'Education',
      'status': 'Past',
    },
    {
      'name': 'Concert',
      'date': DateTime(2023, 8, 5),
      'category': 'Entertainment',
      'status': 'Past',
    },
  ];

  String sortOption = '';

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

  void addEvent(String name, String category, String status,DateTime date) {
    setState(() {
      events.add({
        'name': name,
        'category': category,
        'status': status,
        'date':date
      });
    });
  }

  void editEvent(int index, String newName, String newCategory,  String newStatus, DateTime newDate ) {
    setState(() {
      events[index] = {
        'name': newName,
        'category': newCategory,
        'status': newStatus,
        'date':newDate
      };
    });
  }

  void deleteEvent(int index) {
    setState(() {
      events.removeAt(index);
    });
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
        builder: (context) => mangeEventsPage(event: event),
      ),
    );

    if (result != null) {
      if (event != null) {

        int index = events.indexOf(event);
        editEvent(index, result['name'], result['category'], result['status'],result['date']);
      } else {

        addEvent(result['name'], result['category'], result['status'], result['date']);
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
            child: ListView.builder(
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
                    subtitle: Text(DateFormat('yyyy-MM-dd').format(event['date']), style: TextStyle(color: myAppColors.correctColor)),
                    onTap: () {
                      goToEditEvents(event: event);
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: myAppColors.primColor),
                      onPressed: () => deleteEvent(index),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          goToEditEvents();
        },
        backgroundColor: myAppColors.secondaryColor.withOpacity(0.7),
        child: const Icon(
          Icons.add,

        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
