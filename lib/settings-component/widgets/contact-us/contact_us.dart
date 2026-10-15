import 'package:flutter/material.dart';

class ContactUsWidget extends StatelessWidget {
  final void Function() onPressed;

  const ContactUsWidget({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const ImageIcon(
        ResizeImage(
          AssetImage('assets/images/contact.png'),
          width: 70,
          height: 70,
          allowUpscaling: false,
        ),
      ),
      title: const Text('Contact Us'),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: () => onPressed,
    );
  }
}
