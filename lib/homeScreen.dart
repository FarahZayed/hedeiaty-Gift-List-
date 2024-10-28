import 'package:flutter/material.dart';
import 'package:hedieaty/colors.dart';
import 'package:hedieaty/appBar.dart';
import 'package:hedieaty/db.dart';
// import 'package:contacts_service/contacts_service.dart';
// import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<ThemeMode> onThemeToggle;

  const HomeScreen({super.key, required this.onThemeToggle});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isDarkMode = false;
  bool showSearchField = false;
  final TextEditingController _phoneController = TextEditingController();
  //List<Contact> contacts = [];


  // @override
  // void initState() {
  //   super.initState();
  //   _requestPermission();
  // }

  // Future<void> _requestPermission() async {
  //   if (await Permission.contacts.request().isGranted) {
  //     _fetchContacts();
  //   }
  // }
  //
  // Future<void> _fetchContacts() async {
  //   Iterable<Contact> contactsFromDevice = await ContactsService.getContacts();
  //   setState(() {
  //     contacts = contactsFromDevice.toList();
  //   });
  // }

  // void _addFriendManually() {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: Text("Add Friend Manually"),
  //         content: TextField(
  //           controller: _phoneController,
  //           keyboardType: TextInputType.phone,
  //           decoration: InputDecoration(
  //             labelText: "Enter phone number",
  //             border: OutlineInputBorder(),
  //           ),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context); // Close dialog
  //               String phoneNumber = _phoneController.text.trim();
  //               if (phoneNumber.isNotEmpty) {
  //                 print("Friend added with phone number: $phoneNumber");
  //                 _phoneController.clear();
  //               } else {
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   SnackBar(content: Text("Please enter a phone number")),
  //                 );
  //               }
  //             },
  //             child: Text("Add Friend"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
  //
  // void _showContacts() {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: Text("Select Contact"),
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
  //                   Navigator.pop(context); // Close dialog
  //                   if (contact.phones != null && contact.phones!.isNotEmpty) {
  //                     String phoneNumber = contact.phones!.first.value ?? "";
  //                     print("Friend added from contact: ${contact.displayName} with phone number: $phoneNumber");
  //                   } else {
  //                     ScaffoldMessenger.of(context).showSnackBar(
  //                       SnackBar(content: Text("Selected contact has no phone number")),
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

  @override
  Widget build(BuildContext context) {
    isDarkMode = Theme.of(context).brightness == Brightness.dark;
    //for now fetch the only logged in user
    Map<String,dynamic> user= MockDatabase.friends[3];

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
              DrawerHeader(
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircleAvatar(
                      radius: 35.0,
                      backgroundImage: AssetImage('asset/profile.png'),
                    ),
                    const SizedBox(height: 10.0),
                    Text(
                      "${user['userName']}",
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
                leading: Icon(Icons.person, color: myAppColors.primColor),
                title: Text('Profile'),
                onTap: () {
                  Navigator.pushNamed(context, "/profile");
                },
              ),
              ListTile(
                leading: Icon(Icons.card_giftcard, color: myAppColors.primColor),
                title: Text('My Gift List'),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/giftList',
                    arguments: {
                      'friendId': user['id'],
                      'eventId': null,
                    },
                  );

                },
              ),
              ListTile(
                leading: Icon(Icons.event, color: myAppColors.primColor),
                title: Text('My Events'),
                onTap: () {
                  Navigator.pushNamed(context, "/eventList" , arguments: {
                    'friendId': user['id']
                  });
                },
              ),
              ListTile(
                leading: Icon(Icons.card_giftcard_outlined, color: myAppColors.primColor),
                title: Text("My pledged Gifts"),
                onTap: () => Navigator.pushNamed(context, "/pledgedGifts"),
              ),
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
                  onPressed: () async {
                    await Navigator.pushNamed(context, "/mangeEventsPage");
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
                  icon: const Icon(Icons.add),
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Search Friends',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: myAppColors.secondaryColor,
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: myAppColors.secondaryColor,
                      width: 2.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: myAppColors.secondaryColor,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),

          Expanded(
            child: ListView.builder(
              //for now make it -1
              itemCount: MockDatabase.friends.length-1,
              itemBuilder: (context, index) {
                var friend = MockDatabase.friends[index];
                bool hasUpcomingEvents = friend['events'].length > 0;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  elevation: 15.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(friend['profileImage']),
                    ),
                    title: Text(
                      friend['name'],
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    trailing: hasUpcomingEvents ? CircleAvatar(
                      radius: 12,
                      backgroundColor: myAppColors.primColor,
                      child: Text(
                        '${friend['events'].length}',
                        style: const TextStyle(color: Colors.white, fontSize: 12.0),
                      ),
                    )
                        : null,
                    onTap: () {
                      Navigator.pushNamed(context, "/eventList", arguments: friend['id']);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: myAppColors.secondaryColor.withOpacity(0.7),
        onPressed: () {
          showDialog(context: context,
            builder: (context) {
              return PopupMenuButton<String>(
                // icon: Icon(Icons.add, color: isDarkMode?myAppColors.darkBlack:myAppColors.lightWhite,),

                onSelected: (String item) {
                  // if (item == 'add_by_contact') {
                  //   _showContacts();
                  // } else if (item == 'add_contact_manually') {
                  //   _addFriendManually();
                  // }
                },
                itemBuilder: (BuildContext context) {
                  return [
                    const PopupMenuItem<String>(
                      value: 'add_by_contact',
                      child: Text('Select from your contacts'),
                    ),
                    const PopupMenuItem<String>(
                      value: 'add_contact_manually',
                      child: Text('Add Manually'),
                    ),
                  ];
                },
                color: isDarkMode ? myAppColors.darkBlack : myAppColors
                    .lightWhite,
              );
            },
          );
        },
        child:  const Icon(
          Icons.add,
        ),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}