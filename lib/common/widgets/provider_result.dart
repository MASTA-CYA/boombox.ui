import 'package:boombox/common/constants.dart';
import 'package:flutter/material.dart';

class ProviderResultWidget extends StatelessWidget {
  final bool result;
  final String message;

  const ProviderResultWidget({
    super.key,
    required this.result,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ImageIcon(
          ResizeImage(
            AssetImage(result
                ? 'assets/images/check-circle.png'
                : 'assets/images/close-circle.png'),
            width: 70,
            height: 70,
            allowUpscaling: false,
          ),
          color: Colors.white,
        ),
        const SizedBox(width: 18),
        Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.merge(
                const TextStyle(
                  fontFamily: FontFamily.PRIMARY,
                  color: Colors.white,
                ),
              ),
        ),
      ],
    );
  }
}
