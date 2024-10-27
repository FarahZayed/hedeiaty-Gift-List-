import 'package:flutter/material.dart';
import 'package:hedieaty/colors.dart';
import 'package:hedieaty/appBar.dart';
import 'package:hedieaty/giftDetails.dart';

class giftList extends StatefulWidget {
  const giftList({super.key});

  @override
  _giftListPageState createState() => _giftListPageState();
}

class _giftListPageState extends State<giftList> {
  List<Map<String, dynamic>> gifts = [
    {
      'name': 'Smartphone',
      'category': 'Electronics',
      'description': 'A high-end smartphone with the latest features.',
      'price': 12.5,
      'status': 'available',
      'event': 'birthday',
    },
    {
      'name': 'Book',
      'category': 'Books',
      'description': 'A captivating novel that will keep you engaged.',
      'price': 50.0,
      'status': 'pledged',
      'event': 'wedding',
    },
    {
      'name': 'Headphones',
      'category': 'Electronics',
      'description': 'Wireless headphones with noise cancellation.',
      'price': 60.3,
      'status': 'available',
      'event': 'birthday',
    },
    {
      'name': 'T-shirt',
      'category': 'Clothing',
      'description': 'A stylish and comfortable t-shirt.',
      'price': 55.0,
      'status': 'pledged',
      'event': 'graduation',
    },
    {
      'name': 'Tablet',
      'category': 'Electronics',
      'description': 'A versatile tablet for work and entertainment.',
      'price': 200.0,
      'status': 'available',
      'event': 'anniversary',
    },
    {
      'name': 'Coffee Maker',
      'category': 'Kitchen',
      'description': 'A programmable coffee maker for your daily caffeine fix.',
      'price': 75.0,
      'status': 'pledged',
      'event': 'housewarming',
    },
    {
      'name': 'Backpack',
      'category': 'Travel',
      'description': 'A durable backpack for all your adventures.',
      'price': 80.0,
      'status': 'available',
      'event': 'travel',
    },
    {
      'name': 'Watch',
      'category': 'Accessories',
      'description': 'A classic watch with a timeless design.',
      'price': 150.0,
      'status': 'pledged',
      'event': 'birthday',
    },
    {
      'name': 'Board Game',
      'category': 'Games',
      'description': 'A fun board game for the whole family.',
      'price': 35.0,
      'status': 'available',
      'event': 'christmas',
    },
    {
      'name': 'Gift Card',
      'category': 'Other',
      'description': 'A gift card for their favorite store.',
      'price': 25.0,
      'status': 'pledged',
      'event': 'birthday',
    },
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

  void navigateToGiftDetails({Map<String, dynamic>? gift}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GiftDetailsPage(gift: gift),
      ),
    );

    if (result != null) {
      if (gift != null) {

        int index = gifts.indexOf(gift);
        editGift(index, result['name'], result['category'], result['description'], result['price'], result['status'], result['image'],result['event']);
      } else {

        addGift(result['name'], result['category'], result['description'], result['price'], result['status'], result['image'],result['event']);
      }
    }
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
          Expanded(
            child: ListView.builder(
              itemCount: gifts.length,
              itemBuilder: (context, index) {
                var gift = gifts[index];
                bool isPledged = gift['status'] == 'pledged';

                return Card(
                  color: isPledged ? myAppColors.wrongColor.withOpacity(0.4) : (isDarkMode?Colors.black: myAppColors.lightWhite),
                  margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
                  elevation: 15.0,
                  child: ListTile(
                    title: Text(gift['name'], style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? myAppColors.lightWhite : myAppColors.darkBlack,
                      ),
                    ),
                    subtitle: Text(gift['event'] ?? 'No event', style:TextStyle(
                      color: isDarkMode
                          ? myAppColors.lightWhite.withOpacity(0.7)
                          : myAppColors.darkBlack.withOpacity(0.7),
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: myAppColors.primColor),
                      onPressed: () => deleteGift(index),
                    ),
                    onTap: () {
                        if (!isPledged) {
                          navigateToGiftDetails(gift: gift);
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
          navigateToGiftDetails();
        },
        backgroundColor: myAppColors.secondaryColor.withOpacity(0.7),
        child: const Icon(
          Icons.add,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
