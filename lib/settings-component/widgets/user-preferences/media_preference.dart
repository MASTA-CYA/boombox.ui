import 'preferences_barrel.dart';

class MediaPreferenceWidget extends StatelessWidget {
  const MediaPreferenceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Provider.of<UserSettingsService>(context)
          .getCanDownloadArtistMediaStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return FutureBuilder(
            future: Provider.of<UserSettingsService>(
              context,
              listen: false,
            ).getCanDownloadArtistMediaAsync(),
            builder: (context, snapshot) => Column(
              children: [
                ListTileSwitchWidget(
                  key: UniqueKey(),
                  leading: const ImageIcon(
                    ResizeImage(
                      AssetImage('assets/images/download.png'),
                      width: 70,
                      height: 70,
                      allowUpscaling: false,
                    ),
                  ),
                  title: 'Download Media',
                  subtitle: 'Download missing media and meta data',
                  isActive: snapshot.data ?? false,
                  onValueChanged: (isActive) async =>
                      await _onDownloadMediaChanged(context, isActive),
                ),
                snapshot.data ?? false
                    ? AdditionalInformationWidget<
                        TextAdditionalInformationWidget>(
                        text: 'This feature uses the Google '
                            'Search Engine to search for missing media',
                      )
                    : const SizedBox.shrink(),
              ],
            ),
          );
        } else {
          return Column(
            children: [
              ListTileSwitchWidget(
                key: UniqueKey(),
                leading: const ImageIcon(
                  ResizeImage(
                    AssetImage('assets/images/download.png'),
                    width: 70,
                    height: 70,
                    allowUpscaling: false,
                  ),
                ),
                title: 'Download Media',
                subtitle: 'Download missing artist media',
                isActive: snapshot.data ?? false,
                onValueChanged: (isActive) async =>
                    await _onDownloadMediaChanged(context, isActive),
              ),
              snapshot.data ?? false
                  ? AdditionalInformationWidget<
                      TextAdditionalInformationWidget>(
                      text: 'This feature uses the Google '
                          'Search Engine to search for missing media',
                    )
                  : const SizedBox.shrink(),
            ],
          );
        }
      },
    );
  }

  Future<void> _onDownloadMediaChanged(
      BuildContext context, bool canDownload) async {
    if (context.mounted) {
      await Provider.of<UserSettingsService>(
        context,
        listen: false,
      ).updateCanDownloadArtistMediaAsync(canDownload);
    }
  }
}
