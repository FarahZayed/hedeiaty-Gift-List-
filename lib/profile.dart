import 'package:flutter/material.dart';
import 'package:hedieaty/colors.dart';
import 'package:hedieaty/appBar.dart';

class profilePage extends StatefulWidget {

  @override
  _profilePageState createState() => _profilePageState();
}

class _profilePageState extends State<profilePage> {
  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(title: "Profile",isDarkMode:  isDarkMode),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('asset/profile.png'),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      //will be fetched from DB
                      "User Name",
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? myAppColors.lightWhite : myAppColors.darkBlack,
                      ),
                    ),
                    Text(
                      "user.email@example.com",
                      style: TextStyle(
                        fontSize: 16.0,
                        color: isDarkMode ? myAppColors.lightWhite.withOpacity(0.7) : myAppColors.darkBlack.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Personal Information Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 4.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Personal Information",
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? myAppColors.lightWhite : myAppColors.darkBlack,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        leading: Icon(Icons.person, color: myAppColors.primColor),
                        title: Text("Update Personal Information"),
                        trailing: Icon(Icons.arrow_forward_ios, color: myAppColors.secondaryColor),
                        onTap: () {
                          // Navigate to update personal information page
                        },
                      ),
                      Divider(),
                      SwitchListTile(
                        title: Text(
                          "Enable Notifications",
                          style: TextStyle(
                            color: isDarkMode ? myAppColors.lightWhite : myAppColors.darkBlack,
                          ),
                        ),
                        value: notificationsEnabled,
                        activeColor: myAppColors.primColor,
                        onChanged: (bool value) {
                          setState(() {
                            notificationsEnabled = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Created Events and Gifts Section
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 4.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "My Events & Gifts",
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? myAppColors.lightWhite : myAppColors.darkBlack,
                        ),
                      ),
                      const SizedBox(height: 10),
                      //needs to linked later to DB and page event and gift
                      ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: 3,
                        itemBuilder: (context, index) {
                          return ListTile(
                            leading: Icon(Icons.event, color: myAppColors.secondaryColor),
                            title: Text("Event ${index + 1}: Birthday Party"),
                            subtitle: Text("Gifts: Smartphone, Headphones"),
                            trailing: Icon(Icons.arrow_forward_ios, color: myAppColors.secondaryColor),
                            onTap: () {
                              // Navigate to event
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // My Pledged Gifts Section
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                elevation: 4.0,
                child: ListTile(
                  leading: Icon(Icons.card_giftcard, color: myAppColors.primColor),
                  title: Text("My Pledged Gifts"),
                  trailing: Icon(Icons.arrow_forward_ios, color: myAppColors.secondaryColor),
                  onTap: () {
                    // Navigate to My Pledged Gifts Page
                    Navigator.pushNamed(context, "/pledgedGifts");
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
