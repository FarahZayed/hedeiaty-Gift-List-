import 'package:flutter/material.dart';
import 'package:hedieaty/widgets/colors.dart';
import 'package:hedieaty/widgets/appBar.dart';
import 'package:hedieaty/data/db.dart';
import 'package:hedieaty/models/eventModel.dart';
import 'package:hedieaty/screens/manageEvents.dart';
import 'package:hedieaty/services/connectivityController.dart';
import 'package:uuid/uuid.dart';
//firebase
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


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

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    //_requestPermission();
  }

  void _addFriendManually(String currentUserId, List<dynamic> friendsIds) {
    showDialog(
      context: context, // Parent context is passed here
      builder: (dialogContext) {
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
                Navigator.pop(dialogContext);

                String phoneNumber = _phoneController.text.trim();
                String name = _nameOfFriend.text.trim();
                final  isOnline = await connectivityController.isOnline();
                if (phoneNumber.isNotEmpty && name.isNotEmpty) {
                  try {
                    if(isOnline) {
                      QuerySnapshot userSnapshot = await FirebaseFirestore
                          .instance
                          .collection('users')
                          .where('phone', isEqualTo: phoneNumber)
                          .get();

                      if (userSnapshot.docs.isNotEmpty) {
                        var friendDoc = userSnapshot.docs.first;
                        var friendData = friendDoc.data() as Map<String,
                            dynamic>;

                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(currentUserId)
                            .update({
                          'friendIds': FieldValue.arrayUnion([friendDoc.id]),
                        });

                        setState(() {
                          friendsIds.add(friendDoc.id);
                        });

                        // Show success Snackbar using the parent context
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(
                              "${friendData['username']} was added successfully!")),
                        );
                      } else {
                        // Show error Snackbar using the parent context
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text(
                              "User not found with this phone number.")),
                        );
                      }
                    }
                    else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("You can't add friend while you are offline")),
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

  Future<void> addEvent(String userId,String name, String category, String status, DateTime date, String location ,String description) async {
    try {
      final Uuid uuid = Uuid();
      bool online = await connectivityController.isOnline();
      final newEvent = Event(
        id: uuid.v4(),
        name: name,
        date: date.toIso8601String(),
        location: location,
        description: description,
        userId: userId,
        giftIds: [],
        category: category,
        status: status,
      );
      if (online) {
        final newEventRef = FirebaseFirestore.instance.collection('event').doc(newEvent.id);
        await newEventRef.set(newEvent.toMap());

        await FirebaseFirestore.instance.collection('users').doc(userId).update(
            {
              'eventIds': FieldValue.arrayUnion([newEventRef.id])
            });


        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Event added successfully.")),
        );
      }else{

        await LocalDatabase().saveEvent(newEvent,pendingSync :true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Event saved locally. Will sync when online.")),
        );
      }
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
                    "currentUserId": ""

                  },
                ),
              ),
              ListTile(
                leading: const Icon(Icons.card_giftcard_outlined, color: myAppColors.primColor),
                title: const Text("My Pledged Gifts"),
                onTap: () => Navigator.pushNamed(context, "/pledgedGifts",arguments: user['uid']),
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
                        onTap: () async{
                          final  isOnline = await connectivityController.isOnline();
                          if(isOnline) {
                            print ("USER ID "+ user['uid']);
                            Navigator.pushNamed(context, "/eventList",
                                arguments: {
                                  'userId': friendData['uid'],
                                  'isLoggedIn': false,
                                  'currentUserId':user['uid']
                                });
                          }
                          else{
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("You can't fetch your friends content while you are offline")),
                            );
                          }
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
