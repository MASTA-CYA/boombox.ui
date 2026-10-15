import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  /// Requests every storage/media permission the app actually relies on.
  ///
  /// The app scans user-picked folders using raw `dart:io` File/Directory
  /// calls rather than the MediaStore content-resolver API. On Android 11+
  /// (scoped storage), that kind of arbitrary-folder access requires
  /// MANAGE_EXTERNAL_STORAGE ("All files access") - without it, a raw
  /// directory listing on a folder the app doesn't own can silently come
  /// back empty instead of throwing, which looks like "no music found"
  /// rather than a permissions problem.
  ///
  /// MANAGE_EXTERNAL_STORAGE can't be granted through a normal runtime
  /// dialog - requesting it sends the user to a dedicated system Settings
  /// screen where they flip the toggle by hand, and control returns to the
  /// app asynchronously. Because of that, this method may return before
  /// the grant is actually reflected; callers that need to react to the
  /// grant (e.g. re-scanning folders) should re-check
  /// [areApplicationPermissionsGranted] when the app resumes, rather than
  /// trusting the immediate result of this call.
  static Future<void> requestApplicationPermissionsAsync() async {
    if (!Platform.isAndroid) return;

    // Android 13+ (API 33+): granular media permission.
    if (!await Permission.audio.isGranted) {
      await Permission.audio.request();
    }

    // Android <= 12 (API <= 32): legacy storage permission.
    if (!await Permission.storage.isGranted) {
      await Permission.storage.request();
    }

    // Android 11+: required for raw filesystem access to folders the app
    // doesn't own. Opens a system Settings screen rather than a dialog.
    if (!await Permission.manageExternalStorage.isGranted) {
      await Permission.manageExternalStorage.request();
    }
  }

  static Future<bool> areApplicationPermissionsGranted() async {
    if (!Platform.isAndroid) return true;

    final bool hasMediaAccess =
        await Permission.audio.isGranted || await Permission.storage.isGranted;
    final bool hasManageExternalStorage =
        await Permission.manageExternalStorage.isGranted;

    return hasMediaAccess && hasManageExternalStorage;
  }
}
