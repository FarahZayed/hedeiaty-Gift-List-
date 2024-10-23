import 'package:flutter/material.dart';
import 'package:hedieaty/homeScreen.dart';
import 'package:hedieaty/colors.dart';

//TO BE CHANGED
import 'package:hedieaty/eventList.dart';
import 'package:hedieaty/login.dart';
import 'package:hedieaty/giftList.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

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
       home:giftList(),
      //home:giftListPage(),
    );
  }
}

class MyAppThemes {
  static final lightTheme = ThemeData(
    primaryColor: myAppColors.lightWhite,
    brightness: Brightness.light,
    scaffoldBackgroundColor: myAppColors.lightWhite,
    colorScheme: ColorScheme.light(
      primary: myAppColors.primColor,
      secondary: myAppColors.secondaryColor,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: myAppColors.primColor,
      foregroundColor: myAppColors.lightWhite,
    ),
  );

  static final darkTheme = ThemeData(
  primaryColor: myAppColors.darkBlack,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: myAppColors.darkBlack,
  colorScheme: ColorScheme.dark(
  primary: myAppColors.primColor,
  secondary: myAppColors.secondaryColor,
  ),
    appBarTheme: AppBarTheme(
      backgroundColor: myAppColors.primColor,
      foregroundColor: myAppColors.darkBlack,
    ),
  );
}



