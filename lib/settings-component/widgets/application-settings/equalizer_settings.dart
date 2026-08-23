import 'package:boombox/equalizer-component/equalizer_page.dart';
import 'package:flutter/material.dart';

class EqualizerSettingsWidget extends StatelessWidget {
  final void Function(Widget widget) onSettingPressed;

  const EqualizerSettingsWidget({
    super.key,
    required this.onSettingPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const ImageIcon(
        ResizeImage(
          AssetImage('assets/images/equalizer.png'),
          width: 70,
          height: 70,
          allowUpscaling: false,
        ),
      ),
      title: const Text('Equalizer'),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: () => onSettingPressed(const EqualizerPage()),
    );
  }
}
