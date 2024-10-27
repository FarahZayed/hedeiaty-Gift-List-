import 'package:flutter/material.dart';
import 'package:hedieaty/appBar.dart';
import 'package:hedieaty/colors.dart'; // Assuming you have this for your theme colors

class mangeEventsPage extends StatefulWidget {
  final Map<String, dynamic>? event;
  const mangeEventsPage({super.key, this.event});

  @override
  _manageEventPageState createState() => _manageEventPageState();
}


class _manageEventPageState extends State<mangeEventsPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController statusController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != DateTime.tryParse(dateController.text)) {
      setState(() {
        dateController.text = picked.toString().split(' ')[0]; // Format the date as yyyy-MM-dd
      });
    }
  }

  Widget _buildDateField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required BuildContext context,
  }) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: () => _selectDate(context),
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


  @override
  void initState() {
    super.initState();
    // in case it is editing
    if (widget.event != null) {
      nameController.text = widget.event!['name'];
      categoryController.text = widget.event!['category'];
      dateController.text = widget.event!['date'].toString();
      statusController.text = widget.event!['status'];
    }
  }

  void saveEvent() {
    // Will implement to change or add in DB
    final newEvent = {
      'name': nameController.text,
      'category': categoryController.text,
      'date': DateTime.tryParse(dateController.text) ?? 0,
      'status': statusController.text,
    };
    Navigator.pop(context, newEvent);
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: CustomAppBar(
        title: widget.event != null ? 'Edit Event' : 'Add Event',
        isDarkMode: isDarkMode,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                        label: 'Event Name',
                        icon: Icons.event,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: categoryController,
                        label: 'Category',
                        icon: Icons.category,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: statusController,
                        label: 'Status',
                        icon: Icons.add_circle_outline,

                      ),
                      const SizedBox(height: 16),
                      _buildDateField(
                        controller: dateController,
                        label: 'Date',
                        icon: Icons.date_range_outlined,
                        context: context,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Pledge Status Card


              // Save Button
              Center(
                child: ElevatedButton(
                  onPressed: saveEvent,
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
                  child: Text(widget.event != null ? 'Update Event' : 'Add Event'),
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
