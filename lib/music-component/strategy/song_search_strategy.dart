import 'package:boombox/common/extensions.dart';
import 'package:boombox/common/logger/enums/severity_enum.dart';
import 'package:boombox/common/logger/enums/tag_enum.dart';
import 'package:boombox/common/logger/logger.dart';
import 'package:boombox/common/logger/models/log_event_model.dart';
import 'package:boombox/music-component/models/song_model.dart';
import 'package:boombox/music-component/strategy/search_strategy_interface.dart';

class SongSearchStrategy implements SearchStrategy<Song> {
  @override
  Future<List<Song>> search(String? text, List<Song> media) async {
    try {
      if (text?.isNotEmpty ?? false) {
        media = media
            .where(
              (song) => song.name.containsIgnoreCase(text!),
            )
            .toList();
      }
    } on Exception catch (ex) {
      Logger.logAsync(
        LogEvent<SongSearchStrategy>(
          severity: Severity.error,
          tag: Tag.strategy,
          line: ex.toString(),
        ),
      );
    }

    return media;
  }
}
