import 'package:flutter/material.dart';
import 'package:hedieaty/colors.dart';
import 'package:hedieaty/appBar.dart';

class giftList extends StatefulWidget {
  @override
  _giftListPageState createState() => _giftListPageState();
}

class _giftListPageState extends State<giftList> {
  List<Map<String, dynamic>> gifts = [
    {'name': 'Smartphone', 'category': 'Electronics', 'status': 'available', 'event': 'birthday'},
    {'name': 'Book', 'category': 'Books', 'status': 'pledged', 'event': 'wedding'},
    {'name': 'Headphones', 'category': 'Electronics', 'status': 'available', 'event': 'birthday'},
    {'name': 'T-shirt', 'category': 'Clothing', 'status': 'pledged', 'event': 'graduation'},
  ];

  String sortOption = '';

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

  void addGift(String name, String category, String event) {
    setState(() {
      gifts.add({
        'name': name,
        'category': category,
        'status': 'available',
        'event': event,
      });
    });
  }

  void editGift(int index, String newName, String newCategory, String newEvent) {
    setState(() {
      gifts[index] = {
        'name': newName,
        'category': newCategory,
        'status': 'available',
        'event': newEvent,  // Ensure event is updated
      };
    });
  }

  void deleteGift(int index) {
    setState(() {
      gifts.removeAt(index);
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
            icon: Icon(Icons.filter_list, color: myAppColors.darkBlack),
            onSelected: sortGifts,
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem<String>(
                  value: 'name',
                  child: Text('Sort by Name'),
                ),
                PopupMenuItem<String>(
                  value: 'category',
                  child: Text('Sort by Category'),
                ),
                PopupMenuItem<String>(
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
          Expanded(
            child: ListView.builder(
              itemCount: gifts.length,
              itemBuilder: (context, index) {
                var gift = gifts[index];
                bool isPledged = gift['status'] == 'pledged';

                return Card(
                  color: isPledged ? Colors.red[100] : Colors.green[100], // Color-coded based on pledge status
                  margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),

                  child: ListTile(
                    title: Text(gift['name'], style: TextStyle(color: isDarkMode ? myAppColors.lightWhite : myAppColors.darkBlack)),
                    subtitle: Text(gift['event'] ?? 'No event', style: TextStyle(color: isDarkMode ? myAppColors.lightWhite : myAppColors.darkBlack)),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: myAppColors.primColor),
                      onPressed: () => deleteGift(index),
                    ),
                    onTap: () {
                      if (!isPledged) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            TextEditingController nameController = TextEditingController(text: gift['name']);
                            TextEditingController categoryController = TextEditingController(text: gift['category']);
                            TextEditingController eventController = TextEditingController(text: gift['event']);

                            return AlertDialog(
                              title: Text(
                                'Edit Gift ${gift["name"]}',
                                style: TextStyle(color: isDarkMode ? myAppColors.lightWhite : myAppColors.darkBlack),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextField(
                                    controller: nameController,
                                    decoration: InputDecoration(labelText: 'Gift Name',labelStyle:TextStyle(color:isDarkMode ? myAppColors.lightWhite : myAppColors.darkBlack )),
                                  ),
                                  TextField(
                                    controller: categoryController,
                                    decoration: InputDecoration(labelText: 'Category',labelStyle:TextStyle(color:isDarkMode ? myAppColors.lightWhite : myAppColors.darkBlack)),
                                  ),
                                  TextField(
                                    controller: eventController,
                                    decoration: InputDecoration(labelText: 'Event',labelStyle:TextStyle(color:isDarkMode ? myAppColors.lightWhite : myAppColors.darkBlack)),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    editGift(index, nameController.text, categoryController.text, eventController.text);
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Save'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              TextEditingController nameController = TextEditingController();
              TextEditingController categoryController = TextEditingController();
              TextEditingController eventController = TextEditingController();

              return AlertDialog(
                title: Text('Add New Gift'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Gift Name'),
                    ),
                    TextField(
                      controller: categoryController,
                      decoration: InputDecoration(labelText: 'Category'),
                    ),
                    TextField(
                      controller: eventController,
                      decoration: InputDecoration(labelText: 'Event'),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      addGift(nameController.text, categoryController.text, eventController.text);  // Pass the event as well
                      Navigator.of(context).pop();
                    },
                    child: Text('Add'),
                  ),
                ],
              );
            },
          );
        },
        backgroundColor: myAppColors.primColor, // Primary color for the button
        child: Icon(
          Icons.add, // Add icon to represent adding an event
          // color: myAppColors.secondaryColor, // Icon color from your palette
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
