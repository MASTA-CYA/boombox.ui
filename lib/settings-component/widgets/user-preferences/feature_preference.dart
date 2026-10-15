import 'preferences_barrel.dart';

class FeaturePreferenceWidget extends StatelessWidget {
  const FeaturePreferenceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Provider.of<UserSettingsService>(context)
          .getCanShowApplicationFeaturesStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return FutureBuilder(
            future: Provider.of<UserSettingsService>(
              context,
              listen: false,
            ).getCanShowApplicationFeaturesAsync(),
            builder: (context, snapshot) => Column(
              children: [
                ListTileSwitchWidget(
                  key: UniqueKey(),
                  leading: const ImageIcon(
                    ResizeImage(
                      AssetImage('assets/images/carousel.png'),
                      width: 70,
                      height: 70,
                      allowUpscaling: false,
                    ),
                  ),
                  title: 'Application Features',
                  subtitle: 'Display features carousel instead '
                      'of the mini player',
                  isActive: snapshot.data ?? false,
                  onValueChanged: (canShow) async =>
                      await _onApplicationFeaturesChanged(context, canShow),
                ),
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
                    AssetImage('assets/images/carousel.png'),
                    width: 70,
                    height: 70,
                    allowUpscaling: false,
                  ),
                ),
                title: 'Application Features',
                subtitle: 'Display features carousel instead '
                    'of the mini player',
                isActive: snapshot.data ?? false,
                onValueChanged: (canShow) async =>
                    await _onApplicationFeaturesChanged(context, canShow),
              ),
            ],
          );
        }
      },
    );
  }

  Future<void> _onApplicationFeaturesChanged(
    BuildContext context,
    bool canShow,
  ) async {
    if (context.mounted) {
      await Provider.of<UserSettingsService>(
        context,
        listen: false,
      ).updateCanShowApplicationFeaturesAsync(canShow);
    }
  }
}
