import 'package:background_fetch/background_fetch.dart';
import 'package:boombox/common/logger/enums/severity_enum.dart';
import 'package:boombox/common/logger/enums/tag_enum.dart';
import 'package:boombox/common/logger/logger.dart';
import 'package:boombox/common/logger/models/log_event_model.dart';

class BackgroundService {
  static final _backgroundConfig = BackgroundFetchConfig(
    minimumFetchInterval: 15,
    stopOnTerminate: false,
    enableHeadless: true,
    requiresBatteryNotLow: false,
    requiresCharging: false,
    requiresStorageNotLow: false,
    requiresDeviceIdle: false,
    requiredNetworkType: NetworkType.NONE,
    startOnBoot: true,
  );

  static final BackgroundService _instance = BackgroundService._internal();
// using a factory is important
// because it promises to return _an_ object of this type
  factory BackgroundService() {
    return _instance;
  }
// This named constructor is the "real" constructor
// It'll be called exactly once, by the static property assignment above
// it's also private, so it can only be called in this class
  BackgroundService._internal() {
    Logger.logAsync(
      LogEvent<BackgroundService>(
        severity: Severity.information,
        tag: Tag.service,
        line: 'Starting up...',
      ),
    );
    _configureService();
    BackgroundFetch.registerHeadlessTask(_backgroundFetchHeadlessTask);
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _configureService() async {
    // Configure BackgroundFetch.
    // ignore: unused_local_variable
    int status = await BackgroundFetch.configure(
      _backgroundConfig,
      (taskId) => _onBackgroundFetch(taskId),
      (taskId) => _onTimeout(taskId),
    );
  }

  @pragma('vm:entry-point')
  static void _backgroundFetchHeadlessTask(HeadlessTask task) async {
    String taskId = task.taskId;
    bool isTimeout = task.timeout;
    if (isTimeout) {
      // This task has exceeded its allowed running-time.
      // You must stop what you're doing and immediately .finish(taskId)
      Logger.logAsync(
        LogEvent<BackgroundService>(
          severity: Severity.information,
          tag: Tag.service,
          line: 'Task $taskId timed out',
        ),
      );
      BackgroundFetch.finish(taskId);
      return;
    }

    // Do your work here...
    Logger.logAsync(
      LogEvent<BackgroundService>(
        severity: Severity.information,
        tag: Tag.service,
        line: 'I am a background task',
      ),
    );
    BackgroundFetch.finish(taskId);
  }

  Future<void> _onBackgroundFetch(String taskId) async {
    try {
      Logger.logAsync(
        LogEvent<BackgroundService>(
          severity: Severity.information,
          tag: Tag.service,
          line: 'Preparing to dump log file',
        ),
      );
      await Logger.dumpLogFileAsync();
    } on Exception catch (ex, stacktrace) {
      Logger.logAsync(
        LogEvent<BackgroundService>(
            severity: Severity.error,
            tag: Tag.service,
            line: ex.toString(),
            stacktrace: stacktrace),
      );
    }
    BackgroundFetch.finish(taskId);
  }

  Future<void> _onTimeout(String taskId) async {
    Logger.logAsync(
      LogEvent<BackgroundService>(
        severity: Severity.information,
        tag: Tag.service,
        line: 'Task $taskId timed out',
      ),
    );
    BackgroundFetch.finish(taskId);
  }
}
