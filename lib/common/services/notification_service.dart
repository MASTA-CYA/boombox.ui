import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:boombox/common/extensions.dart';
import 'package:boombox/common/navigator/page_navigator.dart';
import 'package:boombox/common/navigator/transition_direction_enum.dart';
import 'package:boombox/main.dart';
import 'package:boombox/player-component/player_page.dart';
import 'package:boombox/player-component/services/player_service.dart';
import 'package:flutter/material.dart';
import 'package:boombox/common/helpers/color_helper.dart';
import 'package:provider/provider.dart';

class NotificationService {
  static const CHANNEL_KEY = 'BOOMBOX_NOTIFICATION_CHANNEL_KEY';
  static const CHANNEL_NAME = 'BOOMBOX_NOTIFICATION_CHANNEL_NAME';
  static const CHANNEL_DESCRIPTION = 'BOOMBOX_NOTIFICATION_CHANNEL_DESCRIPTION';

  // Media Player
  static const PREVIOUS_BUTTON_KEY = 'PREVIOUS';
  static const NEXT_BUTTON_KEY = 'NEXT';
  static const PLAY_BUTTON_KEY = 'PLAY';
  static const PAUSE_BUTTON_KEY = 'PAUSE';
  static const CLOSE_BUTTON_KEY = 'CLOSE';

  static late AwesomeNotifications _notifier;

  static ReceivedAction? initialAction;
  static ReceivePort? receivePort;

  int? mediaPlayerNotificationId;

  static final NotificationService _instance = NotificationService._internal();
  // using a factory is important
  // because it promises to return _an_ object of this type
  factory NotificationService() {
    return _instance;
  }
  // This named constructor is the "real" constructor
  // It'll be called exactly once, by the static property assignment above
  // it's also private, so it can only be called in this class
  NotificationService._internal() {
    _init();
  }

  Future<void> _init() async {
    _notifier = AwesomeNotifications();
    await _initializeLocalNotifications();
    await _initializeIsolateReceivePort();
    await startListeningNotificationEvents();
  }

  Future<void> dispose() async {
    _notifier.dispose();
  }

  Future<void> _initializeLocalNotifications() async {
    await _notifier.initialize(
        'resource://drawable/boombox',
        [
          NotificationChannel(
            channelKey: CHANNEL_KEY,
            channelName: CHANNEL_NAME,
            channelDescription: CHANNEL_DESCRIPTION,
            groupAlertBehavior: GroupAlertBehavior.Children,
            importance: NotificationImportance.Low,
            defaultPrivacy: NotificationPrivacy.Public,
            defaultRingtoneType: DefaultRingtoneType.Notification,
            criticalAlerts: false,
            onlyAlertOnce: false,
            enableVibration: false,
            enableLights: false,
            playSound: false,
            locked: true,
          ),
        ],
        debug: false);

    // Get initial notification action is optional
    initialAction = await _notifier.getInitialNotificationAction(
        removeFromActionEvents: false);
  }

  Future<void> _initializeIsolateReceivePort() async {
    receivePort = ReceivePort('Notification action port in main isolate')
      ..listen(
          (silentData) => onActionReceivedImplementationMethod(silentData));

    // This initialization only happens on main isolate
    IsolateNameServer.registerPortWithName(
        receivePort!.sendPort, 'notification_action_port');
  }

  Future<void> startListeningNotificationEvents() async {
    _notifier.setListeners(onActionReceivedMethod: onActionReceivedMethod);
  }

