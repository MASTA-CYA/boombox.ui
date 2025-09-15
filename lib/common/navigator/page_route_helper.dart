import 'package:boombox/common/extensions.dart';
import 'package:boombox/common/navigator/named_page_route_model.dart';
import 'package:boombox/common/navigator/transition_direction_enum.dart';
import 'package:boombox/common/navigator/unknown_route.dart';
import 'package:boombox/directory-component/directory_page.dart';
import 'package:boombox/equalizer-component/equalizer_page.dart';
import 'package:boombox/library-component/library_page.dart';
import 'package:boombox/message-component/messages_page.dart';
import 'package:boombox/music-component/music_barrel.dart';
import 'package:boombox/music-component/music_page.dart';
import 'package:boombox/news-component/news_page.dart';
import 'package:boombox/playlist-component/playlist_page.dart';
import 'package:boombox/recently-played-component/recently_played_page.dart';
import 'package:boombox/settings-component/settings_page.dart';
import 'package:boombox/theme-component/theme_page.dart';

class PageRouteHelper {
  static String getInitialRouteName() {
    return _getPageRoutes().first.name;
  }

  static Widget getInitialRouteWidget() {
    return _getPageRoutes().first.widget;
  }

  static String getInitialRoutePath() {
    return _getPageRoutes().first.path;
  }

  static String getHomeRouteName() {
    return _getPageRoutes().firstWhere((route) => route.isHomeRoute).name;
  }

  static String getHomeRoutePath() {
    return _getPageRoutes().firstWhere((route) => route.isHomeRoute).path;
  }

  static Widget getHomeRouteWidget() {
    return _getPageRoutes().firstWhere((route) => route.isHomeRoute).widget;
  }

  static List<NamedPageRoute> _getPageRoutes() {
    return [
      const NamedPageRoute(
        name: 'LibraryPage',
        widget: LibraryPage(),
        isRestorableRoute: true,
        isHomeRoute: true,
      ),
      const NamedPageRoute(
        name: 'MusicPage',
        widget: MusicPage(),
        isRestorableRoute: true,
        ancestors: ['LibraryPage'],
      ),
      const NamedPageRoute(
        name: 'PlaylistPage',
        widget: PlaylistPage(),
        isRestorableRoute: true,
        ancestors: ['LibraryPage'],
      ),
      const NamedPageRoute(
        name: 'RecentlyPlayedPage',
        widget: RecentlyPlayedPage(),
        isRestorableRoute: true,
        ancestors: ['LibraryPage'],
      ),
      // Settings
      const NamedPageRoute(
        name: 'SettingsPage',
        widget: SettingsPage(),
        isRestorableRoute: true,
        ancestors: ['LibraryPage'],
      ),
      const NamedPageRoute(
        name: 'DirectoryPage',
        widget: DirectoryPage(),
        isRestorableRoute: true,
        ancestors: ['SettingsPage'],
      ),
      const NamedPageRoute(
        name: 'EqualizerPage',
        widget: EqualizerPage(),
        isRestorableRoute: true,
        ancestors: ['SettingsPage'],
      ),
      const NamedPageRoute(
        name: 'MessagesPage',
        widget: MessagesPage(),
        isRestorableRoute: true,
        ancestors: ['SettingsPage'],
      ),
      const NamedPageRoute(
        name: 'ThemePage',
        widget: ThemePage(),
        isRestorableRoute: true,
        ancestors: ['SettingsPage'],
      ),
      const NamedPageRoute(
        name: 'PlayerPage',
        widget: PlayerPage(),
        isRestorableRoute: true,
        ancestors: ['LibraryPage'],
      ),
      const NamedPageRoute(
        name: 'NewsPage',
        widget: NewsPage(),
        isRestorableRoute: true,
        ancestors: ['LibraryPage'],
      ),
    ];
  }

  static Map<String, Widget Function(BuildContext)> getNamedPageRoutes() {
    Map<String, Widget Function(BuildContext)> routes = {};
    List<NamedPageRoute> pages = _getPageRoutes();

    for (NamedPageRoute page in pages) {
      routes.addAll({page.path: (context) => page.widget});
    }

    return routes;
  }

  static Route<dynamic>? onGenerateRoute(
    BuildContext context,
    RouteSettings settings,
  ) {
    if (settings.name?.equals('/') ?? false) {
      return AnimatedMaterialPageRoute(
        widget: getInitialRouteWidget(),
        transitionColor: Theme.of(context).scaffoldBackgroundColor,
        settings: RouteSettings(name: getInitialRoutePath()),
      );
    } else if (!settings.name.isNull) {
      NamedPageRoute page = _getPageRoutes().firstWhere(
          (route) => route.path.equals(settings.name ?? ''),
          orElse: () => _getPageRoutes().first);
      return AnimatedMaterialPageRoute(
        widget: page.widget,
        transitionColor: Theme.of(context).scaffoldBackgroundColor,
        settings: RouteSettings(name: page.path),
      );
    } else {
      return null;
    }
  }

  static List<Route<dynamic>> onGenerateInitialRoutes(
    BuildContext context,
    String initialRoute,
  ) {
    List<Route<dynamic>> routes = [];
    List<NamedPageRoute> pageRoutes = _getPageRoutes();
    NamedPageRoute restorableRoute = pageRoutes.first;

    routes.add(
      AnimatedMaterialPageRoute(
        widget: restorableRoute.widget,
        transitionColor: Theme.of(context).scaffoldBackgroundColor,
        settings: RouteSettings(name: restorableRoute.path),
      ),
    );
    return routes;
  }

  static Route<dynamic>? onUnknownRoute(
      BuildContext context, RouteSettings settings) {
    return AnimatedMaterialPageRoute(
      widget: const UnknownRouteWidget(),
      transitionColor: Theme.of(context).scaffoldBackgroundColor,
      settings: settings,
    );
  }

  static Route<void> generateRestorableRoute(
    BuildContext context,
    Map<Object?, Object?> params,
  ) {
    Widget widget = _getPageRoutes()
        .firstWhere(
          (route) => route.name.equals(params['name'] as String),
          orElse: () => _getPageRoutes().first,
        )
        .widget;
    return AnimatedMaterialPageRoute(
      widget: widget,
      transitionColor: Theme.of(context).scaffoldBackgroundColor,
      direction: TransitionDirection.fromName(params['direction'] as String),
      settings: RouteSettings(name: '/${params['name']}'),
    );
  }
}
