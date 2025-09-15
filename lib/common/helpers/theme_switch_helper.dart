import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:boombox/commons_barrel.dart';
import 'package:boombox/settings-component/services/user_settings_service.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

class ThemeSwitchHelper {
  static void switchApplicationThemeAsync(
    BuildContext context,
    ThemeData theme,
    Brightness brightness,
  ) async {
    try {
      ThemeSwitcher.of(context).changeTheme(theme: theme);
      await Provider.of<UserSettingsService>(
        context,
        listen: false,
      ).updateApplicationThemeAsync(brightness);
      Logger.logAsync(
        LogEvent<ThemeSwitchHelper>(
          severity: Severity.information,
          tag: Tag.helper,
          line: 'Application theme changed to ${describeEnum(brightness)} mode',
        ),
      );
    } on Exception catch (ex) {
      Logger.logAsync(
        LogEvent<ThemeSwitchHelper>(
          severity: Severity.error,
          tag: Tag.helper,
          line: ex.toString(),
        ),
      );
    }
  }
}
