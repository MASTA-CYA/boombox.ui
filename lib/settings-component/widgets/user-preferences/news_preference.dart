import 'package:boombox/settings-component/widgets/additional-information/news_additional_information.dart';

import 'preferences_barrel.dart';

class NewsPreferenceWidget extends StatelessWidget {
  const NewsPreferenceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Provider.of<UserSettingsService>(context).getCanFetchNewsStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return FutureBuilder(
            future: Provider.of<UserSettingsService>(
              context,
              listen: false,
            ).getCanFetchNewsAsync(),
            builder: (context, snapshot) => Column(
              children: [
                ListTileSwitchWidget(
                  key: UniqueKey(),
                  leading: const ImageIcon(
                    ResizeImage(
                      AssetImage('assets/images/newspaper-2.png'),
                      width: 70,
                      height: 70,
                      allowUpscaling: false,
                    ),
                  ),
                  title: 'News Service',
                  subtitle: 'Fetch latest music-related news '
                      'bulletins from the web',
                  isActive: snapshot.data ?? false,
                  onValueChanged: (canFetch) async =>
                      await _onFetchNewsChanged(context, canFetch),
                ),
                snapshot.data ?? false
                    ? AdditionalInformationWidget<
                        NewsAdditionalInformationWidget>(
                        text: 'Select your preferred news sources',
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
                    AssetImage('assets/images/newspaper-2.png'),
                    width: 70,
                    height: 70,
                    allowUpscaling: false,
                  ),
                ),
                title: 'News Service',
                subtitle: 'Fetch latest music-related news '
                      'bulletins from the web',
                isActive: snapshot.data ?? false,
                onValueChanged: (canFetch) async =>
                    await _onFetchNewsChanged(context, canFetch),
              ),
              snapshot.data ?? false
                  ? AdditionalInformationWidget<
                      NewsAdditionalInformationWidget>(
                      text: 'Selected your preferred news sources',
                    )
                  : const SizedBox.shrink(),
            ],
          );
        }
      },
    );
  }

  Future<void> _onFetchNewsChanged(BuildContext context, bool canFetch) async {
    if (context.mounted) {
      await Provider.of<UserSettingsService>(
        context,
        listen: false,
      ).updateCanFetchNewsAsync(canFetch);
    }
  }
}
