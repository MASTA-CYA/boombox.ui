import 'dart:ui';

enum TransitionDirection {
  /// Right to Left
  rtl,

  /// Left to Right
  ltr,

  /// Top to Bottom
  ttb,

  /// Bottom to Top
  btt;

  factory TransitionDirection.fromName(String name) =>
      TransitionDirectionExtension.getTransitionDirectionFromName(name);
}

extension TransitionDirectionExtension on TransitionDirection {
  Offset get offset => _getOffset();

  Offset _getOffset() {
    Offset offset = const Offset(0.0, 0.0);

    switch (this) {
      case TransitionDirection.ltr:
        offset = const Offset(1.0, 0.0);
        break;
      case TransitionDirection.rtl:
        offset = const Offset(-1.0, 0.0);
        break;
      case TransitionDirection.ttb:
        offset = const Offset(0.0, -1.0);
        break;
      case TransitionDirection.btt:
        offset = const Offset(0.0, 1.0);
        break;
    }

    return offset;
  }

  static TransitionDirection getTransitionDirectionFromName(String name) {
    TransitionDirection direction;

    switch (name) {
      case 'ltr':
        direction = TransitionDirection.ltr;
        break;
      case 'rtl':
        direction = TransitionDirection.rtl;
        break;
      case 'ttb':
        direction = TransitionDirection.ttb;
        break;
      case 'btt':
        direction = TransitionDirection.btt;
        break;
      default:
        direction = TransitionDirection.ltr;
        break;
    }

    return direction;
  }
}
