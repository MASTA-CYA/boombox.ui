import 'package:boombox/commons_barrel.dart';
import 'package:boombox/theme-component/models/user_theme_model.dart';

class UserSettings {
  bool? canSaveLyricsLocally;
  bool? useEternalStorage;
  bool? canDownloadArtistMedia;
  bool? useSmartEqualizer;
  bool? canFetchNews;
  bool? canShowApplicationFeatures;
  bool? isDrivingModeEnable;
  UserTheme? theme;
  Brightness? isDarkTheme;

  UserSettings({
    this.canSaveLyricsLocally = false,
    this.useEternalStorage = false,
    this.canDownloadArtistMedia = false,
    this.useSmartEqualizer = false,
    this.canFetchNews = false,
    this.canShowApplicationFeatures = false,
    this.isDrivingModeEnable = false,
    this.theme,
    this.isDarkTheme,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
        canSaveLyricsLocally: json['canSaveLyricsLocally'],
        useEternalStorage: json['useEternalStorage'],
        canDownloadArtistMedia: json['canDownloadArtistMedia'],
        useSmartEqualizer: json['useSmartEqualizer'],
        canFetchNews: json['canFetchNews'],
        canShowApplicationFeatures: json['canShowApplicationFeatures'],
        isDrivingModeEnable: json['isDrivingModeEnable'],
        theme: (json['theme'] as Object?).isNull
            ? json['theme']
            : UserTheme.fromJson(json['theme']),
        isDarkTheme: (int.tryParse(json['isDarkTheme'] ?? '0') as int).isZero
            ? Brightness.dark
            : Brightness.light,
      );

  static Map<String, dynamic> toJson(UserSettings settings) => {
        'canSaveLyricsLocally': settings.canSaveLyricsLocally,
        'useEternalStorage': settings.useEternalStorage,
        'canDownloadArtistMedia': settings.canDownloadArtistMedia,
        'useSmartEqualizer': settings.useSmartEqualizer,
        'canFetchNews': settings.canFetchNews,
        'canShowApplicationFeatures': settings.canShowApplicationFeatures,
        'isDrivingModeEnable': settings.isDrivingModeEnable,
        'theme': settings.theme.isNull
            ? settings.theme
            : UserTheme.toJson(settings.theme!),
        'isDarkTheme':
            (settings.isDarkTheme ?? Brightness.dark).index.toString(),
      };
}
