import 'package:permission_handler/permission_handler.dart';

import 'preferences_barrel.dart';

class StoragePreferenceWidget extends StatelessWidget {
  const StoragePreferenceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream:
          Provider.of<UserSettingsService>(context).getUseEternalStorageStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return FutureBuilder(
            future: Provider.of<UserSettingsService>(
              context,
              listen: false,
            ).getUseEternalStorageAsync(),
            builder: (context, snapshot) => ListTileSwitchWidget(
              key: UniqueKey(),
              leading: const ImageIcon(
                ResizeImage(
                  AssetImage('assets/images/eternal.png'),
                  width: 70,
                  height: 70,
                  allowUpscaling: false,
                ),
              ),
              title: 'Eternal Storage',
              subtitle: 'Retain app data after uninstall',
              isActive: snapshot.data ?? false,
              onValueChanged: (isActive) async =>
                  await _onEternalStorageChanged(context, isActive),
            ),
          );
        } else {
          return ListTileSwitchWidget(
            key: UniqueKey(),
            leading: const ImageIcon(
              ResizeImage(
                AssetImage('assets/images/eternal.png'),
                width: 70,
                height: 70,
                allowUpscaling: false,
              ),
            ),
            title: 'Eternal Storage',
            subtitle: 'Retain app data after uninstall',
            isActive: snapshot.data ?? false,
            onValueChanged: (isActive) async =>
                await _onEternalStorageChanged(context, isActive),
          );
        }
      },
    );
  }

  Future<void> _onEternalStorageChanged(
      BuildContext context, bool isActive) async {
    if (!await Permission.storage.isGranted) {
      await Permission.storage.request();
    }

    if (await Permission.storage.isGranted) {
      if (context.mounted) {
        await Provider.of<UserSettingsService>(
          context,
          listen: false,
        ).updateUseEternalStorageAsync(isActive);
      }
    }
  }
}
