enum SnackbarDuration {
  short,
  long,
  infinite,
}

extension SnackbarDurationExtension on SnackbarDuration {
  Duration get duration => _getDuration();

  Duration _getDuration() {
    Duration duration;
    switch (this) {
      case SnackbarDuration.short:
        duration = const Duration(seconds: 2);
        break;
      case SnackbarDuration.long:
        duration = const Duration(seconds: 8);
        break;
      case SnackbarDuration.infinite:
        duration = const Duration(days: 365);
        break;
    }

    return duration;
  }
}
