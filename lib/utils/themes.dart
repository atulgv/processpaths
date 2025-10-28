import 'package:flutter/material.dart';

TextTheme robotoTextTheme(BuildContext context) =>
    Theme.of(context).textTheme.apply(fontFamily: 'Roboto');

/// Light theme configuration
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
  useMaterial3: true,
);

/// Dark theme configuration
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.deepPurple,
    brightness: Brightness.dark,
  ),
  useMaterial3: true,
);
