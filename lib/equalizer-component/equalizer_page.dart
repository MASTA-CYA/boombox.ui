import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:boombox/common/functions.dart';
import 'package:boombox/common/widgets/appbar.dart';
import 'package:boombox/common/widgets/circular_progress_indicator.dart';
import 'package:boombox/equalizer-component/services/equalizer_service.dart';
import 'package:boombox/equalizer-component/widgets/equalizer_bands.dart';
import 'package:boombox/equalizer-component/widgets/equalizer_button.dart';
import 'package:boombox/equalizer-component/widgets/equalizer_textfield.dart';
import 'package:boombox/equalizer-component/widgets/profile_dropdown.dart';
import 'package:boombox/player-component/models/track_info_model.dart';
import 'package:boombox/player-component/services/player_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EqualizerPage extends StatefulWidget {
  const EqualizerPage({super.key});

  @override
  State<StatefulWidget> createState() => _EqualizerPage();
}

class _EqualizerPage extends State<EqualizerPage> {
  final String _title = 'Equalizer';

  final ValueNotifier<bool> _isCustomProfile = ValueNotifier<bool>(false);
  final ValueNotifier<int> _newProfileAdded = ValueNotifier<int>(0);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeSwitchingArea(
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBarWidget<EqualizerPage>(title: _title),
          drawer: null,
          body: Container(
            margin: EdgeInsets.symmetric(
              horizontal: Functions.horizontalScreenMargin(context),
              vertical: 10,
            ),
            child: _buildEqualizerScaffold(),
          ),
        ),
      ),
    );
  }

  Widget _buildEqualizerScaffold() {
    return FutureBuilder(
      future: Provider.of<PlayerService>(context, listen: false)
          .getAudioSessionIdAsync(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return FutureBuilder(
            future: Provider.of<EqualizerService>(context, listen: false)
                .initEqualizerAsync(snapshot.data!),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Column(
                  children: [
                    _buildActiveTrack(),
                    _buildProfileDropdown(),
                    _buildEqualizerBands(),
                    _buildCustomTextField(),
                    _buildButtonBar(),
                  ],
                );
              } else {
                return const CircularProgressIndicatorWidget();
              }
            },
          );
        } else {
          return const CircularProgressIndicatorWidget();
        }
      },
    );
  }

  Widget _buildActiveTrack() {
    return StreamBuilder(
      stream: Provider.of<PlayerService>(context).getSequenceStateStream,
      builder: (context, snapshot) {
        if (snapshot.data?.sequence.isEmpty ?? true) {
          return const CircularProgressIndicatorWidget();
        }

        var trackInfo = snapshot.data!.currentSource!.tag as TrackInfo;
        return Column(
          children: [
            ListTile(
              leading: trackInfo.art!.isNotEmpty
                  ? ClipRRect(
                      child: Image.memory(trackInfo.art!),
                    )
                  : ClipRRect(
                      child: Image.asset('assets/images/cd.png'),
                    ),
              title: Text(trackInfo.title!),
              subtitle: Text(trackInfo.artist!),
            ),
            const Divider(
              thickness: 1,
              indent: 20,
              endIndent: 20,
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileDropdown() {
    return ValueListenableBuilder(
      valueListenable: _newProfileAdded,
      builder: (context, value, child) => FutureBuilder(
        future: Provider.of<EqualizerService>(context, listen: false)
            .getPresetsAsync(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              child: ProfileDropdownWidget(
                label: 'Presets',
                profiles: mapSubCategoryProfileIcons(snapshot.data!),
                onProfileChanged: (profile) => _onProfileChanged(profile),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }

  Map<String, Widget> mapSubCategoryProfileIcons(List<String> filters) {
    Map<String, Widget> profileIcons = {};

    for (String key in filters) {
      switch (key) {
        case 'Flat':
          profileIcons.addAll(
            {
              key: const ImageIcon(
                ResizeImage(AssetImage('assets/images/flat.png'),
                    width: 70, height: 70, allowUpscaling: false),
                size: 20,
              ),
            },
          );
          break;
        case 'Bass Boost':
          profileIcons.addAll(
            {
              key: const ImageIcon(
                ResizeImage(AssetImage('assets/images/bass.png'),
                    width: 70, height: 70, allowUpscaling: false),
                size: 20,
              ),
            },
          );
          break;
        case 'Hip Hop':
          profileIcons.addAll(
            {
              key: const ImageIcon(
                ResizeImage(AssetImage('assets/images/hiphop.png'),
                    width: 70, height: 70, allowUpscaling: false),
                size: 20,
              ),
            },
          );
          break;
        case 'Rock':
          profileIcons.addAll(
            {
              key: const ImageIcon(
                ResizeImage(AssetImage('assets/images/rock.png'),
                    width: 70, height: 70, allowUpscaling: false),
                size: 20,
              ),
            },
          );
          break;
        case 'Jazz':
          profileIcons.addAll(
            {
              key: const ImageIcon(
                ResizeImage(AssetImage('assets/images/jazz.png'),
                    width: 70, height: 70, allowUpscaling: false),
                size: 20,
              ),
            },
          );
          break;
        default:
          profileIcons.addAll(
            {
              key: const ImageIcon(
                ResizeImage(AssetImage('assets/images/equalizer.png'),
                    width: 70, height: 70, allowUpscaling: false),
                size: 20,
              ),
            },
          );
          break;
      }
    }

    return profileIcons;
  }

  Widget _buildEqualizerBands() {
    return Consumer<EqualizerService>(
      builder: (context, service, child) => FutureBuilder(
        future: Future.wait(
          <Future>[
            service.getBandRangeAsync(),
            Future.delayed(
              const Duration(milliseconds: 500),
            ),
          ],
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ValueListenableBuilder(
              valueListenable: _isCustomProfile,
              builder: (context, isCustom, child) => Expanded(
                child: AnimatedContainer(
                  duration: const Duration(seconds: 1),
                  margin: isCustom
                      ? const EdgeInsets.symmetric(horizontal: 18)
                      : null,
                  child: child,
                ),
              ),
              child: EqualizerBandsWidget(bandRange: snapshot.data!.first),
            );
          } else {
            return const Expanded(child: CircularProgressIndicatorWidget());
          }
        },
      ),
    );
  }

  Widget _buildCustomTextField() {
    return ValueListenableBuilder(
      valueListenable: _isCustomProfile,
      builder: (context, isCustom, child) =>
          isCustom ? const EqualizerTextFieldWidget() : const SizedBox.shrink(),
    );
  }

  Widget _buildButtonBar() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ButtonBar(
        alignment: MainAxisAlignment.spaceBetween,
        children: [
          EqualizerButtonWidget(
            icon: const Icon(
              Icons.delete_sweep,
              size: 24.5,
            ),
            text: 'Reset',
            onPressed: () async => {},
          ),
          EqualizerButtonWidget(
            icon: const Icon(
              Icons.save,
              size: 24.5,
            ),
            text: 'Save',
            onPressed: () async => _onProfileSavedPressed(),
          ),
        ],
      ),
    );
  }

  void _onProfileChanged(String profile) async {
    _isCustomProfile.value = profile == 'Custom';
    await Provider.of<EqualizerService>(context, listen: false)
        .setPresetAsync(profile);
  }

  void _onProfileSavedPressed() async {
    _newProfileAdded.value = _newProfileAdded.value++;
  }
}
