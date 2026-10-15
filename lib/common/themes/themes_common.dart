import 'package:boombox/common/constants.dart';
import 'package:boombox/common/helpers/color_helper.dart';
import 'package:flutter/material.dart';

class ThemesCommon {
  // Color Scheme
  static final primaryColor = ColorHelper.lighten(
    ColorHelper.fromHex('#710193'),
  );
  static final secondaryColor = ColorHelper.fromHex('#505050');
  static const lightTertiaryColor = Colors.black;
  static const darkTertiaryColor = Colors.white;
  static const lightScaffoldBackgroundColor = Colors.white;
  static const darkScaffoldBackgroundColor = Colors.black;

  // Text
  static const primaryText = FontFamily.PRIMARY;
  static const secondaryText = FontFamily.SECONDARY;

  // Methods
  static MaterialStateProperty<Color?> buildCheckboxCheckColor() {
    return MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) =>
          // Thumb icon when the switch is selected.
          ThemesCommon.darkTertiaryColor,
    );
  }

  static MaterialStateProperty<Color?> buildSwitchThumbColor() {
    return MaterialStateProperty.resolveWith<Color?>(
      (Set<MaterialState> states) {
        // Thumb icon when the switch is selected.
        if (states.contains(MaterialState.selected)) {
          return ThemesCommon.darkTertiaryColor;
        }
        return ThemesCommon.lightTertiaryColor;
      },
    );
  }
}
