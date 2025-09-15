import 'package:audio_service/audio_service.dart';
import 'package:boombox/common/models/serializable_model.dart';
import 'package:boombox/commons_barrel.dart';
import 'package:just_audio/just_audio.dart' as audio;

extension StringNullableExtensions on String? {
  bool isNullOrEmpty() => (this?.isEmpty ?? true) || isNull;
}

extension StringExtensions on String {
  /// Returns an empty string
  String get empty => '';

  /// Extension that checks if string a contains string b. [ignoreCase] defaults to true.
  bool containsIgnoreCase(String other, {bool ignoreCase = true}) =>
      toLowerCase().contains(RegExp(other.toLowerCase()));

  /// Extension that equates two string. [ignoreCase] defaults to true.
  bool equals(String other, {bool ignoreCase = true}) =>
      toLowerCase() == other.toLowerCase();

  /// Extension that capitalizes the first letter of the target string.
  String capitalize() {
    List<String> letters = characters.toList();
    String capital = letters.elementAt(0).toUpperCase();
    letters.removeAt(0);
    letters.insert(0, capital);

    return letters.join();
  }
}

extension IntExtensions on int {
  bool get isZero => this == 0;
}

extension DoubleExtensions on double {
  bool get isZero => this == 0;
}

extension ObjectExtensions on Object? {
  /// Checks if the object is null
  bool get isNull => this == null;

  /// Extension that equates two string. [ignoreCase] defaults to true.
  bool equals(Object? other) {
    return this == other;
  }
}

extension SerializableModelExtensions<T> on SerializableModel<T> {
  // T get model => this.model;
}

extension SerializableListExtensions<T extends SerializableModel> on List<T> {
  /// Replaces an element in the list. If element is not found and [orElse] is null, no element will be replaced.
  /// [find] - The function used find the the element to be replaced
  /// [orElse] (Optional) - Used if no element is found using [find]
  /// [property] - The property on the model to be modified
  /// [value] - The value to be assigned to the property
  /// [shouldThrowError] - Rethrows any errors caught during the operation
  void modifyElement({
    required bool Function(T element) find,
    T Function()? orElse,
    required String property,
    required dynamic value,
    bool? shouldThrowError = false,
  }) {
    T current;
    try {
      current = firstWhere(
        (element) => find(element),
        orElse: orElse,
      );

      if (!current.keys.contains(property)) {
        throw Exception('Property dies not exist in the model: $T');
      }

      current = current.modifyProperty(property, value);
      replaceElement(find: find, element: current);
    } catch (ex) {
      Logger.logAsync(
        LogEvent<List<T>>(
          severity: Severity.error,
          tag: Tag.extension,
          line: ex.toString(),
        ),
      );
      if (shouldThrowError!) rethrow;
    }
  }
}

extension ListExtensions<T> on List<T> {
  /// Replaces an element in the list. If element is not found and [orElse] is null, no element will be replaced.
  /// [find] - The function used find the the element to be replaced
  /// [element] - New element that will replace old element
  /// [orElse] (Optional) - Used if no element is found using [find]
  /// [shouldThrowError] - Rethrows any errors caught during the operation
  void replaceElement({
    required bool Function(T element) find,
    required T element,
    T Function()? orElse,
    bool? shouldThrowError = false,
  }) {
    T current;
    try {
      current = firstWhere(
        (element) => find(element),
        orElse: orElse,
      );
      int index = indexOf(current);
      removeAt(index);
      insert(index, element);
    } catch (ex) {
      Logger.logAsync(
        LogEvent<List<T>>(
          severity: Severity.error,
          tag: Tag.extension,
          line: ex.toString(),
        ),
      );
      if (shouldThrowError!) rethrow;
    }
  }
}

extension ConnectionStateExtension on ConnectionState {
  bool equals(ConnectionState other) => this == other;
}

extension AudioProcessingStateExtension on AudioProcessingState {
  AudioProcessingState fromProcessingState(audio.ProcessingState state) {
    switch (state) {
      case audio.ProcessingState.idle:
        return AudioProcessingState.idle;
      case audio.ProcessingState.loading:
        return AudioProcessingState.loading;
      case audio.ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case audio.ProcessingState.ready:
        return AudioProcessingState.ready;
      case audio.ProcessingState.completed:
        return AudioProcessingState.completed;
    }
  }
}
