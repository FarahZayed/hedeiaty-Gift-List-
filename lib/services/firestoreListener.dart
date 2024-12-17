import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'cloudMessaging.dart';
class FirestoreListener {
  static void listenForPledges(String currentUserId) {
    print("Listening for pledges for userId: $currentUserId");

    FirebaseFirestore.instance
        .collection('pledges')
        .where('pledgedToUserId', isEqualTo: currentUserId) // Listen for pledges made to the current user
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
              // Fetch the `pledgedByUserId` username for the notification
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


// class FirestoreListener {
//   // static void listenForPledges(String currentUserId) {
//   //   print("LISTENEDD");
//   //   FirebaseFirestore.instance
//   //       .collection('pledges')
//   //       .where('pledgedByUserId', isEqualTo: currentUserId)
//   //       .snapshots()
//   //       .listen((querySnapshot) async {
//   //     for (var docChange in querySnapshot.docChanges) {
//   //       if (docChange.type == DocumentChangeType.added) {
//   //         final data = docChange.doc.data();
//   //         final pledgedByUserId = data?['pledgedByUserId'];
//   //         final pledgedToUserId = data?['pledgedToUserId']; // Fetch the pledgedToUserId (the recipient)
//   //         final giftName = data?['giftName'];
//   //
//   //         if (pledgedToUserId != null && giftName != null) {
//   //           // Trigger a local notification to the pledgedToUserId (the recipient)
//   //           print("SEND NOTFI");
//   //           var userDoc = await FirebaseFirestore.instance.collection("users").doc(pledgedByUserId).get(); // Fetch recipient user data
//   //           if (userDoc.exists) {
//   //             NotificationService.showNotification(
//   //               id: docChange.doc.hashCode,
//   //               title: 'Gift Pledged!',
//   //               body: 'User ${userDoc.data()?['username']} pledged "$giftName" to you.',
//   //             );
//   //           }
//   //         }
//   //       }
//   //     }
//   //   });
//   // }
//
//   static void listenForPledges(String currentUserId) {
//     print("Listening for pledges for userId: $currentUserId");
//
//     FirebaseFirestore.instance
//         .collection('pledges')
//         .where('pledgedToUserId', isEqualTo: currentUserId) // Listen for pledges made to the current user
//         .snapshots()
//         .listen((querySnapshot) async {
//       for (var docChange in querySnapshot.docChanges) {
//         if (docChange.type == DocumentChangeType.added) {
//           final data = docChange.doc.data();
//           final pledgedByUserId = data?['pledgedByUserId'];
//           final giftName = data?['giftName'];
//
//           if (pledgedByUserId != null && giftName != null) {
//             // Fetch the `pledgedByUserId` username for the notification
//             var userDoc = await FirebaseFirestore.instance.collection("users").doc(pledgedByUserId).get();
//             if (userDoc.exists) {
//               NotificationService.showNotification(
//                 id: docChange.doc.hashCode,
//                 title: 'Gift Pledged!',
//                 body: 'User ${userDoc.data()?['username']} pledged "$giftName" to you.',
//               );
//             }
//           }
//         }
//       }
//     });
//   }
// }
