import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty/widgets/colors.dart';
import 'package:hedieaty/widgets/appBar.dart';

class pledgedGiftsPage extends StatefulWidget {
  final String userId;

  const pledgedGiftsPage({super.key, required this.userId});

  @override
  _pledgedGiftsPageState createState() => _pledgedGiftsPageState();
}

class _pledgedGiftsPageState extends State<pledgedGiftsPage> {
  List<Map<String, dynamic>> pledgedGifts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPledgedGifts();
  }

  Future<void> _fetchPledgedGifts() async {
    try {

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        List<String> eventIds = List<String>.from(userDoc.data()?['eventIds'] ?? []);

        List<Map<String, dynamic>> allPledgedGifts = [];

        for (String eventId in eventIds) {

          final eventDoc = await FirebaseFirestore.instance
              .collection('event')
              .doc(eventId)
              .get();

          if (eventDoc.exists) {
            List<String> giftIds = List<String>.from(eventDoc.data()?['giftIds'] ?? []);

            for (String giftId in giftIds) {

              final giftDoc = await FirebaseFirestore.instance
                  .collection('gifts')
                  .doc(giftId)
                  .get();

              if (giftDoc.exists) {
                final giftData = giftDoc.data()!;
                if (giftData['status'] == 'Pledged') {
                  allPledgedGifts.add({
                    'giftName': giftData['name'],
                    'eventName': eventDoc.data()?['name'] ?? "Unknown Friend",
                  });
                }
              }
            }
          }
        }

        setState(() {
          pledgedGifts = allPledgedGifts;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching pledged gifts: $e");
      setState(() {
        isLoading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(title: "My Pledged Gifts", isDarkMode: isDarkMode),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : pledgedGifts.isEmpty
          ? const Center(child: Text("No pledged gifts found."))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: pledgedGifts.length,
          itemBuilder: (context, index) {
            var gift = pledgedGifts[index];

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              elevation: 15.0,
              color:  isDarkMode ? Colors.black : myAppColors.lightWhite,

              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: myAppColors.secondaryColor,
                  child: Icon(
                    Icons.card_giftcard_outlined,
                    color: isDarkMode
                        ? myAppColors.lightWhite
                        : myAppColors.darkBlack,
                  ),
                ),
                title: Text(
                  gift['giftName'],
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode
                        ? myAppColors.lightWhite
                        : myAppColors.darkBlack,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Event: ${gift['eventName']}",
                      style: TextStyle(
                        color: isDarkMode
                            ? myAppColors.lightWhite.withOpacity(0.7)
                            : myAppColors.darkBlack.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
