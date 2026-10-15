import 'package:boombox/settings-component/models/enums/storage_source_enum.dart';
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
            builder: (context, snapshot) =>
                _buildContent(context, snapshot.data ?? false),
          );
        } else {
          return _buildContent(context, snapshot.data ?? false);
        }
      },
    );
  }

  Widget _buildContent(BuildContext context, bool isActive) {
    return Column(
      children: [
        ListTileSwitchWidget(
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
          isActive: isActive,
          onValueChanged: (isActive) async =>
              await _onEternalStorageChanged(context, isActive),
        ),
        if (isActive) _buildStorageSourcePicker(context),
      ],
    );
  }

  Widget _buildStorageSourcePicker(BuildContext context) {
    return StreamBuilder(
      stream: Provider.of<UserSettingsService>(context).getStorageSourceStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return FutureBuilder(
            future: Provider.of<UserSettingsService>(
              context,
              listen: false,
            ).getStorageSourceAsync(),
            builder: (context, snapshot) => _buildStorageSourceDropdown(
              context,
              snapshot.data ?? StorageSource.automatic,
            ),
          );
        } else {
          return _buildStorageSourceDropdown(
            context,
            snapshot.data ?? StorageSource.automatic,
          );
        }
      },
    );
  }

  Widget _buildStorageSourceDropdown(
    BuildContext context,
    StorageSource selected,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: DropdownButtonFormField<StorageSource>(
        isDense: true,
        isExpanded: true,
        icon: const Icon(Icons.keyboard_arrow_down),
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
          labelText: 'Storage Location',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(1),
          ),
        ),
        items: StorageSource.values
            .map(
              (source) => DropdownMenuItem<StorageSource>(
                value: source,
                child: Text(source.displayName),
              ),
            )
            .toList(),
        value: selected,
        onChanged: (source) async =>
            await _onStorageSourceChanged(context, source),
      ),
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

  Future<void> _onStorageSourceChanged(
    BuildContext context,
    StorageSource? source,
  ) async {
    if (source == null || !context.mounted) return;

    await Provider.of<UserSettingsService>(
      context,
      listen: false,
    ).updateStorageSourceAsync(source);
  }
}
