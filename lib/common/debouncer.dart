import 'package:boombox/common/extensions.dart';
import 'dart:async';

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({required this.milliseconds});

  void run(Function(DateTime timestamp) action) {
    _timer?.cancel();
    _timer = Timer(
      Duration(milliseconds: milliseconds),
      () => action(DateTime.now()),
    );
  }

  Timer? runAnimation(Function(DateTime timestamp) action) {
    _timer?.cancel();
    _timer = Timer(
      Duration(milliseconds: milliseconds),
      () => action(DateTime.now()),
    );
    return _timer;
  }

  void dispose() {
    if (!_timer.isNull) _timer!.cancel();
  }
}
