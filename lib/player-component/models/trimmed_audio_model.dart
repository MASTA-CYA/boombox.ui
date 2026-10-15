import 'dart:convert' as convert;

class TrimmedAudio {
  final String path;
  final Duration? start;
  final Duration? end;

  TrimmedAudio({
    required this.path,
    this.start,
    this.end,
  });

  factory TrimmedAudio.fromJson(Map<String, dynamic> json) => TrimmedAudio(
        path: json['path'],
        start: Duration(milliseconds: int.tryParse(json['start']) ?? 0),
        end: Duration(milliseconds: int.tryParse(json['end']) ?? 0),
      );

  static Map<String, dynamic> toJson(TrimmedAudio song) => {
        'path': song.path,
        'start': song.start?.inMilliseconds.toString(),
        'end': song.end?.inMilliseconds.toString(),
      };

  static String encode(List<TrimmedAudio> songs) => convert.json.encode(
        songs
            .map<Map<String, dynamic>>((song) => TrimmedAudio.toJson(song))
            .toList(),
      );

  static List<TrimmedAudio> decode(String jsonString) =>
      (convert.json.decode(jsonString) as List<dynamic>)
          .map<TrimmedAudio>((song) => TrimmedAudio.fromJson(song))
          .toList();
}
