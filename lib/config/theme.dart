import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Color ACTIVE_ACCENT_COLOR = const Color(0xFF003660);

Color ERROR_COLOR = const Color(0xFFf33535);
Color WARNING_COLOR = const Color(0xFFffca28);
Color SUCCESS_COLOR = const Color(0xFF00ca70);

// LIGHT THEME
const lightTextColor = Color(0xFF000000);
const lightBackgroundColor = Color(0xFFf9f9f9);
const lightCardColor = Color(0xFFFFFFFF);
const lightDividerColor = Color(0xFFA8A8A8);

// DARK THEME
const darkTextColor = Color(0xFFE9E9E9);
const darkBackgroundColor = Color(0xFF000000);
const darkCardColor = Color(0xFF0D0D0D);
const darkDividerColor = Color(0xFF545454);

// CARD LOADING
CardLoadingTheme getCardLoadingTheme(context) => CardLoadingTheme(
  colorOne: Theme.of(context).brightness == Brightness.light ? Colors.grey[200]! : Colors.grey[900]!,
  colorTwo: Theme.of(context).brightness == Brightness.light ? Colors.grey[300]! : darkCardColor.withAlpha(100),
);

/// LIGHT STYLE
// final ThemeData lightTheme = ThemeData(
//   brightness: Brightness.light,
//   colorScheme: const ColorScheme.light().copyWith(
//     primary: ACTIVE_ACCENT_COLOR,
//     secondary: ACTIVE_ACCENT_COLOR,
//     onPrimary: Colors.white,
//     onSecondary: Colors.white,
//     surface: Colors.transparent,
//     surfaceTint: Colors.transparent,
//     onSurface: lightBackgroundColor
//   ),
//   fontFamily: "Product Sans",
//   primaryColor: ACTIVE_ACCENT_COLOR,
//   scaffoldBackgroundColor: lightBackgroundColor,
//   cardColor: lightCardColor,
//   appBarTheme: AppBarTheme(
//     foregroundColor: Colors.white,
//     color: ACTIVE_ACCENT_COLOR,
//     centerTitle: true,
//     systemOverlayStyle: SystemUiOverlayStyle.light,
//   ),
//   cardTheme: CardTheme(
//     color: lightCardColor,
//     elevation: 0,
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//   ),
//   listTileTheme: ListTileThemeData(
//     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//   ),
//   buttonTheme: ButtonThemeData(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
//   ),
//   floatingActionButtonTheme: FloatingActionButtonThemeData(
//     backgroundColor: ACTIVE_ACCENT_COLOR,
//     foregroundColor: Colors.white,
//   ),
//   dividerColor: lightDividerColor,
//   dialogBackgroundColor: lightCardColor,
//   popupMenuTheme: PopupMenuThemeData(
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(8),
//     ),
//   ),
// );

/// DARK STYLE
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark().copyWith(
      primary: ACTIVE_ACCENT_COLOR,
      secondary: ACTIVE_ACCENT_COLOR,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    surface: Colors.transparent,
    surfaceTint: Colors.transparent,
    onSurface: darkBackgroundColor
  ),
  fontFamily: "Product Sans",
  primaryColor: ACTIVE_ACCENT_COLOR,
  scaffoldBackgroundColor: darkBackgroundColor,
  iconTheme: const IconThemeData(color: Colors.grey),
  cardColor: darkCardColor,
  appBarTheme: const AppBarTheme(
    foregroundColor: Colors.white,
    color: darkCardColor,
    centerTitle: true,
    systemOverlayStyle: SystemUiOverlayStyle.light,
  ),
  cardTheme: CardTheme(
    color: darkCardColor.withOpacity(0.8),
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      // side: BorderSide(color: Colors.grey)
    ),
  ),
  listTileTheme: ListTileThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    iconColor: Colors.grey,
  ),
  buttonTheme: ButtonThemeData(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: ACTIVE_ACCENT_COLOR,
    foregroundColor: Colors.white,
  ),
  dividerColor: darkDividerColor,
  dialogBackgroundColor: darkCardColor,
  popupMenuTheme: PopupMenuThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(6),
    ),
  ),
);