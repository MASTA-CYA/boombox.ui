import 'package:boombox/common/navigator/page_route_helper.dart';
import 'package:boombox/common/service-bus/models/message_subscriber_interface.dart';
import 'package:boombox/common/service-bus/service_bus.dart';
import 'package:boombox/common/services/background_service.dart';
import 'package:boombox/common/services/connectivity_service.dart';
import 'package:boombox/common/http/services/http_service.dart';
import 'package:boombox/library-component/services/library_service.dart';
import 'package:boombox/message-component/services/message_service.dart';
import 'package:boombox/news-component/services/news_service.dart';
import 'package:boombox/services_barrel.dart';
import 'package:boombox/commons_barrel.dart';
import 'package:flutter/gestures.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GestureBinding.instance.resamplingEnabled = true;

  // Load API keys/tokens from .env before any service that reads them
  // (MetaDataService, MediaArtService below) is constructed. See
  // .env.example / README for setup - this is expected to fail on a fresh
  // checkout until .env exists, in which case those two services just fall
  // back to running without art/genre lookups rather than crashing.
  try {
    await dotenv.load(fileName: '.env');
  } catch (ex) {
    await Logger.logAsync(
      LogEvent<Main>(
        severity: Severity.error,
        tag: Tag.application,
        line:
            'Could not load .env ($ex). Copy .env.example to .env and fill '
            'in your own keys to enable album art and genre lookups - see '
            'README.md. Continuing without them.',
      ),
    );
  }

  // Initialize background service
  BackgroundService();
  // Initialize notification service
  NotificationService();
  // Initialize AppLifeCycle service
  ApplicationLifecycleService();
  // Initialize Metadata Service
  MetaDataService();
  // Initialize MediaArt Service
  MediaArtService();
  // Initialize Lyrics Service
  LyricsService();
  // Request Application Permissions
  await PermissionsService.requestApplicationPermissionsAsync();
  // Application Theme
  final Brightness theme =
      await UserSettingsService.getApplicationThemeFromStorageAsync();

  runApp(Main(theme: theme));
}

class Main extends StatelessWidget {
  // This widget is the root of your application.
  final String title = 'Boombox';
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  final Brightness theme;

  const Main({
    super.key,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          lazy: false,
          create: (context) => ConnectivityService(),
          builder: (context, child) {
            _logServiceStartup<ConnectivityService>();
            return child!;
          },
        ),
        ChangeNotifierProvider(
          lazy: false,
          create: (context) => HttpService(),
          builder: (context, child) {
            _logServiceStartup<HttpService>();
            return child!;
          },
        ),
        ChangeNotifierProvider(
          lazy: false,
          create: (context) => PlayerService(),
          builder: (context, child) {
            _logServiceStartup<PlayerService>();
            WidgetsBinding.instance.addPostFrameCallback(
              (_) async {
                bool isPlayerConfigured =
                    await Provider.of<PlayerService>(context, listen: false)
                        .isPlayerConfiguredAsync();
                // Initialize player
                if (!isPlayerConfigured && context.mounted) {
                  await Provider.of<PlayerService>(context, listen: false)
                      .initPlayerServiceAsync();
                }
              },
            );
            return child!;
          },
        ),
        ChangeNotifierProvider(
          lazy: false,
          create: (context) => DirectoryService(),
          builder: (context, child) {
            _logServiceStartup<DirectoryService>();

            return child!;
          },
        ),
        ChangeNotifierProvider(
          lazy: false,
          create: (context) => EqualizerService(),
          builder: (context, child) {
            _logServiceStartup<EqualizerService>();
            return child!;
          },
        ),
        ChangeNotifierProvider(
          lazy: false,
          create: (context) => MusicService(),
          builder: (context, child) {
            _logServiceStartup<MusicService>();
            return child!;
          },
        ),
        ChangeNotifierProvider(
          lazy: false,
          create: (context) => PlaylistService(),
          builder: (context, child) {
            _logServiceStartup<PlaylistService>();
            return child!;
          },
        ),
        ChangeNotifierProvider(
          lazy: false,
          create: (context) => FavoritesService(),
          builder: (context, child) {
            _logServiceStartup<FavoritesService>();
            return child!;
          },
        ),
        ChangeNotifierProvider(
          lazy: false,
          create: (context) => UserSettingsService(),
          builder: (context, child) {
            _logServiceStartup<UserSettingsService>();
            return child!;
          },
        ),
        ChangeNotifierProvider(
          lazy: false,
          create: (context) => RecentlyPlayedService(),
          builder: (context, child) {
            _logServiceStartup<RecentlyPlayedService>();
            return child!;
          },
        ),
        ChangeNotifierProvider(
          lazy: false,
          create: (context) => TrimAudioService(),
          builder: (context, child) {
            _logServiceStartup<TrimAudioService>();
            return child!;
          },
        ),
        ChangeNotifierProvider(
          lazy: false,
          create: (context) => ThemeService(),
          builder: (context, child) {
            _logServiceStartup<ThemeService>();
            return child!;
          },
        ),
        ChangeNotifierProvider(
          lazy: false,
          create: (context) => MessageService(),
          builder: (context, child) {
            _logServiceStartup<MessageService>();
            return child!;
          },
        ),
        ChangeNotifierProvider(
          lazy: false,
          create: (context) => LibraryService(),
          builder: (context, child) {
            _logServiceStartup<LibraryService>();
            _registerSubscriber('LibraryService', LibraryService());
            return child!;
          },
        ),
        ChangeNotifierProvider(
          lazy: false,
          create: (context) => NewsService(),
          builder: (context, child) {
            _logServiceStartup<NewsService>();
            return child!;
          },
        ),
      ],
      child: ThemeProvider(
        initTheme: theme.equals(Brightness.dark)
            ? AppThemes.darkTheme
            : AppThemes.lightTheme,
        builder: (_, theme) {
          Logger.logAsync(
            LogEvent<Main>(
              severity: Severity.information,
              tag: Tag.application,
              line: '$title Starting up...',
            ),
          );
          return MaterialApp(
            restorationScopeId: 'app',
            navigatorKey: navigatorKey,
            title: title,
            theme: theme,
            themeAnimationCurve: Curves.easeIn,
            debugShowCheckedModeBanner: false,
            onGenerateInitialRoutes: (initialRoute) =>
                PageRouteHelper.onGenerateInitialRoutes(
              context,
              initialRoute,
            ),
            onGenerateRoute: (settings) => PageRouteHelper.onGenerateRoute(
              context,
              settings,
            ),
            onUnknownRoute: (settings) => PageRouteHelper.onUnknownRoute(
              context,
              settings,
            ),
            routes: PageRouteHelper.getNamedPageRoutes(),
            navigatorObservers: [LoggingPageRouteObserver()],
          );
        },
      ),
    );
  }

  Future _logServiceStartup<T>({String? line}) async {
    await Logger.logAsync(
      LogEvent<T>(
        severity: Severity.information,
        tag: Tag.service,
        line: line ?? 'Starting up...',
      ),
    );
  }

  Future<void> _registerSubscriber(
      String name, MessageSubscriber service) async {
    await ServiceBus().registerServiceAsync(name, service);
  }
}
