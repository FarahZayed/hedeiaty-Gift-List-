import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty/widgets/colors.dart';
import 'package:hedieaty/widgets/appBar.dart';
import 'package:hedieaty/services/connectivityController.dart';



class friendGiftPage extends StatefulWidget {
  final String friendId;
  final String eventId;
  final String currentUserId;

  const friendGiftPage({
    super.key,
    required this.friendId,
    required this.eventId,
    required this.currentUserId,
  });
  @override
  _friendGiftPageState createState() => _friendGiftPageState();
}

class _friendGiftPageState extends State<friendGiftPage> {
  List<Map<String, dynamic>> friendGifts = [];

  @override
  void initState() {
    super.initState();
    _fetchUnpledgedGifts();
  }

  Future<void> _fetchUnpledgedGifts() async {
    try {
      final giftsSnapshot = await FirebaseFirestore.instance
          .collection('gifts')
          .where('eventId', isEqualTo: widget.eventId)
          .where('status', isEqualTo: 'Available')
          .get();

      setState(() {
        friendGifts = giftsSnapshot.docs.map((doc) {
          return {
            ...doc.data(),
            'id': doc.id,
          };
        }).toList();
      });
    } catch (e) {
      print("Error fetching unpledged gifts: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching gifts: $e")),
      );
    }
  }

  Future<void> _pledgeGift(int index) async {
    try {
      bool isOnline = await connectivityController.isOnline();
      // Get the gift details
      var gift = friendGifts[index];
      if(isOnline) {
        // Update the gift's status in Firestore
        await FirebaseFirestore.instance.collection('gifts')
            .doc(gift['id'])
            .update({
          'status': 'Pledged',
        });

        // Add a new document in the 'pledges' collection
        final userDoc = await FirebaseFirestore.instance.collection('users')
            .doc(widget.currentUserId)
            .get();
        final friendDoc = await FirebaseFirestore.instance.collection('users')
            .doc(widget.friendId)
            .get();

        if (userDoc.exists && friendDoc.exists) {
          final currentUser = userDoc.data()!;
          final friend = friendDoc.data()!;

          await FirebaseFirestore.instance.collection('pledges').add({
            'giftName': gift['name'],
            'pledgedByUserId': widget.currentUserId,
            'pledgedByUserName': currentUser['username'],
            'pledgedToUserId': widget.friendId,
            'pledgedToUserName': friend['username'],
            'timestamp': FieldValue.serverTimestamp(),
          });


          // Update UI
          setState(() {
            friendGifts.removeAt(index);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Gift pledged successfully.")),
          );
        } else {
          throw "User or friend details not found.";
        }
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("You can't pledge gift while you are offline")),
        );
      }
    } catch (e) {
      print("Error pledging gift: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error pledging gift: $e")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: "Gift List",
        isDarkMode: isDarkMode,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: friendGifts.isEmpty
            ? Center(
          child: Text(
            "No available gifts to pledge.",
            style: TextStyle(
              fontSize: 18.0,
              color: isDarkMode ? myAppColors.lightWhite : myAppColors.darkBlack,
            ),
          ),
        )
            : ListView.builder(
          itemCount: friendGifts.length,
          itemBuilder: (context, index) {
            var gift = friendGifts[index];

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 5.0,
              color: isDarkMode ? Colors.black : myAppColors.lightWhite,
              child: ListTile(
                leading: gift['image'] != null && gift['image'].isNotEmpty
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(25.0),
                  child: Image.network(
                    gift['image'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {

                      return CircleAvatar(
                        backgroundColor: myAppColors.secondaryColor,
                        child: Icon(
                          Icons.card_giftcard,
                          color: isDarkMode ? myAppColors.lightWhite : myAppColors.darkBlack,
                        ),
                      );
                    },
                  ),
                )
                    : CircleAvatar(
                  backgroundColor: myAppColors.secondaryColor,
                  child: Icon(
                    Icons.card_giftcard,
                    color: isDarkMode ? myAppColors.lightWhite : myAppColors.darkBlack,
                  ),
                ),
                title: Text(
                  gift['name'] ?? 'Unnamed Gift',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? myAppColors.lightWhite : myAppColors.darkBlack,
                  ),
                ),
                subtitle: Text(
                  "Category: ${gift['category'] ?? 'Unknown'}",
                  style: TextStyle(
                    color: isDarkMode
                        ? myAppColors.lightWhite.withOpacity(0.7)
                        : myAppColors.darkBlack.withOpacity(0.7),
                  ),
                ),
                trailing: ElevatedButton(
                  onPressed: () => _pledgeGift(index),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: myAppColors.primColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    'Pledge',
                    style: TextStyle(
                      color: isDarkMode ? myAppColors.lightWhite : myAppColors.darkBlack,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
