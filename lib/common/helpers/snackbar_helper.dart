import 'package:boombox/common/helpers/enums/snackbar_duration_enum.dart';
import 'package:boombox/common/helpers/enums/snackbar_type_enum.dart';
import 'package:boombox/common/widgets/provider_result.dart';
import 'package:boombox/common/widgets/snackbar_message.dart';
import 'package:flutter/material.dart';

class SnackbarHelper {
  static Future<void> showMessage(
    BuildContext context,
    SnackbarType type,
    String message, {
    SnackbarDuration? duration,
    SnackBarAction? action,
  }) async {
    if (!context.mounted || message.isEmpty) {
      return;
    }

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: duration?.duration ?? const Duration(milliseconds: 4000),
        content: SnackbarMessageWidget(type: type, message: message),
        action: action,
      ),
    );
  }

  static void showProviderResult(
    BuildContext context,
    bool result, {
    String message = '',
    SnackBarAction? action,
  }) {
    if (!context.mounted) {
      return;
    }

    if (message.isEmpty) {
      message = result ? 'Action Successful' : 'Action Failed';
    }

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: result ? Colors.green : Colors.red,
        content: ProviderResultWidget(result: result, message: message),
        action: action,
      ),
    );
  }
}
