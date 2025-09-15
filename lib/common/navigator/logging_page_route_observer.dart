import 'package:boombox/common/logger/enums/severity_enum.dart';
import 'package:boombox/common/logger/enums/tag_enum.dart';
import 'package:boombox/common/logger/logger.dart';
import 'package:boombox/common/logger/models/log_event_model.dart';
import 'package:flutter/material.dart';

class LoggingPageRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) async {
    super.didPush(route, previousRoute);
    if (route is PageRoute) {
      await _logNavigation(
        route.settings.name,
        previousRoute?.settings.name,
        RouterAction.push,
      );
    }
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) async {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute is PageRoute) {
      await _logNavigation(
        newRoute.settings.name,
        oldRoute?.settings.name,
        RouterAction.replace,
      );
    }
  }

  @override
  void didPop(Route<dynamic>? route, Route<dynamic>? previousRoute) async {
    super.didPop(route!, previousRoute);
    if (route is PageRoute && previousRoute is PageRoute) {
      await _logNavigation(
        route.settings.name,
        previousRoute.settings.name,
        RouterAction.pop,
      );
    }
  }

  Future<void> _logNavigation(
    String? newRoute,
    String? oldRoute,
    RouterAction action,
  ) async {
    await Logger.logAsync(
      LogEvent<LoggingPageRouteObserver>(
        severity: Severity.information,
        tag: Tag.observer,
        line: _buildLogLine(newRoute, oldRoute, action),
      ),
    );
  }

  static String _buildLogLine(
    String? newRoute,
    String? oldRoute,
    RouterAction action,
  ) {
    String line;
    switch (action) {
      case RouterAction.push:
        line = 'Navigated from $oldRoute to $newRoute';
        break;
      case RouterAction.pop:
        line = 'Navigated from $newRoute to $oldRoute';
        break;
      case RouterAction.replace:
        line = 'Replaced route $oldRoute with $newRoute';
        break;
    }

    return line;
  }
}

enum RouterAction {
  push,
  replace,
  pop,
}
