import 'package:flutter/material.dart' hide CarouselController;

import 'colors.dart';

class AppThemes {
  AppThemes._();

  static final darkTheme = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: darkBGColor,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: darkColor2,
      modalBackgroundColor: darkColor2,
    ),
    dialogBackgroundColor: darkColor2,
    popupMenuTheme: const PopupMenuThemeData(
      color: darkColor2,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.redAccent),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(lightColor),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: darkColor2,
      elevation: 2.0,
      titleTextStyle: TextStyle(
        color: lightColor,
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(
        color: lightColor,
      ),
    ),
    iconTheme: const IconThemeData(
      color: lightColor,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: lightColor),
      bodyMedium: TextStyle(color: lightColor),
      bodySmall: TextStyle(color: lightColor),
      titleLarge: TextStyle(color: lightColor),
      titleMedium: TextStyle(color: lightColor),
      titleSmall: TextStyle(color: lightColor),
      displayLarge: TextStyle(color: lightColor),
      displayMedium: TextStyle(color: lightColor),
      displaySmall: TextStyle(color: lightColor),
      labelLarge: TextStyle(color: lightColor),
      labelMedium: TextStyle(color: lightColor),
      labelSmall: TextStyle(color: lightColor),
    ),
  );

  static final lightTheme = ThemeData.light().copyWith(
    scaffoldBackgroundColor: lightBGColor,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: lightColor,
      modalBackgroundColor: lightColor,
    ),
    dialogBackgroundColor: lightBGColor,
    popupMenuTheme: const PopupMenuThemeData(
      color: lightColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(Colors.redAccent),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStateProperty.all(darkColor),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: lightColor,
      elevation: 2.0,
      titleTextStyle: TextStyle(
        color: darkColor,
        fontSize: 20.0,
        fontWeight: FontWeight.bold,
      ),
      iconTheme: IconThemeData(
        color: darkColor,
      ),
    ),
    iconTheme: const IconThemeData(
      color: darkColor,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: darkColor),
      bodyMedium: TextStyle(color: darkColor),
      bodySmall: TextStyle(color: darkColor),
      titleLarge: TextStyle(color: darkColor),
      titleMedium: TextStyle(color: darkColor),
      titleSmall: TextStyle(color: darkColor),
      displayLarge: TextStyle(color: darkColor),
      displayMedium: TextStyle(color: darkColor),
      displaySmall: TextStyle(color: darkColor),
      labelLarge: TextStyle(color: darkColor),
      labelMedium: TextStyle(color: darkColor),
      labelSmall: TextStyle(color: darkColor),
    ),
  );
}
