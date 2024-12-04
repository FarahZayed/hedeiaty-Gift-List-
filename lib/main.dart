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

//firebase
import 'package:firebase_core/firebase_core.dart';
import 'data/firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
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
        "/login":(context)=>loginPage(),
        "/home":(context)=>HomeScreen(onThemeToggle: _toggleTheme),
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

        "/profile":(context)=>profilePage(),
        "/pledgedGifts": (context) => pledgedGiftsPage(userId: ModalRoute.of(context)?.settings.arguments as String),
        "/friendGiftPage":(context){
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
          return friendGiftPage(
            friendId: args['friendId'],
              eventId:args['eventId'],
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