  @pragma('vm:entry-point')
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    if (receivedAction.actionType == ActionType.SilentAction ||
        receivedAction.actionType == ActionType.SilentBackgroundAction) {
      // For background actions, you must hold the execution until the end
      print(
          'Message sent via notification input: "${receivedAction.buttonKeyInput}"');
      await executeLongTaskInBackground();
    } else {
      // this process is only necessary when you need to redirect the user
      // to a new page or use a valid context, since parallel isolates do not
      // have valid context, so you need redirect the execution to main isolate
      if (receivePort == null) {
        print(
            'onActionReceivedMethod was called inside a parallel dart isolate.');
        SendPort? sendPort =
            IsolateNameServer.lookupPortByName('notification_action_port');

        if (sendPort != null) {
          print('Redirecting the execution to main isolate process.');
          sendPort.send(receivedAction);
          return;
        }
      }

      return onActionReceivedImplementationMethod(receivedAction);
    }
  }

  static Future<void> onActionReceivedImplementationMethod(
      ReceivedAction receivedAction) async {
    if ((Main.navigatorKey.currentState?.context).isNull) return;

    final BuildContext context = Main.navigatorKey.currentState!.context;

    switch (receivedAction.payload?['origin']) {
      case 'Media Player':
        await _handleMediaPlayerNotificationAction(context, receivedAction);
        break;
      default:
        break;
    }
  }

  static Future<void> _handleMediaPlayerNotificationAction(
      BuildContext context, ReceivedAction receivedAction) async {
    switch (receivedAction.buttonKeyPressed) {
      case PREVIOUS_BUTTON_KEY:
        if (context.mounted) {
          await Provider.of<PlayerService>(
            context,
            listen: false,
          ).previousAsync();
        }
        break;
      case PLAY_BUTTON_KEY:
        if (context.mounted) {
          //In most cases does not finish and suspends execution
          await Provider.of<PlayerService>(
            context,
            listen: false,
          ).playAsync();
        }
        break;
      case PAUSE_BUTTON_KEY:
        if (context.mounted) {
          await Provider.of<PlayerService>(
            context,
            listen: false,
          ).pauseAsync();
        }
        break;
      case NEXT_BUTTON_KEY:
        if (context.mounted) {
          await Provider.of<PlayerService>(
            context,
            listen: false,
          ).nextAsync();
        }
        break;
      case CLOSE_BUTTON_KEY:
        NotificationService().cancelNotification();
        PageNavigator.exitApplication<NotificationService>();
        break;
      default:
        if (context.mounted) {
          // Playlist playlist = await Provider.of<PlayerService>(
          //   context,
          //   listen: false,
          // ).getActivePlaylistAsync();

          if (context.mounted) {
            PageNavigator.navigateTo<NotificationService>(
              context,
              const PlayerPage(),
              direction: TransitionDirection.btt,
            );
          }
        }
        break;
    }
  }

  static Future<bool> displayNotificationRationale() async {
    bool userAuthorized = false;
    BuildContext context = Main.navigatorKey.currentContext!;
    await showDialog(
        context: context,
        builder: (BuildContext ctx) {
          return AlertDialog(
            title: Text('Get Notified!',
                style: Theme.of(context).textTheme.titleLarge),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Image.asset(
                        'assets/images/animated-bell.gif',
                        height: MediaQuery.of(context).size.height * 0.3,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text('Allow Boombox to send notifications.'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                },
                child: Text(
                  'Deny',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.red),
                ),
              ),
              TextButton(
                onPressed: () async {
                  userAuthorized = true;
                  Navigator.of(ctx).pop();
                },
                child: Text(
                  'Allow',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.deepPurple),
                ),
              ),
            ],
          );
        });
    return userAuthorized &&
        await _notifier.requestPermissionToSendNotifications();
  }

  static Future<void> executeLongTaskInBackground() async {
    print("starting long task");
    await Future.delayed(const Duration(seconds: 4));
    // final url = Uri.parse("http://google.com");
    // final re = await http.get(url);
    // print(re.body);
    print("long task done");
  }

  static Future<bool> isNotificationAllowed() async {
    bool isAllowed = await _notifier.isNotificationAllowed();
    if (!isAllowed) isAllowed = await displayNotificationRationale();

    return isAllowed;
  }

  Future<void> cancelNotification({int? id}) async {
    id.isNull ? await _notifier.cancelAll() : await _notifier.cancel(id!);
  }

  Future<void> showMediaPlayerNotification(
    String title,
    String body,
    String image,
    bool isPlaying, {
    String payload = 'Media Player',
  }) async {
    if (!await isNotificationAllowed()) return;
    if (mediaPlayerNotificationId.isNull) {
      await cancelNotification();
      mediaPlayerNotificationId = Random().nextInt(100);
    }

    await _notifier.createNotification(
      content: NotificationContent(
        id: mediaPlayerNotificationId!,
        channelKey: CHANNEL_KEY,
        largeIcon: image,
        title: title,
        body: body,
        summary: 'Now Playing',
        payload: {'origin': payload},
        notificationLayout: NotificationLayout.MediaPlayer,
        category: NotificationCategory.Transport,
        color: ColorHelper.darken(ColorHelper.fromHex('#710193')),
        backgroundColor: ColorHelper.fromHex('#505050'),
        autoDismissible: false,
        showWhen: false,
      ),
      actionButtons: [
        NotificationActionButton(
          key: PREVIOUS_BUTTON_KEY,
          label: 'Previous',
          icon: 'resource://drawable/ic_baseline_skip_previous_24',
          autoDismissible: false,
          enabled: true,
          actionType: ActionType.KeepOnTop,
        ),
        isPlaying
            ? NotificationActionButton(
                key: PAUSE_BUTTON_KEY,
                label: 'Pause',
                icon: 'resource://drawable/ic_baseline_pause_24',
                autoDismissible: false,
                enabled: true,
                actionType: ActionType.KeepOnTop,
              )
            : NotificationActionButton(
                key: PLAY_BUTTON_KEY,
                label: 'Play',
                icon: 'resource://drawable/ic_baseline_play_arrow_24',
                autoDismissible: false,
                enabled: true,
                actionType: ActionType.KeepOnTop,
              ),
        NotificationActionButton(
          key: NEXT_BUTTON_KEY,
          label: 'Next',
          icon: 'resource://drawable/ic_baseline_skip_next_24',
          autoDismissible: false,
          enabled: true,
          actionType: ActionType.KeepOnTop,
        ),
        NotificationActionButton(
          key: CLOSE_BUTTON_KEY,
          label: 'Close',
          icon: 'resource://drawable/ic_baseline_close_24',
          autoDismissible: false,
          enabled: true,
          actionType: ActionType.KeepOnTop,
        ),
      ],
    );
  }

  // Future<void> showNotification(
  //   String title,
  //   String body,
  //   String summary,
  //   String image, {
  //   String payload = 'Not present',
  // }) async {
  //   if (!await isNotificationAllowed()) return;

  //   final int notificationId = Random().nextInt(100);
  // }
  // Future<void> showNotificationWithActions(
  //     List<AndroidNotificationAction> actions) async {}
  // Future<void> showScheduledNotification(
  //     String title, String body, String message) async {}
  // Future<void> showScheduledNotificationWithActions(
  //     List<AndroidNotificationAction> actions) async {}
}
