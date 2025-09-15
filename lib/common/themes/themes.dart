import 'package:boombox/common/themes/dark_theme.dart';
import 'package:boombox/common/themes/light_theme.dart';
import 'package:flutter/material.dart';


class AppThemes {
  // Default Themes
  static ThemeData get lightTheme => LightThemes.lightThemeDefault;
  static ThemeData get darkTheme => DarkThemes.darkThemeDefault;
}
