import 'package:flutter/material.dart';
import 'package:hedieaty/colors.dart';
import 'package:hedieaty/appBar.dart';
import 'package:hedieaty/db.dart';
import 'package:hedieaty/manageEvents.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


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

  void _addFriendManually(String currentUserId, List<dynamic> friendsIds) {
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
              onPressed: () async {
                Navigator.pop(context);

                String phoneNumber = _phoneController.text.trim();
                String name = _nameOfFriend.text.trim();

                if (phoneNumber.isNotEmpty && name.isNotEmpty) {
                  try {
                    QuerySnapshot userSnapshot = await FirebaseFirestore.instance
                        .collection('users')
                        .where('phone', isEqualTo: phoneNumber)
                        .get();

                    if (userSnapshot.docs.isNotEmpty) {
                      var friendDoc = userSnapshot.docs.first;
                      var friendData = friendDoc.data() as Map<String, dynamic>;

                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(currentUserId)
                          .update({
                        'friendIds': FieldValue.arrayUnion([friendDoc.id]),
                      });

                      setState(() {
                        friendsIds.add(friendDoc.id);
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("${friendData['username']} was added successfully!")),
                      );
                    } else {
                      // Friend not found
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("User not found with this phone number.")),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error adding friend: $e")),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please enter both name and phone number.")),
                  );
                }

                // Clear fields
                _phoneController.clear();
                _nameOfFriend.clear();
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

  // void _showAddOptions() {
  //   showModalBottomSheet(
  //     context: context,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
  //     ),
  //     builder: (context) {
  //       return Container(
  //         padding: const EdgeInsets.all(16.0),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             ListTile(
  //               leading: const Icon(Icons.contact_phone, color: myAppColors.primColor),
  //               title: const Text("Add from Contacts"),
  //               onTap: () {
  //                 Navigator.pop(context);
  //                 //_showContacts();
  //               },
  //             ),
  //             ListTile(
  //               leading: const Icon(Icons.person_add, color: myAppColors.primColor),
  //               title: const Text("Add Manually"),
  //               onTap: () {
  //                 Navigator.pop(context);
  //                 _addFriendManually();
  //               },
  //             ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  Future<void> addEvent(String userId,String name, String category, String status, DateTime date, String location ,String description) async {
    try {
      final newEventRef = FirebaseFirestore.instance.collection('event').doc();
      await newEventRef.set({
        'name': name,
        'category': category,
        'status': status,
        'description': description??"",
        'location': location??"",
        'date': date.toIso8601String(),
        'userId': userId,
      });

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'eventIds': FieldValue.arrayUnion([newEventRef.id])
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


  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> user = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    List <dynamic> friendsIds=user['friendIds'];
    isDarkMode = Theme.of(context).brightness == Brightness.dark;

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
                      "${user['username']}",
                      style: TextStyle(
                        color: isDarkMode ? myAppColors.lightWhite : myAppColors.darkBlack,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "${user['email']}",
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
                onTap: () => Navigator.pushNamed(context, "/giftList",arguments: {'userId': user['uid'],'eventId': null,'isLoggedin':true}),
              ),
              ListTile(
                leading: const Icon(Icons.event, color: myAppColors.primColor),
                title: const Text('My Events'),
                onTap: () => Navigator.pushNamed(
                  context,
                  "/eventList",
                  arguments: {
                    'userId': user['uid'],
                    'isLoggedIn': true,
                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.card_giftcard_outlined, color: myAppColors.primColor),
                title: const Text("My Pledged Gifts"),
                onTap: () => Navigator.pushNamed(context, "/pledgedGifts"),
              ),
              const Spacer(),
              Divider(
                color: isDarkMode ? Colors.white30 : Colors.black38,
                thickness: 1.0,
              ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  "Sign Out",
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () async {
                  // Sign-out logic
                  try {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushReplacementNamed(context, '/login');
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error signing out: $e")),
                    );
                  }
                },
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

          //Friends list
          Expanded(
            child: friendsIds.isEmpty
                ? Container(
               child: Center(child: Text("You have no friends"),),
            ):ListView.builder(
              itemCount: friendsIds.length,
              itemBuilder: (context, index) {
                return FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('users').doc(friendsIds[index]).get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }

                    if (!snapshot.hasData || !snapshot.data!.exists) {
                      return Center(child: Text('Friends not found'));
                    }

                    var friendData = snapshot.data!.data() as Map<String, dynamic>;
                    bool hasUpcomingEvents = friendData['eventIds'] != null && friendData['eventIds'].length > 0;

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      elevation: 10.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          //*********************SHOULD BE FRIENDS IMAGE
                          backgroundImage: AssetImage('asset/profile.png'),
                        ),
                        title: Text(
                          friendData['username'],
                          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                        ),
                        trailing: hasUpcomingEvents
                            ? CircleAvatar(
                          radius: 12,
                          backgroundColor: myAppColors.primColor,
                          child: Text(
                            '${friendData['eventIds'].length}',
                            style: const TextStyle(color: Colors.white, fontSize: 12.0),
                          ),
                        )
                            : null,
                        onTap: () {
                          Navigator.pushNamed(context, "/eventList", arguments: {'userId': friendData['uid'],  'isLoggedIn': false,});
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:()=> _addFriendManually(user['uid'], friendsIds),
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
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManageEventsPage(),
                  ),
                );

                if (result != null) {
                  // Extract event details from the result and save it
                  await addEvent(
                    user['uid'],
                    result['name'],
                    result['category'],
                    result['status'],
                    DateTime.parse(result['date']),
                    result['location'],
                    result['description'],
                  );
                }
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
