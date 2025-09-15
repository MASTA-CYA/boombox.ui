import 'package:flutter/material.dart';

class TextAdditionalInformationWidget extends StatelessWidget {
  final String text;

  const TextAdditionalInformationWidget({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(text);
  }
}
