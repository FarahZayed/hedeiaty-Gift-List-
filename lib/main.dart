import 'package:flutter/material.dart';
import 'package:hedieaty/colors.dart';
//pages
import 'package:hedieaty/eventList.dart';
import 'package:hedieaty/homeScreen.dart';
import 'package:hedieaty/giftList.dart';
import 'package:hedieaty/login.dart';
import 'package:hedieaty/profile.dart';
import 'package:hedieaty/pledgedGifts.dart';
import 'package:hedieaty/friendGiftList.dart';
import 'package:hedieaty/manageEvents.dart';
import 'package:hedieaty/db.dart';

void main() async {
  //WidgetsFlutterBinding.ensureInitialized(); // Ensure Flutter bindings are initialized before any async operations
  //DatabaseService().initDatabase();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }


  @override
  void initState() {
    super.initState();
    //DatabaseService().initDatabase();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hedieaty',
      theme: MyAppThemes.lightTheme,
      darkTheme: MyAppThemes.darkTheme,
      themeMode: _themeMode,
       home:const loginPage(),
      routes: {
        "/home":(context)=>HomeScreen(onThemeToggle: _toggleTheme),
        "/eventList":(context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
          return eventList(
            friendId: args['friendId'],

          );
        },
        '/giftList': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
          return giftList(
            friendId: args['friendId'],
            eventId: args['eventId'],
          );
        },

        "/profile":(context)=>profilePage(),
        "/pledgedGifts":(context)=>pledgedGiftsPage(),
        "/friendGiftPage":(context)=>friendGiftPage(friendName: ModalRoute.of(context)?.settings.arguments as String),
        "/mangeEventsPage":(context)=> mangeEventsPage(),

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



