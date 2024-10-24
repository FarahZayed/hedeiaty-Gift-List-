import 'package:flutter/material.dart';
import 'package:hedieaty/appBar.dart';
import 'package:hedieaty/colors.dart'; // Assuming you have this for your theme colors

class GiftDetailsPage extends StatefulWidget {
  final Map<String, dynamic>? gift; // Pass gift details if editing

  const GiftDetailsPage({super.key, this.gift});

  @override
  _GiftDetailsPageState createState() => _GiftDetailsPageState();
}

class _GiftDetailsPageState extends State<GiftDetailsPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController eventController = TextEditingController();
  bool isPledged = false;

  @override
  void initState() {
    super.initState();
    // in case it is editing
    if (widget.gift != null) {
      nameController.text = widget.gift!['name'];
      descriptionController.text = widget.gift!['description'];
      categoryController.text = widget.gift!['category'];
      priceController.text = widget.gift!['price'].toString();
      eventController.text = widget.gift!['event'];
      isPledged = widget.gift!['status'] == 'pledged';
    }
  }

  void saveGift() {
    // Will implement to change or add in DB
    final newGift = {
      'name': nameController.text,
      'description': descriptionController.text,
      'category': categoryController.text,
      'price': double.tryParse(priceController.text) ?? 0,
      'status': isPledged ? 'pledged' : 'available',
      'event': eventController.text,
    };
    Navigator.pop(context, newGift);
  }

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
                      _buildTextField(
                        controller: eventController,
                        label: 'Event',
                        icon: Icons.event,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Pledge Status Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  title: Text('Status: ${isPledged ? 'Pledged' : 'Available'}',),
                  trailing: Switch(
                    value: isPledged,
                    onChanged: (value) {
                      setState(() {
                        isPledged = value;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Save Button
              Center(
                child: ElevatedButton(
                  onPressed: saveGift,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: myAppColors.primColor,
                    foregroundColor: isDarkMode
                        ? myAppColors.darkBlack
                        : myAppColors.lightWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 40,
                      vertical: 15,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
