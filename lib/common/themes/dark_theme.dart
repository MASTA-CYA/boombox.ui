import 'package:boombox/common/helpers/color_helper.dart';
import 'package:boombox/common/themes/themes_common.dart';
import 'package:flutter/material.dart';

class DarkThemes {
  static final ThemeData darkThemeDefault = ThemeData(
    useMaterial3: true,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    fontFamily: ThemesCommon.secondaryText,
    scaffoldBackgroundColor: ThemesCommon.darkScaffoldBackgroundColor,
    primaryColor: ThemesCommon.primaryColor,
    colorScheme: ColorScheme.dark(
      primary: ThemesCommon.primaryColor,
      onPrimary: ThemesCommon.lightTertiaryColor,
      secondary: ThemesCommon.secondaryColor,
      onSecondary: ThemesCommon.lightTertiaryColor,
    ),
    dividerColor: ThemesCommon.lightTertiaryColor,
    appBarTheme: AppBarTheme(
      backgroundColor: ThemesCommon.primaryColor,
      foregroundColor: ThemesCommon.darkTertiaryColor,
      titleTextStyle: const TextStyle(
        fontFamily: ThemesCommon.primaryText,
        fontWeight: FontWeight.bold,
        // fontSize: 26,
      ),
      toolbarTextStyle: const TextStyle(color: ThemesCommon.darkTertiaryColor,),
      iconTheme: const IconThemeData(color: ThemesCommon.darkTertiaryColor,),
      actionsIconTheme: const IconThemeData(color: ThemesCommon.darkTertiaryColor,),
    ),
    iconTheme: const IconThemeData(color: ThemesCommon.darkTertiaryColor,),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(30.0)),
      ),
      filled: true,
      fillColor: ThemesCommon.darkScaffoldBackgroundColor,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        surfaceTintColor: MaterialStateProperty.all<Color>(Colors.transparent),
        backgroundColor: MaterialStateProperty.all<Color>(ThemesCommon.primaryColor),
        foregroundColor: MaterialStateProperty.all<Color>(ThemesCommon.lightTertiaryColor),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      shape: const CircleBorder(),
      backgroundColor: ThemesCommon.primaryColor,
    ),
    cardTheme: CardTheme(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 1,
      shape: const RoundedRectangleBorder(),
      color: ColorHelper.darken(Colors.grey, 85),
      surfaceTintColor: Colors.transparent,
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: ThemesCommon.darkScaffoldBackgroundColor,
    ),
    snackBarTheme:
        const SnackBarThemeData(backgroundColor: ThemesCommon.lightScaffoldBackgroundColor,),
    sliderTheme: SliderThemeData(
      activeTrackColor: ThemesCommon.primaryColor,
      inactiveTrackColor: ThemesCommon.secondaryColor,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.all<Color>(ThemesCommon.darkTertiaryColor,),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: ThemesCommon.darkScaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(25.0),
        ),
      ),
    ),
    badgeTheme: BadgeThemeData(
      backgroundColor: ThemesCommon.primaryColor,
    ),
    textButtonTheme: const TextButtonThemeData(),
    dialogTheme: DialogTheme(
      backgroundColor: ThemesCommon.secondaryColor,
      surfaceTintColor: ThemesCommon.secondaryColor,
      shape: const BeveledRectangleBorder(),
    ),
    checkboxTheme: CheckboxThemeData(
      checkColor: ThemesCommon.buildCheckboxCheckColor(),
    ),
  );
}
