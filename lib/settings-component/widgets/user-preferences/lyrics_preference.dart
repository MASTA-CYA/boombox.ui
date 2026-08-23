import 'preferences_barrel.dart';

class LyricsPreferenceWidget extends StatelessWidget {
  const LyricsPreferenceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Provider.of<UserSettingsService>(context)
          .getCanSaveLyricsLocallyStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return FutureBuilder(
            future: Provider.of<UserSettingsService>(
              context,
              listen: false,
            ).getCanSaveLyricsLocallyAsync(),
            builder: (context, snapshot) => Column(
              children: [
                ListTileSwitchWidget(
                  key: UniqueKey(),
                  leading: const ImageIcon(
                    ResizeImage(
                      AssetImage('assets/images/lyrics.png'),
                      width: 70,
                      height: 70,
                      allowUpscaling: false,
                    ),
                  ),
                  title: 'Lyrics',
                  subtitle: 'Save lyrics locally',
                  isActive: snapshot.data ?? false,
                  onValueChanged: (isActive) => _onSaveLyricsChanged(
                    context,
                    isActive,
                  ),
                ),
                snapshot.data ?? false
                    ? AdditionalInformationWidget<
                        TextAdditionalInformationWidget>(
                        text: 'This feature scrapes the '
                            'Genius website for lyrics',
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
                    AssetImage('assets/images/lyrics.png'),
                    width: 70,
                    height: 70,
                    allowUpscaling: false,
                  ),
                ),
                title: 'Lyrics',
                subtitle: 'Save lyrics locally',
                isActive: snapshot.data ?? false,
                onValueChanged: (isActive) => _onSaveLyricsChanged(
                  context,
                  isActive,
                ),
              ),
              snapshot.data ?? false
                  ? AdditionalInformationWidget<
                      TextAdditionalInformationWidget>(
                      text: 'This feature scraps the '
                          'Genius website for lyrics',
                    )
                  : const SizedBox.shrink(),
            ],
          );
        }
      },
    );
  }

  Future<void> _onSaveLyricsChanged(BuildContext context, bool isActive) async {
    await Provider.of<UserSettingsService>(
      context,
      listen: false,
    ).updateCanSaveLyricsLocallyAsync(isActive);
  }
}
