import 'dart:math';
import 'package:boombox/equalizer-component/services/equalizer_service.dart';
import 'package:flutter/material.dart';
import 'package:boombox/equalizer-component/widgets/vertical_slider.dart';
import 'package:provider/provider.dart';

class EqualizerBandsWidget extends StatefulWidget {
  final List<int> bandRange;
  const EqualizerBandsWidget({
    super.key,
    required this.bandRange,
  });

  @override
  State<StatefulWidget> createState() => _EqualizerBandsWidget();
}

class _EqualizerBandsWidget extends State<EqualizerBandsWidget> {
  late Map<int, double> bands;

  @override
  void initState() {
    super.initState();
    bands = {};

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        if (mounted) {
          bands = await Provider.of<EqualizerService>(context, listen: false)
              .getActiveBandLevelsAsync();
          setState(() {});
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildFrequencyBands();
  }

  Widget _buildFrequencyBands() {
    return Transform.rotate(
      angle: 270 * (pi / 180),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: bands.entries.map((e) => _buildBandSlider(e)).toList(),
        ),
      ),
    );
  }

  Widget _buildBandSlider(MapEntry<int, double> band) {
    return VerticalSlider.adaptive(
      // key: UniqueKey(),
      min: widget.bandRange.first.toDouble(),
      max: widget.bandRange.last.toDouble(),
      value: band.value,
      onChanged: (level) async => _onBandSliderChanged(band.key, level),
    );
  }

  void _onBandSliderChanged(int bandId, double level) async {
    bands.update(bandId, (value) => level);
    // await Provider.of<EqualizerService>(context, listen: false)
    //     .setBandLevel(bandId, level.toInt());
    setState(
      () {},
    );
  }
}
