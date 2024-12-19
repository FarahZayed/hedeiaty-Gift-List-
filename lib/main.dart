import 'package:flutter/material.dart';
import 'package:hedieaty/services/cloudMessaging.dart';
import 'package:hedieaty/services/connectivityController.dart';
import 'package:hedieaty/services/firestoreListener.dart';
import 'package:hedieaty/widgets/colors.dart';
//pages
import 'package:hedieaty/screens/eventList.dart';
import 'package:hedieaty/screens/homeScreen.dart';
import 'package:hedieaty/screens/giftList.dart';
import 'package:hedieaty/screens/login.dart';
import 'package:hedieaty/screens/profile.dart';
import 'package:hedieaty/screens/pledgedGifts.dart';
import 'package:hedieaty/screens/friendGiftList.dart';
import 'package:hedieaty/screens/manageEvents.dart';
import 'package:hedieaty/data/db.dart';
import 'package:hedieaty/services/syncManager.dart';
import 'package:hedieaty/services/cloudMessaging.dart';

//firebase
import 'package:firebase_core/firebase_core.dart';
import 'data/firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

//connectivity
import 'package:connectivity_plus/connectivity_plus.dart';

//shared Preference
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background notifications
  print("Handling a background message: ${message.messageId}");
  print("Handling a background message: ${message.notification?.title}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //initialize local DB
  final localDb = LocalDatabase();
  await localDb.database;

  // Initialize local notifications
  await NotificationService.initialize();

  // RUN APP
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  ThemeMode _themeMode = ThemeMode.system;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    //_initializeApp();
  }

  // Future<void> _initializeApp() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final userId = prefs.getString('userId');
  //   print("Logged-in userId: $userId");
  //
  //   if (userId != null) {
  //     setState(() {
  //       _currentUserId = userId;
  //     });
  //
  //
  //   }
  // }

  @override
  void dispose() {
    print("Disposing app and closing database.");
    LocalDatabase().closeDatabase();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print("AppLifecycleState changed: $state\n");
    if (state == AppLifecycleState.resumed) {
      _handleConnectivityChange();
    }
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      print("App is paused or detached. Closing database.");
      LocalDatabase().closeDatabase();
    }
  }

  void _handleConnectivityChange() async {
    bool isConnected = await connectivityController.isOnline();
    if (isConnected) {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      print("userid::" + userId.toString());
      await SyncManager().syncAllUnsyncedData(userId.toString());
    }
  }

  void _toggleTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    // if (_currentUserId == null) {
    //   return MaterialApp(
    //     home: Scaffold(
    //       body: Center(
    //         child: CircularProgressIndicator(),
    //       ),
    //     ),
    //   );
    // }

    return MaterialApp(
      title: 'Hedieaty',
      theme: MyAppThemes.lightTheme,
      debugShowCheckedModeBanner: false,
      darkTheme: MyAppThemes.darkTheme,
      themeMode: _themeMode,
      home: const loginPage(),
      routes: {
        "/login": (context) => loginPage(),
        "/home": (context) => HomeScreen(onThemeToggle: _toggleTheme),
        "/eventList": (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
          return eventList(
            userId: args['userId'],
            isLoggedIn: args['isLoggedIn'],
            currentUserId: args['currentUserId'],
          );
        },
        '/giftList': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
          return giftList(
            userId: args['userId'],
            eventId: args['eventId'],
            isLoggedin: args['isLoggedin'],
          );
        },
        "/profile": (context) => profilePage(user: ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>),
        "/pledgedGifts": (context) => pledgedGiftsPage(
            userId: ModalRoute.of(context)?.settings.arguments as String),
        "/friendGiftPage": (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
          return friendGiftPage(
            friendId: args['friendId'],
            eventId: args['eventId'],
            currentUserId: args['currentUserId'],
          );
        },
        "/manageEventsPage": (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          return ManageEventsPage(event: args?['event']);
        },
      },
    );
  }
}

class MyAppThemes {
  static final lightTheme = ThemeData(
    primaryColor: myAppColors.lightWhite,
    brightness: Brightness.light,
    scaffoldBackgroundColor: myAppColors.lightWhite,
    colorScheme: const ColorScheme.light(
      primary: myAppColors.primColor,
      secondary: myAppColors.secondaryColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: myAppColors.primColor,
      foregroundColor: myAppColors.lightWhite,
    ),
  );

  static final darkTheme = ThemeData(
    primaryColor: myAppColors.darkBlack,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: myAppColors.darkBlack,
    colorScheme: const ColorScheme.dark(
      primary: myAppColors.primColor,
      secondary: myAppColors.secondaryColor,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: myAppColors.primColor,
      foregroundColor: myAppColors.darkBlack,
    ),
  );
}
