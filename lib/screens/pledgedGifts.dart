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

      final pledgesSnapshot = await FirebaseFirestore.instance
          .collection('pledges')
          .where('pledgedByUserId', isEqualTo: widget.userId)
          .get();


      final fetchedPledgedGifts = pledgesSnapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'giftName': data['giftName'] ?? 'Unnamed Gift',
          'pledgedToUserName': data['pledgedToUserName'] ?? 'Unknown User',
        };
      }).toList();


      setState(() {
        pledgedGifts = fetchedPledgedGifts;
        isLoading = false;
      });
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
              color: isDarkMode
                  ? Colors.black
                  : myAppColors.lightWhite,
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
                      "Pledged to: ${gift['pledgedToUserName']}",
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
