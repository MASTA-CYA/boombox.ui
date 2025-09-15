import 'dart:async';

import 'package:boombox/commons_barrel.dart';

class KeepAliveService {
  late Timer _timer;
  late List<Function> _operations;

  static const _duration = Duration(seconds: 1);

  static final KeepAliveService _instance = KeepAliveService._internal();
  // using a factory is important
  // because it promises to return _an_ object of this type
  factory KeepAliveService() {
    return _instance;
  }
  // This named constructor is the "real" constructor
  // It'll be called exactly once, by the static property assignment above
  // it's also private, so it can only be called in this class
  KeepAliveService._internal() {
    _init();
  }

  Future<void> _init() async {
    _operations = [];
    _startTimer();
  }

  Future<void> dispose() async {
    _operations.clear();
    _timer.cancel();
    Logger.logAsync(
      LogEvent<KeepAliveService>(
        severity: Severity.information,
        tag: Tag.service,
        line: 'Global timer canceled.',
      ),
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(
      _duration,
      (timer) => _executeOperations(),
    );
    Logger.logAsync(
      LogEvent<KeepAliveService>(
        severity: Severity.information,
        tag: Tag.service,
        line: 'Global timer started.',
      ),
    );
  }

  Future<void> addTimedOperation(
    void Function() operation, {
    int? executionCount,
  }) async {
    _operations.add(operation);
    if (!_timer.isActive) _startTimer();
  }

  Future<void> _executeOperations() async {
    for (Function operation in _operations) {
      operation;
    }
  }
}
