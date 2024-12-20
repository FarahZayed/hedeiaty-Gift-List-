import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting

class ManageEventsPage extends StatefulWidget {
  final Map<String, dynamic>? event;

  const ManageEventsPage({super.key, this.event});

  @override
  _ManageEventsPageState createState() => _ManageEventsPageState();
}

class _ManageEventsPageState extends State<ManageEventsPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController statusController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        dateController.text = picked.toIso8601String().split('T')[0];
        _updateStatus(picked);
      });
    }
  }

  void _updateStatus(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDate = DateTime(date.year, date.month, date.day);

    if (selectedDate.isBefore(today)) {
      statusController.text = 'Past';
    } else if (selectedDate.isAfter(today)) {
      statusController.text = 'Upcoming';
    } else {
      statusController.text = 'Current';
    }
  }

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      nameController.text = widget.event!['name'];
      categoryController.text = widget.event!['category'];

      dateController.text = widget.event!['date'];
      locationController.text = widget.event!['location'] ?? '';
      descriptionController.text = widget.event!['description'] ?? '';
      _updateStatus(DateTime.parse(widget.event!['date']));
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditMode = widget.event != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Events' : 'Add Events'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildTextField(nameController, 'Event Name', Icons.event),
            const SizedBox(height: 16),
            _buildTextField(categoryController, 'Category', Icons.category),
            // const SizedBox(height: 16),
            // _buildTextField(statusController, 'Status', Icons.info, readOnly: true),
            const SizedBox(height: 16),
            TextField(
              controller: dateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Date',
                prefixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onTap: () => _selectDate(context),
            ),
            const SizedBox(height: 16),
            _buildTextField(locationController, 'Location', Icons.location_on),
            const SizedBox(height: 16),
            _buildTextField(descriptionController, 'Description', Icons.description),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'name': nameController.text.trim(),
                  'category': categoryController.text.trim(),
                  'status': statusController.text.trim(),
                  'date': dateController.text.trim(),
                  'location': locationController.text.trim(),
                  'description': descriptionController.text.trim(),
                });
              },
              child: Text(isEditMode ? 'Save Changes' : 'Add Event'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool readOnly = false}) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}