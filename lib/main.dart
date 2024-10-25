import 'package:flutter/material.dart';
import 'package:hedieaty/colors.dart';
import 'package:hedieaty/eventList.dart';


//TO BE CHANGED
import 'package:hedieaty/homeScreen.dart';
import 'package:hedieaty/giftList.dart';
import 'package:hedieaty/login.dart';

void main() {
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
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hedieaty',
      theme: MyAppThemes.lightTheme,
      darkTheme: MyAppThemes.darkTheme,
      themeMode: _themeMode,
      //home:  HomeScreen(onThemeToggle: _toggleTheme),
       home:const loginPage(),
      routes: {
        "/home":(context)=>HomeScreen(onThemeToggle: _toggleTheme),
        "/eventList":(context)=>eventList(),
        "/giftList":(context)=>giftList(),

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



