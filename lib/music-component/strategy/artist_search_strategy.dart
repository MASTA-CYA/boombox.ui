import 'package:boombox/common/logger/enums/severity_enum.dart';
import 'package:boombox/common/logger/enums/tag_enum.dart';
import 'package:boombox/common/logger/logger.dart';
import 'package:boombox/common/logger/models/log_event_model.dart';
import 'package:boombox/music-component/models/artist_model.dart';
import 'package:boombox/music-component/strategy/search_strategy_interface.dart';

class ArtistSearchStrategy implements SearchStrategy<Artist> {
  @override
  Future<List<Artist>> search(String? text, List<Artist> media) async {
    try {
      if (text?.isNotEmpty ?? false) {
        media = media
            .where(
              (artist) => artist.name.toLowerCase().contains(text!.toLowerCase()),
            )
            .toList();
      }
    } on Exception catch (ex) {
      Logger.logAsync(
        LogEvent<ArtistSearchStrategy>(
          severity: Severity.error,
          tag: Tag.strategy,
          line: ex.toString(),
        ),
      );
    }

    return media;
  }
}
