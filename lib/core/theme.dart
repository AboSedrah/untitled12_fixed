import 'package:flutter/material.dart';

final ThemeData appTheme = ThemeData(
  primarySwatch: Colors.orange,
  scaffoldBackgroundColor:
      Colors.grey[200],
  fontFamily: 'Amiri',
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.black87,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20,
      fontWeight: FontWeight.bold,
      fontFamily: 'Amiri',
    ),
    iconTheme: IconThemeData(
      color: Colors.white,
    ),
  ),
  cardTheme: CardThemeData(
    color: Colors.white,
    margin: EdgeInsets.symmetric(
      vertical: 8,
    ),
    shape: RoundedRectangleBorder(
      borderRadius:
          BorderRadius.circular(10),
    ),
  ),
);
