import 'package:boombox/common/extensions.dart';
import 'package:boombox/common/logger/enums/severity_enum.dart';
import 'package:boombox/common/logger/enums/tag_enum.dart';
import 'package:boombox/common/logger/logger.dart';
import 'package:boombox/common/logger/models/log_event_model.dart';
import 'package:boombox/common/navigator/page_route.dart';
import 'package:boombox/common/navigator/page_route_helper.dart';
import 'package:boombox/common/navigator/transition_direction_enum.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

class PageNavigator {
  static void navigateTo<T>(
    BuildContext context,
    Widget widget, {
    bool shouldPop = false,
    bool useScheduler = true,
    TransitionDirection direction = TransitionDirection.ltr,
  }) async {
    if (!context.mounted) return;

    // Short circuit navigation if page is the same as current
    String? currentPage = ModalRoute.of(context)!.settings.name;
    if (currentPage?.equals('/'
            '${widget.runtimeType.toString()}') ??
        false) {
      await _logNavigation<T>(isExitCommand: false);
      return;
    }

    if (useScheduler) {
      SchedulerBinding.instance.addPostFrameCallback(
        (_) async => await _doNavigation(
          context,
          widget,
          shouldPop,
          direction,
          T,
        ),
      );
    } else {
      await _doNavigation(
        context,
        widget,
        shouldPop,
        direction,
        T,
      );
    }
  }

  static void navigateBack<T>(BuildContext context) async {
    if (!context.mounted) {
      return;
    }

    SchedulerBinding.instance.addPostFrameCallback(
      (_) {
        if (Navigator.canPop(context)) {
          Navigator.of(context).maybePop(context);
        }
      },
    );
  }

  static void exitApplication<T>() async {
    await _logNavigation<T>(isExitCommand: true);
    await SystemNavigator.pop(
      animated: defaultTargetPlatform == TargetPlatform.iOS,
    );
  }

  static Future<void> _doNavigation(
    BuildContext context,
    Widget widget,
    bool shouldPop,
    TransitionDirection direction,
    Type type,
  ) async {
    if (shouldPop && Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    if (type.toString().containsIgnoreCase('page')) {
      Navigator.of(context).restorablePush(
        _restorableRouteBuilder,
        arguments: {
          'name': type.toString(),
          'direction': describeEnum(direction),
        },
      );
    } else {
      Navigator.of(context).push(
        AnimatedMaterialPageRoute(
          widget: widget,
          transitionColor: Theme.of(context).scaffoldBackgroundColor,
          direction: direction,
          settings: RouteSettings(name: '/$type'),
        ),
      );
    }
  }

  @pragma('vm:entry-point')
  static Route<void> _restorableRouteBuilder(
    BuildContext context,
    Object? arguments,
  ) {
    Map<Object?, Object?> params = arguments! as Map<Object?, Object?>;
    return PageRouteHelper.generateRestorableRoute(context, params);
  }

  static Future<void> _logNavigation<T>({
    bool isExitCommand = false,
  }) async {
    await Logger.logAsync(
      LogEvent<PageNavigator>(
        severity: Severity.information,
        tag: Tag.application,
        line: isExitCommand
            ? 'Attempting to gracefully exit application'
            : 'Navigation short-circuited for page: $T',
      ),
    );
  }
}
