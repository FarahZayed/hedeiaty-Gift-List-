import 'package:flutter/material.dart';
import 'package:hedieaty/widgets/colors.dart';
import 'package:hedieaty/widgets/appBar.dart';
import 'package:hedieaty/screens/giftDetails.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class giftList extends StatefulWidget {
  final String userId;
  final String? eventId;
  final bool isLoggedin;


  const giftList({super.key, required this.userId, this.eventId, required this.isLoggedin});

  @override
  _giftListPageState createState() => _giftListPageState();
}

class _giftListPageState extends State<giftList> {
  late List<Map<String, dynamic>> gifts = [];
  String sortOption = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserAndGifts();
  }

  Future<void> _fetchUserAndGifts() async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();

      if (userDoc.exists) {
        List<String> eventIds = List<String>.from(userDoc.data()?['eventIds'] ?? []);


        List<Map<String, dynamic>> allGifts = [];

        for (String eventId in eventIds) {
          final eventDoc = await FirebaseFirestore.instance.collection('event').doc(eventId).get();
          if (eventDoc.exists) {
            List<String> giftIds = List<String>.from(eventDoc.data()?['giftIds'] ?? []);

            for (String giftId in giftIds) {
              final giftDoc = await FirebaseFirestore.instance.collection('gifts').doc(giftId).get();
              if (giftDoc.exists) {
                final giftData = giftDoc.data()!;
                allGifts.add({
                  ...giftData,
                  'id': giftId,
                  'eventId': eventId,
                  'eventname': eventDoc.data()?['name'],
                });
              }
            }
          }
        }

        setState(() {
          gifts = allGifts;
          isLoading=false;
        });

      } else {
        print("User not found");
        isLoading=false;
      }
    } catch (e) {
      print("Error fetching user and gifts: $e");
      isLoading=false;
    }
  }

  void sortGifts(String option) {
    setState(() {
      sortOption = option;
      if (option == 'name') {
        gifts.sort((a, b) => a['name'].compareTo(b['name']));
      } else if (option == 'category') {
        gifts.sort((a, b) => a['category'].compareTo(b['category']));
      } else if (option == 'status') {
        gifts.sort((a, b) => a['status'].compareTo(b['status']));
      }
    });
  }

  Future<void> addGift(String name, String category, String description, double price, String? imagePath, String eventId) async {
    try {
      final newGiftRef = FirebaseFirestore.instance.collection('gifts').doc();
      await newGiftRef.set({
        'name': name,
        'category': category,
        'description': description,
        'price': price,
        'status': 'Available', // Default status
        'image': imagePath,
        'eventId': eventId,
      });

      await FirebaseFirestore.instance.collection('event').doc(eventId).update({
        'giftIds': FieldValue.arrayUnion([newGiftRef.id]),
      });
      final eventDoc = await FirebaseFirestore.instance.collection('event').doc(eventId).get();

      setState(() {
        gifts.add({
          'id': newGiftRef.id,
          'name': name,
          'category': category,
          'description': description,
          'price': price,
          'status': 'Available',
          'image': imagePath,
          'eventId': eventId,
          'eventname':eventDoc.data()?['name']
        });
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gift added successfully.")),
      );
    } catch (e) {
      print("Error adding gift: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error adding gift: $e")),
      );
    }
  }

  Future<void> editGift(String giftId, String name, String category, String description, double price, String? imagePath, String newEventId) async {
    try {
      // Fetch the current gift data
      final giftDoc = await FirebaseFirestore.instance.collection('gifts').doc(giftId).get();
      if (!giftDoc.exists) throw "Gift not found";

      final giftData = giftDoc.data()!;
      final oldEventId = giftData['eventId'];


      await FirebaseFirestore.instance.collection('gifts').doc(giftId).update({
        'name': name,
        'category': category,
        'description': description,
        'price': price,
        'image': imagePath,
        'eventId': newEventId, // Assign to the new event
      });


      if (oldEventId != newEventId) {
        await FirebaseFirestore.instance.collection('event').doc(oldEventId).update({
          'giftIds': FieldValue.arrayRemove([giftId]),
        });

        // Step 3: Update the new event's `giftIds` list
        await FirebaseFirestore.instance.collection('event').doc(newEventId).update({
          'giftIds': FieldValue.arrayUnion([giftId]),
        });
      }


      final newEventDoc = await FirebaseFirestore.instance.collection('event').doc(newEventId).get();
      final newEventName = newEventDoc.data()?['name'] ?? "Unknown Event";

      setState(() {
        int index = gifts.indexWhere((gift) => gift['id'] == giftId);
        if (index != -1) {
          gifts[index] = {
            'id': giftId,
            'name': name,
            'category': category,
            'description': description,
            'price': price,
            'status': gifts[index]['status'], // Preserve status
            'image': imagePath,
            'eventId': newEventId,
            'eventname': newEventName,
          };
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gift updated successfully.")),
      );
    } catch (e) {
      print("Error updating gift: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating gift: $e")),
      );
    }
  }


  Future<void> deleteGift(String giftId, String? eventId) async {
    try {
      await FirebaseFirestore.instance.collection('gifts').doc(giftId).delete();

      await FirebaseFirestore.instance.collection('event').doc(eventId).update({
        'giftIds': FieldValue.arrayRemove([giftId]),
      });

      setState(() {
        gifts.removeWhere((gift) => gift['id'] == giftId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gift deleted successfully.")),
      );
    } catch (e) {
      print("Error deleting gift: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting gift: $e")),
      );
    }
  }

  void navigateToGiftDetails(Map<String, dynamic>? gift, String? eventId) async {
    if (gift != null && gift['status'] == 'Pledged') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cannot edit a pledged gift.")),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GiftDetailsPage(
          gift: gift,
          eventId: eventId,
          userId: widget.userId,
        ),
      ),
    );

    if (result != null) {
      if (gift != null) {

        await editGift(
          gift['id'],
          result['name'],
          result['category'],
          result['description'],
          double.parse(result['price']),
          result['image'],
          result['eventId'],
        );
      } else {
        await addGift(
          result['name'],
          result['category'],
          result['description'],
          double.parse(result['price']),
          result['image'],
          result['eventId'],
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: "Gift List",
        isDarkMode: isDarkMode,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list, color: myAppColors.darkBlack),
            onSelected: sortGifts,
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
                  value: 'status',
                  child: Text('Sort by Status'),
                ),
              ];
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()):
      Column(
        children: [
          Expanded(
            child: gifts.isEmpty
                ? const Center(child: Text("You have no gifts"))
                : ListView.builder(
              itemCount: gifts.length,
              itemBuilder: (context, index) {
                var gift = gifts[index];
                bool isPledged = gift['status'] == 'Pledged';

                return Card(
                  color: isPledged
                      ? myAppColors.wrongColor.withOpacity(0.4)
                      : (isDarkMode ? Colors.black : myAppColors.lightWhite),
                  margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                  elevation: 15.0,
                  child: ListTile(
                    title: Text(
                      gift['name']??"No Name",
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? myAppColors.lightWhite : myAppColors.darkBlack,
                      ),
                    ),
                    subtitle: Text(
                      gift['eventname'] ?? "No assigned event",
                      style: TextStyle(
                        color: isDarkMode
                            ? myAppColors.lightWhite.withOpacity(0.7)
                            : myAppColors.darkBlack.withOpacity(0.7),
                      ),
                    ),
                    trailing: isPledged
                        ? const SizedBox()
                        : IconButton(
                      icon: const Icon(Icons.delete, color: myAppColors.primColor),
                      onPressed: () {
                        deleteGift(gift['id'],gift['eventId']);
                      },
                    ),
                    onTap: isPledged
                        ? null
                        : () {
                       navigateToGiftDetails(gift, gift['eventId']);
                    },
                    onLongPress: (){
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(gift['name']),
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: <Widget>[
                                  ListTile(
                                    leading: Icon(Icons.category),
                                    title: Text('Category'),
                                    subtitle: Text(gift['category']?? "No available category"),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.info),
                                    title: Text('Price'),
                                    subtitle: Text(
                                      gift['price']?.toString() ?? "No available price",
                                    ),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.description),
                                    title: Text('Description'),
                                    subtitle: Text(gift['description']?? "No available description"),
                                  ),
                                  ListTile(
                                    leading: Icon(Icons.location_on),
                                    title: Text('Event'),
                                    subtitle: Text(gift['eventname']?? "No avaulable location "),
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
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: widget.isLoggedin
          ? FloatingActionButton(
        onPressed: () {
          navigateToGiftDetails(null, widget.eventId);
        },
        backgroundColor: myAppColors.secondaryColor.withOpacity(0.7),
        child: const Icon(Icons.add),
      )
          : null,
    );
  }
}
