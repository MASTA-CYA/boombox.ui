import 'dart:async';

import 'package:boombox/common/http/models/Internet_connection_state_model.dart';
import 'package:boombox/commons_barrel.dart';
import 'package:boombox/message-component/models/message_severity_enum.dart';
import 'package:boombox/message-component/models/notification_model.dart';
import 'package:boombox/message-component/services/message_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService with ChangeNotifier {
  late Connectivity _connectivity;
  late InternetConnectionState _currentState;

  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  static final ConnectivityService _instance = ConnectivityService._internal();
  // using a factory is important
  // because it promises to return _an_ object of this type
  factory ConnectivityService() {
    return _instance;
  }
  // This named constructor is the "real" constructor
  // It'll be called exactly once, by the static property assignment above
  // it's also private, so it can only be called in this class
  ConnectivityService._internal() {
    _init();
  }

  @override
  void dispose() async {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    _connectivity = Connectivity();
    _currentState = const InternetConnectionState(
      source: ConnectionSource.none,
      isConnected: false,
    );

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (result) async {
        _currentState = InternetConnectionState(
          source: ConnectionSource.fromConnectivityResult(result),
          isConnected: true,
        );
        await MessageService().sendNotificationAsync(
            AppNotification(
              title: 'Internet Connectivity',
              message: _currentState.source.equals(ConnectionSource.none)
                  ? 'Device has lost internet connectivity. '
                      'Online features will not work as intended.'
                  : 'Device internet connectivity changed to ${_currentState.source.name}',
              notificationText: _currentState.source
                      .equals(ConnectionSource.none)
                  ? 'No internet connectivity'
                  : 'Internet connectivity via ${_currentState.source.name} network',
              severity: _currentState.source.equals(ConnectionSource.none)
                  ? MessageSeverity.warning
                  : MessageSeverity.information,
            ),
            saveAsMessage: _currentState.source.equals(ConnectionSource.none));
      },
    );
  }

  Future<bool> hasNetworkConnectivityAsync() async {
    return !_currentState.source.equals(ConnectionState.none);
  }
}
