import 'package:flutter/material.dart';
import 'package:hedieaty/colors.dart';




class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onThemeToggle;
  final bool isDarkMode;
  final List<Widget>? actions;

  const CustomAppBar({super.key, 
    required this.title,
    required this.isDarkMode,
    this.onThemeToggle,
    this.actions
  });

  @override
  Widget build(BuildContext context) {
   // bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              myAppColors.primColor,
              myAppColors.secondaryColor,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 15.0,
          title: Text(title),
          actions: actions?? [
           IconButton(
             icon: Icon(isDarkMode ? Icons.nights_stay : Icons.wb_sunny),
               onPressed: onThemeToggle,
               color: isDarkMode ? myAppColors.lightWhite: myAppColors.darkBlack
        ),
      ],
          // bottom: bottoms,
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
