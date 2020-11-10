import 'package:flutter/material.dart';

class Themes {
  static ThemeData light = ThemeData(
    fontFamily: 'Lato',
    brightness: Brightness.light,
    accentColor: const Color(0xff2150c4),
    primaryColor: const Color(0xff2150c4),
  );
  static ThemeData dark = ThemeData(
    fontFamily: 'Lato',
    brightness: Brightness.dark,
    accentColor: const Color(0xff8349eb),
    primaryColor: const Color(0xff8349eb),
    backgroundColor: const Color(0xff130528),
    cardColor: const Color(0xff424242),
  );
}
