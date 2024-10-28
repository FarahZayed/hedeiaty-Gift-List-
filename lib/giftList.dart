import 'package:flutter/material.dart';
import 'package:hedieaty/colors.dart';
import 'package:hedieaty/appBar.dart';
import 'package:hedieaty/giftDetails.dart';
import 'package:hedieaty/db.dart';

class giftList extends StatefulWidget {
  final int friendId;
  final int? eventId;

  const giftList({super.key, required this.friendId, this.eventId});

  @override
  _giftListPageState createState() => _giftListPageState();
}

class _giftListPageState extends State<giftList> {
  late List<Map<String, dynamic>> gifts;
  late bool isLoggedin;
  Map<String, dynamic>? event;
  String sortOption = '';

  @override
  void initState() {
    super.initState();
    if (widget.eventId != null) {
      gifts = MockDatabase.getGiftsForFriendEvent(widget.friendId, widget.eventId!);
      event = MockDatabase.getEventById(widget.eventId!); // Fetch the event by ID
    } else {
      gifts = MockDatabase.getGiftsForFriend(widget.friendId);
    }
    var friend = MockDatabase.friends.firstWhere((friend) => friend['id'] == widget.friendId);
    isLoggedin = friend['isLoggedin'];
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

  void addGift(String name, String category, String description, double price, String status, String? imagePath, String event) {
    setState(() {
      gifts.add({
        'name': name,
        'category': category,
        'description': description,
        'price': price,
        'status': status,
        'image': imagePath,
        'event': event
      });
    });
  }

  void editGift(int index, String newName, String newCategory, String newDescription, double newPrice, String newStatus, String? newImagePath, String event) {
    setState(() {
      gifts[index] = {
        'name': newName,
        'category': newCategory,
        'description': newDescription,
        'price': newPrice,
        'status': newStatus,
        'image': newImagePath,
        'event': event
      };
    });
  }

  void deleteGift(int index) {
    setState(() {
      gifts.removeAt(index);
    });
  }

  void navigateToGiftDetails({Map<String, dynamic>? gift,Map<String, dynamic>? event}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GiftDetailsPage(gift: gift,event:event),
      ),
    );

    if (result != null) {
      if (gift != null) {
        int index = gifts.indexOf(gift);
        editGift(index, result['name'], result['category'], result['description'], result['price'], result['status'], result['image'], result['event']);
      } else {
        addGift(result['name'], result['category'], result['description'], result['price'], result['status'], result['image'], result['event']);
      }
    }
  }

  void togglePledgeStatus(int index) {
    setState(() {
      gifts[index]['status'] = gifts[index]['status'] == 'Available' ? 'Pledged' : 'Available';
      //then save in DB
    });
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
      body: Column(
        children: [
          // Display the Event Name at the top of the page if available
          if (event != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                event!['name'],
                style: TextStyle(
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? myAppColors.lightWhite : myAppColors.darkBlack,
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              itemCount: gifts.length,
              itemBuilder: (context, index) {
                var gift = gifts[index];
                var evntCurrentId = gift['eventId'];
                bool isPledged = gift['status'] == 'Pledged';
                Map<String, dynamic>? evnt = MockDatabase.getEventById(evntCurrentId);
                return Card(
                  color: isPledged ? myAppColors.wrongColor.withOpacity(0.4) : (isDarkMode ? Colors.black : myAppColors.lightWhite),
                  margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                  elevation: 15.0,
                  child: ListTile(
                    title: Text(gift['name'], style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? myAppColors.lightWhite : myAppColors.darkBlack,
                    ),
                    ),
                    subtitle: Text(evnt?['name']?? "No assigned event ", style: TextStyle(
                      color: isDarkMode ? myAppColors.lightWhite.withOpacity(0.7) : myAppColors.darkBlack.withOpacity(0.7),
                    ),
                    ),
                    trailing: isLoggedin
                        ? IconButton(
                         icon: const Icon(Icons.delete, color: myAppColors.primColor),
                         onPressed: () {
                          deleteGift(index);
                        },
                    )
                        : ElevatedButton(
                          onPressed: () => togglePledgeStatus(index),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isPledged ? Colors.grey : myAppColors.primColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                          child: Text(
                            isPledged ? 'Pledged' : 'Pledge',
                            style: TextStyle(color: isDarkMode ? myAppColors.lightWhite : myAppColors.darkBlack),
                          ),
                    ),
                    onTap: () {
                      if (!isPledged) {
                        navigateToGiftDetails(gift: gift, event: evnt);
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Visibility(
        visible: isLoggedin,
        child: FloatingActionButton(
          onPressed: () {
            navigateToGiftDetails();
          },
          backgroundColor: myAppColors.secondaryColor.withOpacity(0.7),
          child: const Icon(Icons.add),
        ),
      ),

    );
  }
}
