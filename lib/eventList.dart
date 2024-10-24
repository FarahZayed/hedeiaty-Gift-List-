import 'package:flutter/material.dart';
import 'package:hedieaty/colors.dart';
import 'package:hedieaty/appBar.dart';

class eventList extends StatelessWidget {
  const eventList({super.key});

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
              itemCount: 5,  // Replace with actual event list count
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    title: Text('Event Name $index'),
                    subtitle: const Text('Event Date: 2024-12-01', style: TextStyle(color: myAppColors.correctColor)),
                    onTap: () {
                      // Navigate to gift list for this event
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add a new event
        },
        backgroundColor: myAppColors.primColor, // Primary color for the button
        child: const Icon(
          Icons.add, // Add icon to represent adding an event
         // color: myAppColors.secondaryColor, // Icon color from your palette
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
