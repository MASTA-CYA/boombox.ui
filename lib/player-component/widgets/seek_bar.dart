import 'package:boombox/common/debouncer.dart';
import 'package:boombox/player-component/services/trim_audio_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class SeekBarWidget extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final Duration bufferedPosition;
  final ValueChanged<Duration>? onValueChanged;
  final ValueChanged<Duration>? onChangeEnd;
  final ValueChanged<List<Duration>>? onRangeValueChanged;

  const SeekBarWidget({
    super.key,
    required this.duration,
    required this.position,
    required this.bufferedPosition,
    this.onValueChanged,
    this.onChangeEnd,
    this.onRangeValueChanged,
  });

  @override
  State<StatefulWidget> createState() => _SeekBarWidget();
}

class _SeekBarWidget extends State<SeekBarWidget> {
  late DateFormat _dateFormat;
  late String _playerPosition;
  late String _trackDuration;
  late String _clipStartDuration;
  late String _clipEndDuration;

  final ValueNotifier<bool> _isInClipMode = ValueNotifier<bool>(false);
  final ValueNotifier<bool> _canUpdateClipDuration = ValueNotifier<bool>(false);
  late Debouncer _debouncer;

  @override
  void initState() {
    super.initState();
    _dateFormat = widget.duration.inMinutes > 60
        ? DateFormat('HH:mm:ss')
        : DateFormat('mm:ss');
    _playerPosition = _dateFormat.format(
      DateTime.fromMillisecondsSinceEpoch(
        widget.position.inMilliseconds,
        isUtc: true,
      ),
    );
    _trackDuration = _dateFormat.format(
      DateTime.fromMillisecondsSinceEpoch(
        widget.duration.inMilliseconds,
        isUtc: true,
      ),
    );
    _clipStartDuration = _dateFormat.format(
      DateTime.fromMillisecondsSinceEpoch(
        0,
        isUtc: true,
      ),
    );
    _clipEndDuration = _trackDuration;
    _debouncer = Debouncer(milliseconds: 100);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildSeekBar(),
        _buildTrackTime(),
      ],
    );
  }

  Widget _buildSeekBar() {
    final double max = widget.duration.inMilliseconds.toDouble();
    final double position = widget.position.inMilliseconds.toDouble();

    return StreamBuilder(
      stream: Provider.of<TrimAudioService>(
        context,
      ).getClipModeStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return FutureBuilder(
            future: Provider.of<TrimAudioService>(
              context,
              listen: false,
            ).getClipModeAsync(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!) {
                _redrawClipModeDuration(snapshot.data!);
                return StreamBuilder(
                  stream: Provider.of<TrimAudioService>(context)
                      .getTrimmedAudioStream,
                  builder: (context, snapshot) => !snapshot.hasData
                      ? FutureBuilder(
                          future: Provider.of<TrimAudioService>(
                            context,
                            listen: false,
                          ).getTrimmedAudioDataAsync(),
                          builder: (context, snapshot) => RangeSlider(
                            min: 0.0,
                            max: max,
                            values: RangeValues(
                              snapshot.data?.start?.inMilliseconds.toDouble() ??
                                  0.0,
                              (snapshot.data?.end?.inMilliseconds.toDouble() ??
                                          max) ==
                                      0
                                  ? max
                                  : snapshot.data?.end?.inMilliseconds
                                          .toDouble() ??
                                      max,
                            ),
                            // labels: RangeLabels(position, max),
                            onChanged: (value) =>
                                _onSliderRangeValueChanged(value),
                          ),
                        )
                      : RangeSlider(
                          min: 0.0,
                          max: max,
                          values: RangeValues(
                            snapshot.data?.start?.inMilliseconds.toDouble() ??
                                0.0,
                            (snapshot.data?.end?.inMilliseconds.toDouble() ??
                                        max) ==
                                    0
                                ? max
                                : snapshot.data?.end?.inMilliseconds
                                        .toDouble() ??
                                    max,
                          ),
                          // labels: RangeLabels(position, max),
                          onChanged: (value) =>
                              _onSliderRangeValueChanged(value),
                        ),
                );
              } else {
                return Slider.adaptive(
                  min: 0.0,
                  max: max,
                  value: position > max ? max : position,
                  onChanged: (value) => _onSliderValueChanged(value),
                );
              }
            },
          );
        } else {
          _redrawClipModeDuration(snapshot.data!);
          return snapshot.data!
              ? RangeSlider(
                  min: 0.0,
                  max: max,
                  values: RangeValues(position, max),
                  // labels: RangeLabels(position, max),
                  onChanged: (value) => _onSliderRangeValueChanged(value),
                )
              : Slider.adaptive(
                  min: 0.0,
                  max: max,
                  value: position > max ? max : position,
                  onChanged: (value) => _onSliderValueChanged(value),
                );
        }
      },
    );
  }

  Widget _buildTrackTime() {
    return Column(
      children: [
        ValueListenableBuilder(
          valueListenable: _isInClipMode,
          builder: (context, isActive, child) => isActive
              ? ValueListenableBuilder(
                  valueListenable: _canUpdateClipDuration,
                  builder: (context, canUpdate, child) => Container(
                    key: UniqueKey(),
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _clipStartDuration,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary),
                        ),
                        Text(
                          _clipEndDuration,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary),
                        ),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_playerPosition),
              Text(_trackDuration),
            ],
          ),
        ),
      ],
    );
  }

  void _onSliderValueChanged(double value) async {
    Duration duration = Duration(milliseconds: value.round());
    _playerPosition = _dateFormat.format(
      DateTime.fromMillisecondsSinceEpoch(duration.inMilliseconds, isUtc: true),
    );
    widget.onValueChanged!(duration);
  }

  void _onSliderRangeValueChanged(RangeValues value) {
    Duration start = Duration(milliseconds: value.start.round());
    Duration end = Duration(milliseconds: value.end.round());
    _playerPosition = _dateFormat.format(
      DateTime.fromMillisecondsSinceEpoch(
        start.inMilliseconds,
        isUtc: true,
      ),
    );
    _clipStartDuration = _dateFormat.format(
      DateTime.fromMillisecondsSinceEpoch(
        start.inMilliseconds,
        isUtc: true,
      ),
    );
    _clipEndDuration = _dateFormat.format(
      DateTime.fromMillisecondsSinceEpoch(
        end.inMilliseconds,
        isUtc: true,
      ),
    );
    _canUpdateClipDuration.value = !_canUpdateClipDuration.value;
    widget.onRangeValueChanged!([start, end]);
  }

  void _redrawClipModeDuration(bool isActive) {
    _debouncer.run(
      (timestamp) {
        _isInClipMode.value = isActive;
      },
    );
  }
}
