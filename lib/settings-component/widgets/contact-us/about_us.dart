import 'package:flutter/material.dart';

class AboutUsWidget extends StatelessWidget {
  final void Function() onPressed;

  const AboutUsWidget({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const ImageIcon(
        ResizeImage(
          AssetImage('assets/images/about.png'),
          width: 70,
          height: 70,
          allowUpscaling: false,
        ),
      ),
      title: const Text('About Us'),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: () async => onPressed
    );
  }
}
