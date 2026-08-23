import 'package:boombox/theme-component/theme_page.dart';
import 'package:flutter/material.dart';

class ThemeSettingsWidget extends StatelessWidget {
  final void Function(Widget widget) onSettingPressed;

  const ThemeSettingsWidget({
    super.key,
    required this.onSettingPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const ImageIcon(
        ResizeImage(
          AssetImage('assets/images/theme.png'),
          width: 70,
          height: 70,
          allowUpscaling: false,
        ),
      ),
      title: const Text('Themes'),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: () => onSettingPressed(const ThemePage()),
    );
  }
}
