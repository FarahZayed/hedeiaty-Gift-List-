import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty/widgets/colors.dart';
import 'package:hedieaty/widgets/appBar.dart';

class friendGiftPage extends StatefulWidget {
  final String friendId;
  final String eventId;

  const friendGiftPage({super.key, required this.friendId, required this.eventId});

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
      var gift = friendGifts[index];

      await FirebaseFirestore.instance.collection('gifts').doc(gift['id']).update({
        'status': 'Pledged',
      });

      setState(() {
        friendGifts.removeAt(index);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gift pledged successfully.")),
      );
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
                leading: CircleAvatar(
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
