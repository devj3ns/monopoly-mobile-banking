import 'package:flutter/material.dart';

final borderRadius = BorderRadius.circular(7);

final _buttonShape = MaterialStateProperty.all<RoundedRectangleBorder>(
    RoundedRectangleBorder(borderRadius: borderRadius));
final _cardShape = RoundedRectangleBorder(borderRadius: borderRadius);

const _lightPrimaryColor = Colors.blueAccent;
const _lightSecondaryColor = Color(0xff4e82bf);
const _lightScaffoldColor = Color(0xffebf0f7);

final lightTheme = ThemeData(
  brightness: Brightness.light,

  /// #### Colors: ####
  primaryColor: _lightPrimaryColor,
  toggleableActiveColor: _lightPrimaryColor,
  scaffoldBackgroundColor: _lightScaffoldColor,
  dialogBackgroundColor: Colors.white,
  cardColor: Colors.white,
  appBarTheme: const AppBarTheme(backgroundColor: _lightPrimaryColor),

  /// #### Dialog & Card shape: ####
  dialogTheme: DialogTheme(
    shape: _cardShape,
  ),
  cardTheme: CardTheme(
    shape: _cardShape,
  ),

  /// #### Text Theme: ####
  textTheme: const TextTheme(
    bodyText2: TextStyle(fontSize: 16),
  ),

  /// #### Buttons: ####
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(_lightSecondaryColor),
      shape: _buttonShape,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      shape: _buttonShape,
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      shape: _buttonShape,
    ),
  ),
);

const _darkPrimaryColor = Color(0xff4e82bf);
const _darkSecondaryColor = Color(0xff324b69);
const _darkScaffoldColor = Color(0xff1e2c3d);

final darkTheme = ThemeData(
  brightness: Brightness.dark,

  /// #### Colors: ####
  primaryColor: _darkPrimaryColor,
  accentColor: _darkPrimaryColor,
  toggleableActiveColor: _darkPrimaryColor,
  scaffoldBackgroundColor: _darkScaffoldColor,
  dialogBackgroundColor: _darkSecondaryColor,
  cardColor: _darkSecondaryColor,
  appBarTheme: const AppBarTheme(backgroundColor: _darkPrimaryColor),

  /// #### Dialog & Card shape: ####
  dialogTheme: DialogTheme(
    shape: _cardShape,
  ),
  cardTheme: CardTheme(
    shape: _cardShape,
  ),

  /// #### Text Theme: ####
  textTheme: const TextTheme(
    bodyText2: TextStyle(fontSize: 16),
  ),

  /// #### Buttons: ####
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(_darkPrimaryColor),
      shape: _buttonShape,
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      shape: _buttonShape,
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      shape: _buttonShape,
    ),
  ),
);
