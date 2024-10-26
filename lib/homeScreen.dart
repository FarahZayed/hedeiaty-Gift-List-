import 'package:flutter/material.dart';
import 'package:hedieaty/colors.dart';
import 'package:hedieaty/appBar.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<ThemeMode> onThemeToggle;

  const HomeScreen({super.key, required this.onThemeToggle});

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
      drawer: Drawer(
        child: Container(
          color: isDarkMode ? myAppColors.darkBlack : myAppColors.lightWhite,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 70.0),
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        myAppColors.primColor,
                        myAppColors.secondaryColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 35.0,
                          backgroundImage: AssetImage('asset/profile.png'), // Example profile image
                        ),
                        const SizedBox(height: 10.0),
                        Text(
                          //will fetch it later when he logs in
                          "User Name",
                          style: TextStyle(
                            color: isDarkMode ? myAppColors.lightWhite : myAppColors.darkBlack,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          //will fetch it later when he logs in
                          "user.email@example.com",
                          style: TextStyle(
                            color: isDarkMode ? myAppColors.lightWhite : myAppColors.darkBlack,
                            fontSize: 14.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.person, color: myAppColors.primColor),
                title: Text('Profile'),
                onTap: () {
                  Navigator.pushNamed(context, "/profile");
                },
              ),
              ListTile(
                leading: Icon(Icons.card_giftcard, color: myAppColors.primColor),
                title:  Text('MY gift List'),
                onTap: () {
                  Navigator.pushNamed(context, "/giftList");
                },
              ),
              ListTile(
                leading: Icon(Icons.event, color: myAppColors.primColor),
                title:  Text('My Events'),
                onTap: () {
                  Navigator.pushNamed(context, "/eventList");
                },
              ),
              ListTile(
                leading: Icon(Icons.card_giftcard_outlined, color: myAppColors.primColor,),
                title: Text("My pledged Gifts"),
                onTap: () => Navigator.pushNamed(context,"/pledgedGifts"),
              )
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton.icon(
                  onPressed: () async{
                    await Navigator.pushNamed(context, "/eventList");

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: myAppColors.secondaryColor,
                    foregroundColor: isDarkMode ? myAppColors.darkBlack : myAppColors.lightWhite,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    elevation: 10.0,
                    shadowColor: myAppColors.secondaryColor.withOpacity(1.0),
                  ),
                  icon: const Icon(Icons.add), // Icon indicating adding an event
                  label: const Text(
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
                  icon: const Icon(Icons.search),
                  color: isDarkMode ? myAppColors.lightWhite : myAppColors.darkBlack,
                ),
              ),
            ],
          ),
          if (showSearchField)
            const Padding(
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
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  elevation: 4.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundImage: AssetImage('asset/profile.png'),  // Example profile image
                    ),
                    title: Text(
                      'Friend Name $index',
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: const Text(
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
        backgroundColor: myAppColors.primColor,
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
