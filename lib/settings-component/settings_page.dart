import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:boombox/commons_barrel.dart';
import 'package:boombox/settings-component/settings_barrel.dart';
import 'package:boombox/directory-component/directory_page.dart';
import 'package:boombox/equalizer-component/equalizer_page.dart';
import 'package:boombox/message-component/messages_page.dart';
import 'package:boombox/theme-component/theme_page.dart';

import 'package:provider/provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {
  final String _title = 'Settings';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        if (mounted) {
          await Provider.of<UserSettingsService>(
            context,
            listen: false,
          ).getUserSettingsAsync();
        }
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ThemeSwitchingArea(
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBarWidget<SettingsPage>(title: _title),
          drawer: null,
          body: PageBackgroundWidget(
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: Functions.horizontalScreenMargin(context),
                vertical: 10,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: _buildSettingsOptions(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsOptions() {
    return Column(
      children: [
        _buildApplicationHeader(),
        ..._buildMediaDirectories(),
        ..._buildEqualizer(),
        ..._buildMessages(),
        ..._buildThemes(),
        _buildUserPreferenceHeader(),
        ..._buildLyricsMode(),
        ..._buildEternalStorageMode(),
        ..._buildDownloadMediaMode(),
        ..._buildSmartEqualizerMode(),
        ..._buildNewsServiceMode(),
        ..._buildApplicationFeaturesMode(),
        ..._buildDrivingMode(),
        _buildAboutUsHeader(),
        ..._buildAboutUs(),
        ..._buildContactUs(),
      ],
    );
  }

  Widget _buildApplicationHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      color: Theme.of(context).brightness == Brightness.light
          ? ColorHelper.lighten(Theme.of(context).colorScheme.secondary, 70)
          : Theme.of(context).colorScheme.secondary.withOpacity(0.4),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(8, 4, 0, 4),
            child: Text(
              'Application',
              style: Theme.of(context).textTheme.titleMedium?.merge(
                    const TextStyle(fontFamily: FontFamily.PRIMARY),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildMediaDirectories() {
    return <Widget>[
      DirectorySettingsWidget(
        onSettingPressed: (widget) => _navigateTo<DirectoryPage>(widget),
      ),
      const DividerWidget(),
    ];
  }

  List<Widget> _buildEqualizer() {
    return <Widget>[
      EqualizerSettingsWidget(
        onSettingPressed: (widget) => _navigateTo<EqualizerPage>(widget),
      ),
      const DividerWidget(),
    ];
  }

  List<Widget> _buildMessages() {
    return <Widget>[
      MessagesSettingsWidget(
        onSettingPressed: (widget) => _navigateTo<MessagesPage>(widget),
      ),
      const DividerWidget(),
    ];
  }

  List<Widget> _buildThemes() {
    return <Widget>[
      ThemeSettingsWidget(
        onSettingPressed: (widget) => _navigateTo<ThemePage>(widget),
      ),
    ];
  }

  Widget _buildUserPreferenceHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 24, 0, 10),
      color: Theme.of(context).brightness == Brightness.light
          ? ColorHelper.lighten(Theme.of(context).colorScheme.secondary, 70)
          : Theme.of(context).colorScheme.secondary.withOpacity(0.4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.fromLTRB(8, 4, 0, 4),
              child: Text(
                'Preferences',
                style: Theme.of(context).textTheme.titleMedium?.merge(
                      const TextStyle(fontFamily: FontFamily.PRIMARY),
                    ),
              ),
            ),
          ),
          const Expanded(
            child: OnlineCapabilityWidget(),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildLyricsMode() {
    return <Widget>[
      const LyricsPreferenceWidget(),
      const DividerWidget(),
    ];
  }

  List<Widget> _buildEternalStorageMode() {
    return <Widget>[
      const StoragePreferenceWidget(),
      const DividerWidget(),
    ];
  }

  List<Widget> _buildDownloadMediaMode() {
    return <Widget>[
      const MediaPreferenceWidget(),
      const DividerWidget(),
    ];
  }

  List<Widget> _buildSmartEqualizerMode() {
    return <Widget>[
      const EqualizerPreferenceWidget(),
      const DividerWidget(),
    ];
  }

  List<Widget> _buildNewsServiceMode() {
    return <Widget>[
      const NewsPreferenceWidget(),
      const DividerWidget(),
    ];
  }

  List<Widget> _buildApplicationFeaturesMode() {
    return <Widget>[
      const FeaturePreferenceWidget(),
      const DividerWidget(),
    ];
  }

  List<Widget> _buildDrivingMode() {
    return <Widget>[
      const DrivingPreferenceWidget(),
    ];
  }

  Widget _buildAboutUsHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
      color: Theme.of(context).brightness == Brightness.light
          ? ColorHelper.lighten(Theme.of(context).colorScheme.secondary, 70)
          : Theme.of(context).colorScheme.secondary.withOpacity(0.4),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(8, 4, 0, 4),
            child: Text(
              'Boombox',
              style: Theme.of(context).textTheme.titleMedium?.merge(
                    const TextStyle(fontFamily: FontFamily.PRIMARY),
                  ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAboutUs() {
    return <Widget>[
      AboutUsWidget(
        onPressed: () async => await showDialog(
          context: context,
          builder: (context) => AboutDialog(
            applicationIcon: Image.asset(
              'assets/images/launcher.png',
              width: 40,
              height: 40,
            ),
            applicationVersion: '1.0.0',
            children: const [
              Text(
                'A lightweight music player '
                'with minimal online capabilities.',
              ),
              SizedBox(height: 10),
              Text('© 2023 Boombox Music. All rights reserved.'),
            ],
          ),
        ),
      ),
      const DividerWidget(),
    ];
  }

  List<Widget> _buildContactUs() {
    return <Widget>[
      ContactUsWidget(
        onPressed: () => {},
      ),
    ];
  }

  void _navigateTo<T>(Widget widget) {
    PageNavigator.navigateTo<T>(context, widget);
  }
}
