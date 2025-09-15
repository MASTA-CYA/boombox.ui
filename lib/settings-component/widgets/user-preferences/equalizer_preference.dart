import 'preferences_barrel.dart';

class EqualizerPreferenceWidget extends StatelessWidget {
  const EqualizerPreferenceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream:
          Provider.of<UserSettingsService>(context).getUseSmartEqualizerStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return FutureBuilder(
            future: Provider.of<UserSettingsService>(
              context,
              listen: false,
            ).getUseSmartEqualizerAsync(),
            builder: (context, snapshot) => Column(
              children: [
                ListTileSwitchWidget(
                  key: UniqueKey(),
                  leading: const ImageIcon(
                    ResizeImage(
                      AssetImage('assets/images/equalizer-1.png'),
                      width: 70,
                      height: 70,
                      allowUpscaling: false,
                    ),
                  ),
                  title: 'Smart Equalizer',
                  subtitle: 'Activate equalizer '
                      'preset based on track genre',
                  isActive: snapshot.data ?? false,
                  onValueChanged: (canUse) async =>
                      await _onSmartEqualizerChanged(context, canUse),
                ),
                snapshot.data ?? false
                    ? AdditionalInformationWidget<
                        TextAdditionalInformationWidget>(
                        text: 'This feature uses an online '
                            'API to retrieve metadata',
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
                    AssetImage('assets/images/equalizer-1.png'),
                    width: 70,
                    height: 70,
                    allowUpscaling: false,
                  ),
                ),
                title: 'Smart Equalizer',
                subtitle: 'Automatically activate equalizer '
                    'preset based on track genre',
                isActive: snapshot.data ?? false,
                onValueChanged: (canUse) async =>
                    await _onSmartEqualizerChanged(context, canUse),
              ),
              snapshot.data ?? false
                  ? AdditionalInformationWidget<
                      TextAdditionalInformationWidget>(
                      text: 'This feature uses an online '
                          'API to retrieve metadata',
                    )
                  : const SizedBox.shrink(),
            ],
          );
        }
      },
    );
  }

  Future<void> _onSmartEqualizerChanged(
      BuildContext context, bool canUse) async {
    if (context.mounted) {
      await Provider.of<UserSettingsService>(
        context,
        listen: false,
      ).updateUseSmartEqualizerAsync(canUse);
    }
  }
}
