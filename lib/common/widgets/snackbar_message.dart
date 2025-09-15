import 'package:boombox/common/constants.dart';
import 'package:boombox/common/helpers/enums/snackbar_type_enum.dart';
import 'package:flutter/material.dart';

class SnackbarMessageWidget extends StatelessWidget {
  final SnackbarType type;
  final String message;

  const SnackbarMessageWidget({
    super.key,
    required this.type,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ImageIcon(
          ResizeImage(
            AssetImage(type.getIcon()),
            width: 70,
            height: 70,
            allowUpscaling: false,
          ),
          color: type == SnackbarType.information &&
                  Theme.of(context).brightness == Brightness.dark
              ? Colors.black
              : Colors.white,
        ),
        const SizedBox(width: 18),
        Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.merge(
                TextStyle(
                  fontFamily: FontFamily.PRIMARY,
                  color: type == SnackbarType.information &&
                          Theme.of(context).brightness == Brightness.dark
                      ? Colors.black
                      : Colors.white,
                ),
              ),
        ),
      ],
    );
  }
}
