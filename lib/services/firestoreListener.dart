import 'package:cloud_firestore/cloud_firestore.dart';

import 'cloudMessaging.dart';
class FirestoreListener {
  static void listenForPledges(String currentUserId) {
    print("Listening for pledges for userId: $currentUserId");

    FirebaseFirestore.instance
        .collection('pledges')
        .where('pledgedToUserId', isEqualTo: currentUserId)
        .snapshots()
        .listen((querySnapshot) async {
      print("New pledge detected for $currentUserId");
      for (var docChange in querySnapshot.docChanges) {
        if (docChange.type == DocumentChangeType.added) {
          final data = docChange.doc.data();
          final pledgedByUserId = data?['pledgedByUserId'];
          final giftName = data?['giftName'];

          if (pledgedByUserId != null && giftName != null) {
            try {

              var userDoc = await FirebaseFirestore.instance.collection("users").doc(pledgedByUserId).get();
              if (userDoc.exists) {
                final pledgedByUsername = userDoc.data()?['username'] ?? "Unknown User";
                NotificationService.showNotification(
                  id: docChange.doc.hashCode,
                  title: 'Gift Pledged!',
                  body: 'User $pledgedByUsername pledged "$giftName" to you.',
                );
              }
            } catch (e) {
              print("Error fetching pledgedByUserId details: $e");
            }
          }
        }
      }
    });
  }
}

