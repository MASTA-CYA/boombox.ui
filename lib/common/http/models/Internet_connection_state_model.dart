import 'package:boombox/common/extensions.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

class InternetConnectionState {
  final ConnectionSource source;
  final bool isConnected;

  const InternetConnectionState({
    required this.source,
    required this.isConnected,
  });
}

enum ConnectionSource {
  wifi,
  ethernet,
  bluetooth,
  mobile,
  none,
  vpn,
  other;

  factory ConnectionSource.fromConnectivityResult(ConnectivityResult result) {
    switch (result) {
      case ConnectivityResult.wifi:
        return ConnectionSource.wifi;
      case ConnectivityResult.bluetooth:
        return ConnectionSource.bluetooth;
      case ConnectivityResult.ethernet:
        return ConnectionSource.ethernet;
      case ConnectivityResult.mobile:
        return ConnectionSource.mobile;
      case ConnectivityResult.vpn:
        return ConnectionSource.vpn;
      case ConnectivityResult.other:
        return ConnectionSource.other;
      default:
        return ConnectionSource.none;
    }
  }
  String toJson() => serializableName;
}

extension ConnectionSourceExtension on ConnectionSource {
  String get serializableName => describeEnum(this);
  String get name {
    switch (this) {
      case ConnectionSource.wifi:
      case ConnectionSource.ethernet:
      case ConnectionSource.mobile:
      case ConnectionSource.none:
      case ConnectionSource.vpn:
      case ConnectionSource.other:
        return describeEnum(this).capitalize();
      default:
        return 'Unknown';
    }
  }
}
