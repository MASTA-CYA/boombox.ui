import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:boombox/common/extensions.dart';
import 'package:boombox/common/functions.dart';
import 'package:boombox/common/widgets/appbar.dart';
import 'package:boombox/common/widgets/circular_progress_indicator.dart';
import 'package:boombox/common/widgets/separator_header.dart';
import 'package:boombox/settings-component/services/user_settings_service.dart';
import 'package:boombox/theme-component/models/user_theme_model.dart';
import 'package:boombox/theme-component/services/theme_service.dart';
import 'package:boombox/theme-component/widgets/theme_image_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemePage extends StatefulWidget {
  const ThemePage({super.key});

  @override
  State<StatefulWidget> createState() => _ThemePage();
}

class _ThemePage extends State<ThemePage> {
  final String _title = 'Themes';

  final ValueNotifier<bool> _isDefaultExpanded = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _isCustomExpanded = ValueNotifier<bool>(true);
  final ValueNotifier<bool> _isDefaultThemeActive = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _isCustomThemeActive = ValueNotifier<bool>(false);
  UserTheme? _activeTheme;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        _activeTheme = await Provider.of<UserSettingsService>(
          context,
          listen: false,
        ).getActiveThemeAsync();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ThemeSwitchingArea(
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBarWidget<ThemePage>(title: _title),
          drawer: null,
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: Functions.horizontalScreenMargin(context),
                vertical: 10,
              ),
              child: _buildThemeOptions(),
            ),
          ),
          floatingActionButton: FloatingActionButton(
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
              onPressed: () {}),
        ),
      ),
    );
  }

  Widget _buildThemeOptions() {
    return Column(
      children: [
        _buildDefaultThemesHeader(),
        _buildDefaultThemes(),
        _buildCustomThemesHeader(),
        _buildCustomThemes(),
      ],
    );
  }

  Widget _buildDefaultThemesHeader() {
    return SeparatorHeaderWidget(
      title: 'Default',
      isExpandable: true,
      onExpanded: (title, isExpanded) => _onSectionExpanded(title, isExpanded),
    );
  }

  Widget _buildDefaultThemes() {
    return FutureBuilder(
      future: Provider.of<ThemeService>(context).getDefaultThemesAsync(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final List<UserTheme> themes = snapshot.data!;
          return ValueListenableBuilder(
            valueListenable: _isDefaultExpanded,
            builder: (context, isExpanded, child) => isExpanded
                ? Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ValueListenableBuilder(
                      valueListenable: _isDefaultThemeActive,
                      builder: (context, isCustom, child) => StatefulBuilder(
                        builder: (context, setState) => ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: themes.length,
                          itemBuilder: (context, index) => ThemeImageCardWidget(
                            isActive: themes.elementAt(index).name.equals(
                                  _activeTheme?.name ?? '',
                                ),
                            theme: themes.elementAt(index),
                            onThemeChanged: (color, isInverted) async {
                              await _onThemeChanged(
                                themes.elementAt(index),
                                color,
                                isInverted,
                              );
                              setState(() => _isCustomThemeActive.value =
                                  !_isCustomThemeActive.value);
                            },
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          );
        } else {
          return const CircularProgressIndicatorWidget();
        }
      },
    );
  }

  Widget _buildCustomThemesHeader() {
    return SeparatorHeaderWidget(
      title: 'Custom',
      isExpandable: true,
      onExpanded: (title, isExpanded) => _onSectionExpanded(title, isExpanded),
    );
  }

  Widget _buildCustomThemes() {
    return FutureBuilder(
      future: Provider.of<ThemeService>(context).getCustomThemesAsync(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final List<UserTheme> themes = snapshot.data!;
          return ValueListenableBuilder(
            valueListenable: _isCustomExpanded,
            builder: (context, isExpanded, child) => isExpanded
                ? Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ValueListenableBuilder(
                      valueListenable: _isCustomThemeActive,
                      builder: (context, isCustom, child) => StatefulBuilder(
                        builder: (context, setState) => ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: themes.length,
                          itemBuilder: (context, index) => ThemeImageCardWidget(
                            isActive: themes.elementAt(index).name.equals(
                                  _activeTheme?.name ?? '',
                                ),
                            theme: themes.elementAt(index),
                            onThemeChanged: (color, isInverted) async {
                              await _onThemeChanged(
                                themes.elementAt(index),
                                color,
                                isInverted,
                              );
                              setState(() => _isDefaultThemeActive.value =
                                  !_isDefaultThemeActive.value);
                            },
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          );
        } else {
          return const CircularProgressIndicatorWidget();
        }
      },
    );
  }

  Future<void> _onThemeChanged(
    UserTheme theme,
    Color color,
    bool isInverted,
  ) async {
    if (!theme.name.equals(_activeTheme!.name)) _activeTheme = theme;
    if (_activeTheme!.isCustom!) {
      _activeTheme!.color = color;
      _activeTheme!.invertColors = isInverted;
    }
    await Provider.of<UserSettingsService>(
      context,
      listen: false,
    ).updateActiveThemeAsync(_activeTheme!);
  }

  void _onSectionExpanded(String title, bool isExpanded) {
    switch (title) {
      case 'Default':
        _isDefaultExpanded.value = isExpanded;
        break;
      case 'Custom':
        _isCustomExpanded.value = isExpanded;
        break;
      default:
        break;
    }
  }
}
