import 'package:permission_handler/permission_handler.dart';

class PermissionsService {
  static Future<void> requestApplicationPermissionsAsync() async {
    if (!await Permission.storage.isGranted) {
      await Permission.storage.request();
    }
  }

  static Future<bool> areApplicationPermissionsGranted() async {
    return await Permission.storage.isGranted;
  }
}
