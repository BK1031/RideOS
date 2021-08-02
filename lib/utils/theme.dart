import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

bool darkMode = false;

final mainColor = Color(0xFF2CB1FF);
final spotifyColor = Color(0xFF1db954);
final successColor = Color(0xFF58BA5B);
final warningColor = Color(0xFFF2C94C);
final errorColor = Color(0xFFEB5757);

// LIGHT THEME
const lightTextColor = Colors.black;
const lightBackgroundColor = Color(0xFFf9f9f9);
const lightCardColor = Colors.white;
const lightDividerColor = const Color(0xFFC9C9C9);

// DARK THEME
const darkTextColor = Colors.white;
// const darkBackgroundColor = const Color(0xFF212121);
// const darkCardColor = const Color(0xFF2C2C2C);
const darkBackgroundColor = const Color(0xFF000000);
const darkCardColor = const Color(0xFF1C1C1C);
const darkDividerColor = const Color(0xFF616161);

// CURRENT COLORs
var currTextColor = darkTextColor;
var currBackgroundColor = darkBackgroundColor;
var currCardColor = darkCardColor;
var currDividerColor = darkDividerColor;

ThemeData mainTheme = new ThemeData(
    accentColor: mainColor,
    primaryColor: mainColor,
    brightness: Brightness.dark,
    cardTheme: CardTheme(
      color: currCardColor,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    )
);