import 'package:boombox/directory-component/directory_page.dart';
import 'package:flutter/material.dart';

class DirectorySettingsWidget extends StatelessWidget {
  final void Function(Widget widget) onSettingPressed;

  const DirectorySettingsWidget({
    super.key,
    required this.onSettingPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const ImageIcon(
        ResizeImage(
          AssetImage('assets/images/folder.png'),
          width: 70,
          height: 70,
          allowUpscaling: false,
        ),
      ),
      title: const Text('Media Directories'),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: () => onSettingPressed(const DirectoryPage())
    );
  }
}
