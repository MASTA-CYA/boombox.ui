import 'package:flutter/material.dart';

enum SnackbarType {
  information,
  alert,
  warning,
  error,
}

extension SnackbarTypeExtension on SnackbarType {
  Color getColor(Brightness brightness) {
    switch (this) {
      case SnackbarType.information:
        return brightness == Brightness.light ? Colors.black : Colors.white;
      case SnackbarType.alert:
        return Colors.blue;
      case SnackbarType.warning:
        return Colors.amber;
      case SnackbarType.error:
        return Colors.red;
      }
  }

  String getIcon() {
    String icon = '';

    switch (this) {
      case SnackbarType.information:
        icon = 'assets/images/information.png';
        break;
      case SnackbarType.alert:
        icon = 'assets/images/alert.png';
        break;
      case SnackbarType.warning:
        icon = 'assets/images/warning.png';
        break;
      case SnackbarType.error:
        icon = 'assets/images/error.png';
        break;
    }

    return icon;
  }
}
