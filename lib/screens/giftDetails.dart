import 'package:flutter/material.dart';
import 'package:hedieaty/widgets/appBar.dart';
import 'package:hedieaty/widgets/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GiftDetailsPage extends StatefulWidget {
  final Map<String, dynamic>? gift;
  final String? eventId;
  final String userId;

  const GiftDetailsPage({super.key, this.gift, this.eventId, required this.userId});

  @override
  _GiftDetailsPageState createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController priceController = TextEditingController();

  String? selectedEventId;
  String? eventName;
  List<Map<String, dynamic>> userEvents = [];
  bool isPledged = false;

  @override
  void initState() {
    super.initState();

    // Fetch user's events and populate dropdown
    _fetchUserEvents();

    // Pre-fill gift data
    if (widget.gift != null) {
      nameController.text = widget.gift!['name'];
      descriptionController.text = widget.gift!['description'];
      categoryController.text = widget.gift!['category'];
      priceController.text = widget.gift!['price'].toString();
      selectedEventId = widget.gift!['eventId'];
      //isPledged = widget.gift!['status'] == 'pledged';
    } else if (widget.eventId != null) {
      selectedEventId = widget.eventId;
      _fetchEventName(widget.eventId!); // Fetch the name of the event
    }
  }

  Future<void> _fetchUserEvents() async {
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
      if (userDoc.exists) {
        List<String> eventIds = List<String>.from(userDoc.data()?['eventIds'] ?? []);

        List<Map<String, dynamic>> events = [];
        for (String eventId in eventIds) {
          final eventDoc = await FirebaseFirestore.instance.collection('event').doc(eventId).get();
          if (eventDoc.exists) {
            events.add({
              'id': eventId,
              'name': eventDoc.data()?['name'] ?? 'Unnamed Event',
            });
          }
        }

        setState(() {
          userEvents = events;
        });
      }
    } catch (e) {
      print("Error fetching user events: $e");
    }
  }

  Future<void> _fetchEventName(String eventId) async {
    try {
      final eventDoc = await FirebaseFirestore.instance.collection('event').doc(eventId).get();
      if (eventDoc.exists) {
        setState(() {
          eventName = eventDoc.data()?['name'] ?? 'Unnamed Event';
        });
      }
    } catch (e) {
      print("Error fetching event name: $e");
    }
  }

  // void saveGift() {
  //   if (selectedEventId == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Please select an event.")),
  //     );
  //     return;
  //   }
  //
  //   final newGift = {
  //     'name': nameController.text.trim(),
  //     'description': descriptionController.text.trim(),
  //     'category': categoryController.text.trim(),
  //     'price': double.tryParse(priceController.text) ?? 0,
  //     'status': isPledged ? 'pledged' : 'available',
  //     'eventId': selectedEventId,
  //   };
  //
  //   Navigator.pop(context, newGift);
  // }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: widget.gift != null ? 'Edit Gift' : 'Add Gift',
        isDarkMode: isDarkMode,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gift Information Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(
                        controller: nameController,
                        label: 'Gift Name',
                        icon: Icons.card_giftcard,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: descriptionController,
                        label: 'Description',
                        icon: Icons.description,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: categoryController,
                        label: 'Category',
                        icon: Icons.category,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: priceController,
                        label: 'Price',
                        icon: Icons.attach_money,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      // Dropdown for Event Selection
                      DropdownButtonFormField<String>(
                        value: selectedEventId,
                        items: userEvents.map((event) {
                          return DropdownMenuItem<String>(
                            value: event['id'],
                            child: Text(event['name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedEventId = value;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: 'Event',
                          prefixIcon: const Icon(Icons.event, color: myAppColors.primColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      if (eventName != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            'Selected Event: $eventName',
                            style: TextStyle(
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                              color: myAppColors.primColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Pledge Status Card
              // Card(
              //   elevation: 4,
              //   shape: RoundedRectangleBorder(
              //     borderRadius: BorderRadius.circular(15),
              //   ),
              //   child: ListTile(
              //     contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              //     title: Text('Status: ${isPledged ? 'Pledged' : 'Available'}'),
              //     trailing: Switch(
              //       value: isPledged,
              //       onChanged: (value) {
              //         setState(() {
              //           isPledged = value;
              //         });
              //       },
              //     ),
              //   ),
              // ),

              //const SizedBox(height: 20),

              // Save Button
              Center(
                child: ElevatedButton(
                  onPressed: (){
                    Navigator.pop(context, {
                      'name': nameController.text.trim(),
                      'category': categoryController.text.trim(),
                      // 'status': statusController.text.trim(),
                      'eventId': selectedEventId,
                      'price': priceController.text.trim(),
                      'description': descriptionController.text.trim(),
                    });
                  },
                  child: Text(widget.gift != null ? 'Update Gift' : 'Add Gift'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: myAppColors.primColor),
        labelText: label,
        labelStyle: TextStyle(
          color: myAppColors.primColor,
          fontWeight: FontWeight.bold,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: myAppColors.primColor),
          borderRadius: BorderRadius.circular(15),
        ),
      ),
    );
  }
}
