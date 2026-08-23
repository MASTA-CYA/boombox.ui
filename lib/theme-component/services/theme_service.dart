import 'package:boombox/theme-component/models/user_theme_model.dart';
import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:flutter/services.dart';

class ThemeService with ChangeNotifier {
  late List<UserTheme> _themes;

  static final ThemeService _instance = ThemeService._internal();
// using a factory is important
// because it promises to return _an_ object of this type
  factory ThemeService() {
    return _instance;
  }
// This named constructor is the "real" constructor
// It'll be called exactly once, by the static property assignment above
// it's also private, so it can only be called in this class
  ThemeService._internal() {
    _init();
  }

  Future<void> _init() async {
    _themes = [];

    // Add Default themes
    // final AssetManifest assetManifest =
    //     await AssetManifest.loadFromAssetBundle(rootBundle);
    // // This returns a List<String> with all your images
    // final List<String> images = assetManifest
    //     .listAssets()
    //     .where((string) => string.startsWith("assets/images/themes"))
    //     .toList();

    _themes.add(
      UserTheme(
        name: 'Boombox',
        path: 'assets/images/themes/80s Party.png',
        fit: BoxFit.fill,
        invertColors: true,
        isCustom: false,
      ),
    );

  // Add Custom themes
    _themes.addAll(
      <UserTheme>[
        UserTheme(
          name: '80s Party',
          path: 'assets/images/themes/80s Party.png',
          fit: BoxFit.fill,
          invertColors: true,
        ),
        UserTheme(
          name: 'Men Of Funk',
          path: 'assets/images/themes/Men Of Funk.jpg',
          fit: BoxFit.fill,
          invertColors: false,
        ),
      ],
    );
  }

  Future<List<UserTheme>> getDefaultThemesAsync() async {
    return _themes.where((theme) => !theme.isCustom!).toList();
  }

  Future<List<UserTheme>> getCustomThemesAsync() async {
    return _themes.where((theme) => theme.isCustom!).toList();
  }
}
