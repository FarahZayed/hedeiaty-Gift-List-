import 'package:flutter/material.dart';
import 'package:hedieaty/colors.dart';
import 'package:hedieaty/appBar.dart';

class friendGiftPage extends StatefulWidget {
  final String friendName; // Friend's name passed from the previous page
  const friendGiftPage({super.key, required this.friendName});

  @override
  _friendGiftPageState createState() => _friendGiftPageState();
}

class _friendGiftPageState extends State<friendGiftPage> {
  //will get it from DB
  final List<Map<String, dynamic>> friendGifts = [
    {'giftName': 'Smartphone', 'category': 'Electronics', 'status': 'Available'},
    {'giftName': 'Headphones', 'category': 'Electronics', 'status': 'Pledged'},
    {'giftName': 'Book', 'category': 'Books', 'status': 'Available'},
  ];


  void togglePledgeStatus(int index) {
    setState(() {
      friendGifts[index]['status'] = friendGifts[index]['status'] == 'Available'
          ? 'Pledged'
          : 'Available';
      //then save in DB
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(title: "${widget.friendName}'s Gift List", isDarkMode: isDarkMode),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: friendGifts.length,
                itemBuilder: (context, index) {
                  var gift = friendGifts[index];
                  bool isPledged = gift['status'] == 'Pledged';

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    elevation: 5.0,
                    color: isPledged ? myAppColors.wrongColor.withOpacity(0.4) : (isDarkMode?Colors.black: myAppColors.lightWhite),
                    child: ListTile(
                      //later will be the image if there is
                      leading: CircleAvatar(
                        backgroundColor: myAppColors.secondaryColor,
                        child: Icon(
                          Icons.card_giftcard,
                          color: isDarkMode ? myAppColors.lightWhite : myAppColors.darkBlack,
                        ),
                      ),
                      title: Text(
                        gift['giftName'],
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? myAppColors.lightWhite : myAppColors.darkBlack,
                        ),
                      ),
                      subtitle: Text(
                        "Category: ${gift['category']}",
                        style: TextStyle(
                          color: isDarkMode
                              ? myAppColors.lightWhite.withOpacity(0.7)
                              : myAppColors.darkBlack.withOpacity(0.7),
                        ),
                      ),
                      trailing: ElevatedButton(
                        onPressed: () => togglePledgeStatus(index),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isPledged ? Colors.grey : myAppColors.primColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text(
                          isPledged ? 'Pledged' : 'Pledge',
                          style:  TextStyle(color: isDarkMode ? myAppColors.lightWhite : myAppColors.darkBlack),
                        ),
                      ),
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
