import 'package:flutter/material.dart';
import 'package:hedieaty/colors.dart';
import 'package:hedieaty/appBar.dart';

class pledgedGiftsPage extends StatefulWidget {
  @override
  _pledgedGiftsPageState createState() => _pledgedGiftsPageState();
}

class _pledgedGiftsPageState extends State<pledgedGiftsPage> {
  List<Map<String, dynamic>> pledgedGifts = [
    {
      'giftName': 'Smartphone',
      'friendName': 'Alice',
      'dueDate': '2024-11-15',
      'status': 'pending'
    },
    {
      'giftName': 'Headphones',
      'friendName': 'Bob',
      'dueDate': '2024-10-30',
      'status': 'completed'
    },
    {
      'giftName': 'Book',
      'friendName': 'Charlie',
      'dueDate': '2024-12-05',
      'status': 'pending'
    },
  ];

  void modifyPledge(int index) {
    setState(() {
      pledgedGifts[index]['status'] = 'modified';
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(title: "My Pledged Gifts",isDarkMode: isDarkMode),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: pledgedGifts.length,
                itemBuilder: (context, index) {
                  var gift = pledgedGifts[index];
                  bool isPending = gift['status'] == 'pending';

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 15.0,
                    color: isPending ? (isDarkMode? Colors.black:myAppColors.lightWhite) : Colors.green[100],
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: myAppColors.secondaryColor,
                        child: Icon(
                          Icons.card_giftcard_outlined,
                          color: isDarkMode ? myAppColors.lightWhite : myAppColors.darkBlack,
                        ),
                      ),
                      title: Text(
                        gift['giftName'],
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? (isPending?myAppColors.lightWhite: myAppColors.darkBlack) : myAppColors.darkBlack,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Friend: ${gift['friendName']}",
                            style: TextStyle(
                              color:isDarkMode ? (isPending?myAppColors.lightWhite.withOpacity(0.7): myAppColors.darkBlack.withOpacity(0.7)) : myAppColors.darkBlack.withOpacity(0.7),
                            ),
                          ),
                          Text(
                            "Due Date: ${gift['dueDate']}",
                            style: TextStyle(
                              color: isDarkMode ? (isPending?myAppColors.lightWhite.withOpacity(0.7): myAppColors.darkBlack.withOpacity(0.7)) : myAppColors.darkBlack.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                      trailing: isPending ? IconButton(
                        onPressed: () {
                          modifyPledge(index);
                        },
                        icon: Icon(Icons.change_circle_outlined,
                          color: myAppColors.primColor,
                        ),
                      )
                          : Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 28.0,
                      ),
                      onTap: () {
                        // Handle tap on gift to show details or modify
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
