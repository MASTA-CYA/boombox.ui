import 'dart:ui';

import 'package:boombox/common/extensions.dart';
import 'package:boombox/common/logger/logger.dart';
import 'package:boombox/common/logger/models/log_event_model.dart';
import 'package:boombox/common/services/keep_alive_service.dart';
import 'package:boombox/common/services/notification_service.dart';
import 'package:boombox/main.dart';
import 'package:boombox/player-component/services/player_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:boombox/common/logger/enums/severity_enum.dart';
import 'package:boombox/common/logger/enums/tag_enum.dart';

class ApplicationLifecycleService {
  late List<String> _stateHistory;

  static late bool _canSendMediaPlayerNotifications;

  static final ApplicationLifecycleService _instance =
      ApplicationLifecycleService._internal();
  // using a factory is important
  // because it promises to return _an_ object of this type
  factory ApplicationLifecycleService() {
    return _instance;
  }
  // This named constructor is the "real" constructor
  // It'll be called exactly once, by the static property assignment above
  // it's also private, so it can only be called in this class
  ApplicationLifecycleService._internal() {
    _init();
  }

  void _init() async {
    AppLifecycleListener(
      onExitRequested: _handleExitRequestAsync,
      onStateChange: _handleStateChangedAsync,
    );
    _stateHistory = ['onStart'];
    _canSendMediaPlayerNotifications = false;
  }

  void _handleStateChangedAsync(AppLifecycleState state) async {
    switch (state.name) {
      case 'paused':
        await _handleOnPausedStateAsync();
        break;
      case 'resumed':
        await _handleOnResumedStateAsync();
        break;
      case 'detached':
        await _handleOnDetachedAsync();
        break;
      default:
        _canSendMediaPlayerNotifications = false;
        break;
    }

    await Logger.logAsync(
      LogEvent<ApplicationLifecycleService>(
        severity: Severity.information,
        tag: Tag.application,
        line: 'App state changed from ${_stateHistory.last} to ${state.name}',
      ),
    );
    _stateHistory.add(state.name);
  }

  Future<void> _handleOnResumedStateAsync() async {
    _canSendMediaPlayerNotifications = false;
    NotificationService().cancelNotification();
  }

  Future<void> _handleOnPausedStateAsync() async {
    BuildContext? context = Main.navigatorKey.currentState?.context;
    _canSendMediaPlayerNotifications = true;

    try {
      if (context.isNull || !(context?.mounted ?? false)) {
        throw Exception(
          'Context of Main is null or defunct. '
          'Handler: _handleOnPausedStateAsync.',
        );
      }

      await Provider.of<PlayerService>(
        context!,
        listen: false,
      ).showNowPlayingNotificationAsync();
    } on Exception catch (ex) {
      await Logger.logAsync(
        LogEvent<ApplicationLifecycleService>(
          severity: Severity.error,
          tag: Tag.application,
          line: ex.toString(),
        ),
      );
    }
  }

  static bool canSendMediaPlayerNotifications() =>
      _canSendMediaPlayerNotifications;

  Future<void> _handleOnDetachedAsync() async {
    // Run possible resource clean up
    // BuildContext context = Main.navigatorKey.currentState!.context;

    // Notifications
    _canSendMediaPlayerNotifications = false;
    await NotificationService().dispose();
    // Keep Alive Service
    await KeepAliveService().dispose();

    // Services

    // Logger
    await Logger.logAsync(
      LogEvent<ApplicationLifecycleService>(
        severity: Severity.information,
        tag: Tag.application,
        line: 'Boombox is shutting down',
      ),
    );
  }

  Future<AppExitResponse> _handleExitRequestAsync() async {
    await Logger.logAsync(
      LogEvent<ApplicationLifecycleService>(
        severity: Severity.error,
        tag: Tag.application,
        line: 'Handled exit request',
      ),
    );

    return AppExitResponse.exit;
  }
}
