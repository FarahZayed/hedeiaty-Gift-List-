import 'package:flutter_local_notifications/flutter_local_notifications.dart';
class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const androidInitializationSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(
      android: androidInitializationSettings,
    );

    await _localNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    print("Sending notification...");
    const androidDetails = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'This channel is for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _localNotificationsPlugin.show(id, title, body, notificationDetails);
  }
}

// class NotificationService {
//   static final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
//   FlutterLocalNotificationsPlugin();
//
//   static Future<void> initialize() async {
//     const androidInitializationSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const initializationSettings = InitializationSettings(
//       android: androidInitializationSettings,
//     );
//
//     await _localNotificationsPlugin.initialize(initializationSettings);
//   }
//
//   static Future<void> showNotification({
//     required int id,
//     required String title,
//     required String body,
//   }) async {
//     print("SENDINGG>..");
//     const androidDetails = AndroidNotificationDetails(
//       'channel_id',
//       'channel_name',
//       channelDescription: 'This channel is for important notifications.',
//       importance: Importance.high,
//       priority: Priority.high,
//     );
//
//     const notificationDetails = NotificationDetails(
//       android: androidDetails,
//     );
//
//     await _localNotificationsPlugin.show(id, title, body, notificationDetails);
//   }
// }




// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
//
// class NotificationService {
//   static final _firebaseMessaging = FirebaseMessaging.instance;
//   static final _localNotifications = FlutterLocalNotificationsPlugin();
//
//   static void initialize() async {
//     // Configure foreground notifications
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       if (message.notification != null) {
//         _showLocalNotification(message.notification!);
//       }
//     });
//
//     // Configure background notification click behavior
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print("Notification clicked!");
//       // Handle navigation or other logic
//     });
//
//     // Initialize local notifications
//     const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
//     const initSettings = InitializationSettings(android: androidSettings);
//     await _localNotifications.initialize(initSettings);
//   }
//
//   static void _showLocalNotification(RemoteNotification notification) {
//     const androidDetails = AndroidNotificationDetails(
//       "channel_id",
//       "channel_name",
//       importance: Importance.high,
//     );
//
//     const notificationDetails = NotificationDetails(android: androidDetails);
//
//     _localNotifications.show(
//       notification.hashCode,
//       notification.title,
//       notification.body,
//       notificationDetails,
//     );
//   }
// }
//
//
//
//
// // import 'dart:convert';
// //
// // import 'package:firebase_messaging/firebase_messaging.dart';
// // import 'package:flutter/foundation.dart';
// // import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// //
// // class cloudMessaging{
// //   static final _messaging = FirebaseMessaging.instance;
// //   static final _localNotifications = FlutterLocalNotificationsPlugin();
// //   handleMessage(RemoteMessage? mess){
// //     if(mess== null){
// //       return;
// //     }
// //     print(mess!.notification?.title);
// //
// //   }
// //   Future<void> handlebackgroundMessage(RemoteMessage? mess) async{
// //
// //     print(mess!.notification?.title);
// //     print(mess!.notification?.body);
// //
// //   }
// //   late AndroidNotificationChannel channel;
// //   bool isFlutterLocalNotificationsInitialized = false;
// //   late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
// //
// //   Future<void> setupFlutterNotifications() async {
// //     if (isFlutterLocalNotificationsInitialized) {
// //       return;
// //     }
// //     channel = const AndroidNotificationChannel(
// //       'high_importance_channel', // id
// //       'High Importance Notifications', // title
// //       description:
// //       'This channel is used for important notifications.', // description
// //       importance: Importance.high,
// //     );
// //
// //     flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
// //
// //     /// Create an Android Notification Channel.
// //     ///
// //     /// We use this channel in the `AndroidManifest.xml` file to override the
// //     /// default FCM channel to enable heads up notifications.
// //     await flutterLocalNotificationsPlugin
// //         .resolvePlatformSpecificImplementation<
// //         AndroidFlutterLocalNotificationsPlugin>()
// //         ?.createNotificationChannel(channel);
// //
// //     /// Update the iOS foreground notification presentation options to allow
// //     /// heads up notifications.
// //     await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
// //       alert: true,
// //       badge: true,
// //       sound: true,
// //     );
// //     isFlutterLocalNotificationsInitialized = true;
// //   }
// //
// //   initPushNotification(){
// //     _messaging.getInitialMessage().then(handleMessage);
// //     FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
// //     FirebaseMessaging.onBackgroundMessage(handlebackgroundMessage);
// //
// //     FirebaseMessaging.onMessage.listen(showFlutterNotification);
// //   }
// //
// //   void initLocalNotification(){
// //     //mesh la2ya 7aga
// //   }
// //
// //
// //
// //   void showFlutterNotification(RemoteMessage message) {
// //     RemoteNotification? notification = message.notification;
// //     AndroidNotification? android = message.notification?.android;
// //     if (notification != null && android != null && !kIsWeb) {
// //       flutterLocalNotificationsPlugin.show(
// //         notification.hashCode,
// //         notification.title,
// //         notification.body,
// //         payload: jsonEncode(message.toMap()),
// //         NotificationDetails(
// //           android: AndroidNotificationDetails(
// //             channel.id,
// //             channel.name,
// //             channelDescription: channel.description,
// //             // TODO add a proper drawable resource to android, for now using
// //             //      one that already exists in example app.
// //             icon: 'launch_background',
// //           ),
// //         ),
// //       );
// //     }
// //   }
// //
// //   initNotification() async{
// //     await _messaging.requestPermission();
// //     final fcmToken = await _messaging.getToken();
// //     print('Token: $fcmToken' );
// //     await setupFlutterNotifications();
// //     initLocalNotification();
// //     initPushNotification();
// //
// //   }
// // }