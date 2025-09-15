import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:boombox/common/constants.dart';
import 'package:boombox/common/extensions.dart';
import 'package:boombox/common/helpers/theme_switch_helper.dart';
import 'package:boombox/common/navigator/page_navigator.dart';
import 'package:boombox/common/navigator/transition_direction_enum.dart';
import 'package:boombox/common/widgets/scrolling_text.dart';
import 'package:boombox/news-component/news_page.dart';
import 'package:boombox/news-component/services/news_service.dart';
import 'package:boombox/player-component/player_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:flutter/scheduler.dart';
// ignore: unnecessary_import
import 'package:flutter/services.dart';
import 'package:boombox/common/themes/themes.dart';
import 'package:provider/provider.dart';

class AppBarWidget<T> extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final Widget? actions;

  const AppBarWidget({
    super.key,
    required this.title,
    this.actions,
  });

  @override
  State<StatefulWidget> createState() => _AppBarWidget<T>();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppBarWidget<T> extends State<AppBarWidget<T>>
    with SingleTickerProviderStateMixin {
  static const double iconSpacing = 16;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: _buildBackButton(),
      title: _buildTitle(),
      elevation: 1,
      actions: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildThemeSwitcher(),
              if (!widget.title.equals('News')) ...{
                _buildNewsIcon(),
              },
              if (widget.title.equals('News')) ...{
                _buildPlayerIcon(),
              },
              // buildEqualizerIcon(),
              if (widget.actions != null) ...{
                const SizedBox(width: iconSpacing),
                widget.actions as Widget,
              }
            ],
          ),
        ),
      ],
    );
  }

  Widget? _buildBackButton() {
    return ModalRoute.of(context)!.impliesAppBarDismissal
        ? BackButton(
            onPressed: () => PageNavigator.navigateBack<T>(context),
          )
        : null;
  }

  Widget _buildTitle() {
    TextStyle? style = Theme.of(context)
        .textTheme
        .headlineLarge
        ?.merge(Theme.of(context).appBarTheme.titleTextStyle);

    bool isSmallDevice =
        MediaQuery.of(context).size.width < DeviceSize.SMALL_DEVICE_WIDTH;
    bool isLargeText = widget.title.length > 12;
    if (isSmallDevice || isLargeText) {
      return SizedBox(
        height: kToolbarHeight,
        child: Center(
          child: ScrollingTextWidget(
            text: widget.title,
            textStyle: style,
          ),
        ),
      );
    } else {
      return Center(
        child: Text(
          widget.title,
          style: style,
        ),
      );
    }
  }

  Widget _buildThemeSwitcher() {
    final ThemeData currentTheme;
    final IconData icon;
    final Brightness brightness;

    currentTheme = Theme.of(context).brightness == Brightness.dark
        ? AppThemes.lightTheme
        : AppThemes.darkTheme;
    icon = Theme.of(context).brightness == Brightness.dark
        ? CupertinoIcons.sun_max
        : CupertinoIcons.moon_stars;
    brightness = Theme.of(context).brightness == Brightness.dark
        ? Brightness.light
        : Brightness.dark;

    return ThemeSwitcher(
      builder: (context) {
        return GestureDetector(
          child: Icon(
            icon,
            size: 25,
          ),
          onTap: () async => ThemeSwitchHelper.switchApplicationThemeAsync(
            context,
            currentTheme,
            brightness,
          ),
        );
      },
    );
  }

  Widget _buildPlayerIcon() {
    return Row(
      children: [
        const SizedBox(width: iconSpacing),
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          child: const ImageIcon(
            ResizeImage(
              AssetImage('assets/images/playing-1.png'),
              width: 70,
              height: 70,
              allowUpscaling: false,
            ),
            // size: 22.3,
          ),
          onTap: () => _navigateTo(
            const PlayerPage(),
            direction: TransitionDirection.btt,
          ),
        ),
      ],
    );
  }

  Widget _buildNewsIcon() {
    return Consumer<NewsService>(
      builder: (context, service, child) => FutureBuilder(
        future: service.isNewsServiceActive(),
        builder: (context, snapshot) {
          if (snapshot.connectionState.equals(ConnectionState.done) &&
              snapshot.hasData) {
            if (snapshot.data!) {
              return Row(
                children: [
                  const SizedBox(width: iconSpacing),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    child: const Padding(
                      padding: EdgeInsets.only(top: 2.5),
                      child: ImageIcon(
                        ResizeImage(
                          AssetImage('assets/images/newspaper.png'),
                          width: 70,
                          height: 70,
                          allowUpscaling: false,
                        ),
                        size: 22.3,
                      ),
                    ),
                    onTap: () => _navigateTo<NewsPage>(const NewsPage()),
                  ),
                ],
              );
            } else {
              return child!;
            }
          } else {
            return child!;
          }
        },
      ),
      child: const SizedBox.shrink(),
    );
  }

  // Widget buildEqualizerIcon() {
  //   return GestureDetector(
  //     child: const ImageIcon(
  //       ResizeImage(
  //         AssetImage('assets/images/equalizer.png'),
  //         width: 70,
  //         height: 70,
  //         allowUpscaling: false,
  //       ),
  //       // size: 25,
  //     ),
  //     onTap: () => {},
  //   );
  // }

  void _navigateTo<W>(
    Widget widget, {
    TransitionDirection? direction,
  }) {
    PageNavigator.navigateTo<W>(
      context,
      widget,
      // shouldPop: true,
      useScheduler: false,
      direction: direction ?? TransitionDirection.ltr,
    );
  }
}
