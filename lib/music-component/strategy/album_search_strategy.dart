import 'package:boombox/common/logger/enums/severity_enum.dart';
import 'package:boombox/common/logger/enums/tag_enum.dart';
import 'package:boombox/common/logger/logger.dart';
import 'package:boombox/common/logger/models/log_event_model.dart';
import 'package:boombox/music-component/models/album_model.dart';
import 'package:boombox/music-component/strategy/search_strategy_interface.dart';

class AlbumSearchStrategy implements SearchStrategy<Album> {
  @override
  Future<List<Album>> search(String? text, List<Album> media) async {
    try {
      if (text?.isNotEmpty ?? false) {
        media = media
            .where(
              (song) => song.name.toLowerCase().contains(text!.toLowerCase()),
            )
            .toList();
      }
    } on Exception catch (ex) {
      Logger.logAsync(
        LogEvent<AlbumSearchStrategy>(
          severity: Severity.error,
          tag: Tag.strategy,
          line: ex.toString(),
        ),
      );
    }

    return media;
  }
}
