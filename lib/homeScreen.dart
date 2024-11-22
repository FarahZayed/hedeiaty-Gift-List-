import 'package:flutter/material.dart';
import 'package:hedieaty/colors.dart';
import 'package:hedieaty/appBar.dart';
import 'package:hedieaty/db.dart';
import 'package:hedieaty/models/userModel.dart';

//import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<ThemeMode> onThemeToggle;

  const HomeScreen({super.key, required this.onThemeToggle});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isDarkMode = false;
  bool showSearchField = false;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameOfFriend = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
 // List<Contact> contacts = [];

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    //_requestPermission();
  }

  // Future<void> _requestPermission() async {
  //   if (await Permission.contacts.request().isGranted) {
  //     _fetchContacts();
  //   }
  // }

  // Future<void> _fetchContacts() async {
  //   Iterable<Contact> contactsFromDevice = await ContactsService.getContacts();
  //   setState(() {
  //     contacts = contactsFromDevice.toList();
  //   });
  // }

  void _addFriendManually() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Friend Manually"),
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameOfFriend,
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                      labelText: "Enter name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: "Enter phone number",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                String phoneNumber = _phoneController.text.trim();
                String name = _nameOfFriend.text.trim();
                if (phoneNumber.isNotEmpty && name.isNotEmpty) {
                  Map<String, dynamic> newFriend = {
                    'id': MockDatabase.friends.length + 1,
                    'name': name,
                    'profileImage': 'asset/profile.png',
                    'phoneNumber': phoneNumber,
                    'events': [],
                  };

                  setState(() {
                    MockDatabase.friends.add(newFriend);
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Friend was added successfully")),
                  );
                  _phoneController.clear();
                  _nameOfFriend.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter a name and phone number")),
                  );
                }
              },
              child: const Text("Add Friend"),
            ),
          ],
        );
      },
    );
  }

  // void _showContacts() {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text("Select Contact"),
  //         content: SizedBox(
  //           width: double.maxFinite,
  //           child: ListView.builder(
  //             itemCount: contacts.length,
  //             itemBuilder: (context, index) {
  //               Contact contact = contacts[index];
  //               return ListTile(
  //                 title: Text(contact.displayName ?? "No Name"),
  //                 subtitle: Text(contact.phones!.isNotEmpty
  //                     ? contact.phones!.first.value ?? ""
  //                     : "No phone number"),
  //                 onTap: () {
  //                   Navigator.pop(context);
  //                   if (contact.phones != null && contact.phones!.isNotEmpty) {
  //                     String phoneNumber = contact.phones!.first.value ?? "";
  //                     print(
  //                         "Friend added from contact: ${contact.displayName} with phone number: $phoneNumber");
  //                   } else {
  //                     ScaffoldMessenger.of(context).showSnackBar(
  //                       const SnackBar(content: Text("Selected contact has no phone number")),
  //                     );
  //                   }
  //                 },
  //               );
  //             },
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  void _showAddOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.contact_phone, color: myAppColors.primColor),
                title: const Text("Add from Contacts"),
                onTap: () {
                  Navigator.pop(context);
                  //_showContacts();
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_add, color: myAppColors.primColor),
                title: const Text("Add Manually"),
                onTap: () {
                  Navigator.pop(context);
                  _addFriendManually();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final User user = ModalRoute.of(context)!.settings.arguments as User;
    isDarkMode = Theme.of(context).brightness == Brightness.dark;
   // Map<String, dynamic> user = MockDatabase.friends[3];

    return Scaffold(
      key: _scaffoldKey,
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
              const SizedBox(height: 50.0),
              DrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [myAppColors.primColor, myAppColors.secondaryColor],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 35.0,
                      backgroundImage: AssetImage('asset/profile.png'),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      "${user.name}",
                      style: TextStyle(
                        color: isDarkMode ? myAppColors.lightWhite : myAppColors.darkBlack,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${user.email}",
                      style: TextStyle(
                        color: isDarkMode ? myAppColors.lightWhite : myAppColors.darkBlack,
                        fontSize: 14.0,
                      ),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.person, color: myAppColors.primColor),
                title: const Text('Profile'),
                onTap: () => Navigator.pushNamed(context, "/profile", arguments: user),
              ),
              ListTile(
                leading: const Icon(Icons.card_giftcard, color: myAppColors.primColor),
                title: const Text('My Gift List'),
                onTap: () => Navigator.pushNamed(context, "/giftList", arguments: {
                  'friendId': user.id,
                  'eventId': null,
                }),
              ),
              ListTile(
                leading: const Icon(Icons.event, color: myAppColors.primColor),
                title: const Text('My Events'),
                onTap: () => Navigator.pushNamed(context, "/eventList", arguments: {
                  'friendId': user.id
                }),
              ),
              ListTile(
                leading: const Icon(Icons.card_giftcard_outlined, color: myAppColors.primColor),
                title: const Text("My Pledged Gifts"),
                onTap: () => Navigator.pushNamed(context, "/pledgedGifts"),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: myAppColors.secondaryColor),
                labelText: 'Search Friends',
                filled: true,
                fillColor: isDarkMode ? Colors.black12 : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: MockDatabase.friends.length - 1,
              itemBuilder: (context, index) {
                var friend = MockDatabase.friends[index];
                bool hasUpcomingEvents = friend['events'].length > 0;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  elevation: 10.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(friend['profileImage']),
                    ),
                    title: Text(
                      friend['name'],
                      style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                    ),
                    trailing: hasUpcomingEvents
                        ? CircleAvatar(
                      radius: 12,
                      backgroundColor: myAppColors.primColor,
                      child: Text(
                        '${friend['events'].length}',
                        style: const TextStyle(color: Colors.white, fontSize: 12.0),
                      ),
                    )
                        : null,
                    onTap: () {
                      Navigator.pushNamed(context, "/eventList", arguments: {'friendId': friend['id']});
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddOptions,
        backgroundColor: myAppColors.secondaryColor.withOpacity(0.8),
        child: Icon(Icons.add, color: isDarkMode ? myAppColors.lightWhite : myAppColors.darkBlack),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 8.0,
        color: myAppColors.primColor,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.menu, color: myAppColors.lightWhite),
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            TextButton(
              onPressed: () async {
                await Navigator.pushNamed(context, "/mangeEventsPage");
              },
              child: Text(
                "Create Event",
                style: TextStyle(color: myAppColors.lightWhite, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
