import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty/colors.dart';
import 'package:hedieaty/appBar.dart';
import 'package:hedieaty/models/userModel.dart';
import 'package:hedieaty/db.dart';

class profilePage extends StatefulWidget {

  @override
  _profilePageState createState() => _profilePageState();
}

class _profilePageState extends State<profilePage> {
  bool notificationsEnabled = true;


  void _changeProfile(String username, String email, String phone, Map<String,dynamic> user) async {
    try {
      final firestore = FirebaseFirestore.instance;

      if (username.isNotEmpty || email.isNotEmpty || phone.isNotEmpty) {
        final updatedData = {
          if (username.isNotEmpty) 'username': username,
          if (email.isNotEmpty) 'email': email,
          if (phone.isNotEmpty) 'phone': phone,
        };


        await firestore.collection('users').doc(user['uid']).update(updatedData);


        final updatedSnapshot = await firestore.collection('users').doc(user['uid']).get();
        final updatedUser = updatedSnapshot.data();

        if (updatedUser != null) {
          setState(() {
            user['username'] = updatedUser['username'];
            user['email'] = updatedUser['email'];
            user['phone'] = updatedUser['phone'];
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Profile updated successfully")),
          );
        }

        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter the data you want to change")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("An error occurred: $e")),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    Map<String,dynamic> user = ModalRoute.of(context)!.settings.arguments as Map<String,dynamic>;
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    final TextEditingController userNameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    //final TextEditingController imageController = TextEditingController();

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
                      "${user['username']}",
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? myAppColors.lightWhite : myAppColors.darkBlack,
                      ),
                    ),
                    Text(
                      "${user['email']}",
                      style: TextStyle(
                        fontSize: 16.0,
                        color: isDarkMode ? myAppColors.lightWhite.withOpacity(0.7) : myAppColors.darkBlack.withOpacity(0.7),
                      ),
                    ),
                    Text(
                      "${user['phone']}",
                      style: TextStyle(
                        fontSize: 14.0,
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
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text("Update your profile"),
                                content: SingleChildScrollView(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        //SHOULD ADD IMAGE PICKER HERE
                                        TextField(
                                          controller: userNameController,
                                          keyboardType: TextInputType.name,
                                          decoration: InputDecoration(
                                            labelText: "Edit your username",
                                            hintText: user['username'],
                                            border: const OutlineInputBorder(),
                                          ),
                                        ),
                                        const SizedBox(height: 15.0),
                                        TextField(
                                          controller: emailController,
                                          keyboardType: TextInputType.emailAddress,
                                          decoration: InputDecoration(
                                            labelText: "Edit your email",
                                            hintText: user['email'],
                                            border: const OutlineInputBorder(),
                                          ),
                                        ),
                                        const SizedBox(height: 15.0),
                                        TextField(
                                          controller: phoneController,
                                          keyboardType: TextInputType.emailAddress,
                                          decoration: InputDecoration(
                                            labelText: "Edit your phone number",
                                            hintText: user['phone'] ?? 'You have no phone number saved',
                                            border: const OutlineInputBorder(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: (){
                                      setState(() {
                                          _changeProfile(userNameController.text.trim(), emailController.text.trim(), phoneController.text.trim(),user);
                                      });

                                    },
                                    child: const Text("Update"),
                                  ),
                                ],
                              );
                            },
                          );
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
