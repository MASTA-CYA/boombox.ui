import 'package:boombox/music-component/models/album_model.dart';

class MediaStoreService {
  static final MediaStoreService _instance = MediaStoreService._internal();
  // using a factory is important
  // because it promises to return _an_ object of this type
  factory MediaStoreService() {
    return _instance;
  }
  // This named constructor is the "real" constructor
  // It'll be called exactly once, by the static property assignment above
  // it's also private, so it can only be called in this class

  MediaStoreService._internal() {}

  Future<List<Album>> getAlbumsAsync() async {
    return [];
  }
}
