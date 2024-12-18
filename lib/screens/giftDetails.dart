import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hedieaty/widgets/appBar.dart';
import 'package:hedieaty/widgets/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

import 'package:permission_handler/permission_handler.dart';

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

  File? _imageFile;
  String? _uploadedImageUrl;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    _fetchUserEvents();

    if (widget.gift != null) {
      nameController.text = widget.gift!['name'];
      descriptionController.text = widget.gift!['description'];
      categoryController.text = widget.gift!['category'];
      priceController.text = widget.gift!['price'].toString();
      selectedEventId = widget.gift!['eventId'];
      _uploadedImageUrl = widget.gift!['image'];
    } else if (widget.eventId != null) {
      selectedEventId = widget.eventId;
      _fetchEventName(widget.eventId!);
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
            events.add({'id': eventId, 'name': eventDoc.data()?['name'] ?? 'Unnamed Event'});
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

  Future<void> requestGalleryPermission() async {
    PermissionStatus status = await Permission.storage.status;

    if (status.isDenied) {
      // Request permission
      status = await Permission.storage.request();

      if (status.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gallery permission is required to select an image.")),
        );
        return;
      }
    }

    if (status.isPermanentlyDenied) {
      // User permanently denied permission
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Gallery permission is permanently denied. Enable it in settings."),
          action: SnackBarAction(
            label: "Settings",
            onPressed: () {
              openAppSettings();
            },
          ),
        ),
      );
      return;
    }

    if (status.isGranted) {
      print('Gallery permissions granted.');
    }

  }

  Future<void> _pickImage() async {
    await requestGalleryPermission();

    if (await Permission.storage.isGranted) {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image selected successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No image selected.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gallery permission denied.")),
      );
    }
  }



  // Future<void> _uploadImage() async {
  //   try {
  //     if (_imageFile != null) {
  //       String fileName = 'gifts/${DateTime.now().millisecondsSinceEpoch}.png';
  //       Reference ref = FirebaseStorage.instance.ref().child(fileName);
  //       UploadTask uploadTask = ref.putFile(_imageFile!);
  //
  //       TaskSnapshot taskSnapshot = await uploadTask;
  //       String downloadUrl = await taskSnapshot.ref.getDownloadURL();
  //
  //       setState(() {
  //         _uploadedImageUrl = downloadUrl;
  //       });
  //
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Image uploaded successfully!")),
  //       );
  //     }
  //   } catch (e) {
  //     print("Error uploading image: $e");
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Error uploading image: $e")),
  //     );
  //   }
  // }

  Future<String> _uploadImageToImgur(String imagePath) async {
    print("UPLOAD IMAGE TO IMGUR");
    const clientId = '6035c0610d863f1';
    final uri = Uri.parse('https://api.imgur.com/3/image');
    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Client-ID $clientId';
    request.files.add(await http.MultipartFile.fromPath('image', imagePath));

    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    final decodedResponse = json.decode(responseData);

    if (response.statusCode == 200 && decodedResponse['success'] == true) {
      return decodedResponse['data']['link'];
    } else {
      throw Exception('Failed to upload image to Imgur.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: widget.gift != null ? 'Edit Gift' : 'Add Gift',
        isDarkMode: Theme.of(context).brightness == Brightness.dark,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Gift Image Upload
              GestureDetector(
                onTap:()async{

                   await _pickImage();
                },
                child: Center(
                  child: _uploadedImageUrl != null
                      ? Image.network(_uploadedImageUrl!, height: 150, width: 150, fit: BoxFit.cover)
                      : _imageFile != null
                      ? Image.file(_imageFile!, height: 150, width: 150, fit: BoxFit.cover)
                      : Container(
                    height: 150,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Text Fields
              _buildTextField(nameController, 'Gift Name', Icons.card_giftcard),
              const SizedBox(height: 16),
              _buildTextField(descriptionController, 'Description', Icons.description),
              const SizedBox(height: 16),
              _buildTextField(categoryController, 'Category', Icons.category),
              const SizedBox(height: 16),
              _buildTextField(priceController, 'Price', Icons.attach_money, TextInputType.number),
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


              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () async{
                    if (_imageFile != null) {
                      try {
                        final uploadedUrl = await _uploadImageToImgur(_imageFile!.path);
                        setState(() {
                          _uploadedImageUrl = uploadedUrl;
                        });
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error uploading image: $e")),
                        );
                      }
                    }
                    print("URL IN DETAILS::"+_uploadedImageUrl!);
                    Navigator.pop(context, {
                      'name': nameController.text.trim(),
                      'category': categoryController.text.trim(),
                      'description': descriptionController.text.trim(),
                      'price': priceController.text.trim(),
                      'eventId': selectedEventId,
                      'image': _uploadedImageUrl,
                    });
                  },
                  child: const Text('Save Gift'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon,
      [TextInputType keyboardType = TextInputType.text]) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: myAppColors.primColor),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
