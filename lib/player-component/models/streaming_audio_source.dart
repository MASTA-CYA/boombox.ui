import 'dart:io';
import 'package:just_audio/just_audio.dart';
import 'package:audio_decoder/audio_decoder.dart';

class StreamingAudioSource extends StreamAudioSource {
  final String path;

  StreamingAudioSource(this.path, {super.tag});

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    // Decode FLAC to raw PCM/WAV
    final rawBytes = await AudioDecoder.convertToM4aBytes(
      await File(path).readAsBytes(),
      formatHint: 'wav',
    );

    final startOffset = start ?? 0;
    final endOffset = end ?? rawBytes.length;
    final length = endOffset - startOffset;

    // Use a view instead of a sublist to avoid creating a second copy of the data
    final slicedBytes = rawBytes.buffer.asUint8List(startOffset, length);

    return StreamAudioResponse(
      stream: Stream.value(slicedBytes),
      sourceLength: rawBytes.length,
      contentLength: length,
      offset: startOffset,
      contentType: 'audio/wav',
    );
  }

  Future<String> _covertToM4AAsync(String oldPath) async {
    try {
      final lastSeparator = oldPath.lastIndexOf(Platform.pathSeparator);
      final directory = oldPath.substring(0, lastSeparator + 1);
      final fileNameWithExt = oldPath.substring(lastSeparator + 1);

      final dotIndex = fileNameWithExt.lastIndexOf('.');
      final baseName =
          dotIndex == -1
              ? fileNameWithExt
              : fileNameWithExt.substring(0, dotIndex);
      final newPath = '$directory$baseName.wav';
      return await AudioDecoder.convertToM4a(oldPath, newPath);
    } on AudioConversionException catch (e) {
      print('Decoding failed: $e');
      return oldPath;
    }
  }
}
