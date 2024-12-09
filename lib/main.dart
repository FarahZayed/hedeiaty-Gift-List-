import 'package:flutter/material.dart';
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

//firebase
import 'package:firebase_core/firebase_core.dart';
import 'data/firebase_options.dart';

//connectivity
import 'package:connectivity_plus/connectivity_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //initialize local DB
  final localDb = LocalDatabase();
  await localDb.database;

  //TEST DB
  final db = await LocalDatabase().database;
  final tables = await db.rawQuery("SELECT name FROM sqlite_master WHERE type='table'");
  print("Tables in the database: $tables");

  final schema = await db.rawQuery("PRAGMA table_info(event)");
  print("Schema of event table: $schema");

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    print("AppLifecycleState changed: $state\n");
    if (state == AppLifecycleState.resumed) {
      print("is Resumed");
      final connectivityResult = await Connectivity().checkConnectivity();
      _handleConnectivityChange(connectivityResult);
    }
  }

  void _handleConnectivityChange(List<ConnectivityResult> result) async {
    print("Connectivity result: $result\n"); // Debug log
    print ("checking connectivity..\n");
    bool isConnected = result.any((result) =>
    result == ConnectivityResult.mobile || result == ConnectivityResult.wifi);

    if (isConnected) {
      print("calling\n");
      await SyncManager().syncAllUnsyncedData();
    } else {
      print("A###");
    }

  }

  void _toggleTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hedieaty',
      theme: MyAppThemes.lightTheme,
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
          );
        },
        '/giftList': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
          return giftList(
            userId: args['userId'],
            eventId: args?['eventId'],
            isLoggedin: args['isLoggedin'],
          );
        },
        "/profile": (context) => profilePage(),
        "/pledgedGifts": (context) => pledgedGiftsPage(userId: ModalRoute.of(context)?.settings.arguments as String),
        "/friendGiftPage": (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
          return friendGiftPage(
            friendId: args['friendId'],
            eventId: args['eventId'],
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
