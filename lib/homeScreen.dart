import 'package:flutter/material.dart';
import 'package:hedieaty/colors.dart';
import 'package:hedieaty/appBar.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<ThemeMode> onThemeToggle;

  HomeScreen({required this.onThemeToggle});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isDarkMode = false;
  bool showSearchField = false;

  @override
  Widget build(BuildContext context) {
    isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: "Hedieaty",
        isDarkMode: isDarkMode,
        onThemeToggle: () => widget.onThemeToggle(isDarkMode ? ThemeMode.light : ThemeMode.dark),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to create a new event or gift list
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: myAppColors.secondaryColor,
                    foregroundColor: isDarkMode ? myAppColors.darkBlack : myAppColors.lightWhite,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    elevation: 10.0,
                    shadowColor: myAppColors.secondaryColor.withOpacity(1.0),
                  ),
                  icon: Icon(Icons.add), // Icon indicating adding an event
                  label: Text(
                    'Add Event ',
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  onPressed: () {
                    setState(() {
                      showSearchField = !showSearchField;
                    });
                  },
                  icon: Icon(Icons.search),
                  color: isDarkMode ? myAppColors.lightWhite : myAppColors.darkBlack,
                ),
              ),
            ],
          ),
          if (showSearchField)
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Search Friends',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: myAppColors.secondaryColor, // Use the correct color
                      width: 2.0, // Set the border thickness
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: myAppColors.secondaryColor, // Use the correct color
                      width: 2.0, // Set the border thickness
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: myAppColors.secondaryColor, // Use the correct color
                      width: 1.5, // Set the border thickness
                    ),
                  ),
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: 10,  // Replace with actual friends list count
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage('asset/profile.png'),  // Example profile image
                    ),
                    title: Text(
                      'Friend Name $index',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'Upcoming Events: 1',
                      style: TextStyle(
                        color: myAppColors.correctColor,
                        fontSize: 16.0,
                      ),
                    ),
                    onTap: () {
                      // Navigate to the friend's gift list
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
        child: Icon(
          Icons.add, // Add icon to represent adding an event
          //color: myAppColors.secondaryColor, // Icon color from your palette
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
