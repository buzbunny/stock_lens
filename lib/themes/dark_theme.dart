import 'package:flutter/material.dart';

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
  ),
  colorScheme: ColorScheme.dark(
    brightness: Brightness.dark,
    background: Colors.black,
    primary: Colors.grey[900]!,
    secondary: Colors.grey[850]!,

  )
);