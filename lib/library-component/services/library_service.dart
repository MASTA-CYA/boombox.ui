import 'package:boombox/common/service-bus/models/message_subscriber_interface.dart';
import 'package:boombox/common/service-bus/service_bus.dart';
import 'package:boombox/commons_barrel.dart';
import 'package:boombox/library-component/models/application_feature_model.dart';
import 'package:boombox/services_barrel.dart';

class LibraryService with ChangeNotifier implements MessageSubscriber {
  static const String _MAPPING_STATUS = 'LIBRARY_MAPPING_STATUS';

  late List<ApplicationFeature> _features;
  static final LibraryService _instance = LibraryService._internal();
  // using a factory is important
  // because it promises to return _an_ object of this type
  factory LibraryService() {
    return _instance;
  }
  // This named constructor is the "real" constructor
  // It'll be called exactly once, by the static property assignment above
  // it's also private, so it can only be called in this class
  LibraryService._internal() {
    _init();
  }

  Future<void> _init() async {
    await ServiceBus().registerMessageSubscriberAsync(
      _MAPPING_STATUS,
      'LibraryService',
    );
    _features = await _populateFeatures();
    UserSettingsService().getEnabledFeaturesStream.listen(
      (features) async {
        _features = await _populateFeatures();
        notifyListeners();
      },
    );
  }

  Future<List<ApplicationFeature>> getApplicationFeaturesAsync() async {
    _features.shuffle();
    return _features;
  }

  Future<List<ApplicationFeature>> _populateFeatures() async {
    return [
      ApplicationFeature(
        icon: 'assets/images/lyrics.png',
        name: 'Lyrics',
        description: 'This feature scrapes the '
            'Genius website for lyrics. '
            'The lyrics are saved locally or to Eternal Storage (if enabled) '
            'so that they are only download only once.',
        isEnabled: await UserSettingsService().getCanSaveLyricsLocallyAsync(),
      ),
      ApplicationFeature(
        icon: 'assets/images/eternal.png',
        name: 'Eternal Storage',
        description: 'This feature ensure that '
            'application data is retained after the '
            'application is uninstalled.',
        isEnabled: await UserSettingsService().getUseEternalStorageAsync(),
      ),
      ApplicationFeature(
        icon: 'assets/images/download.png',
        name: 'Download Media',
        description: 'This feature uses the '
            'Google Search Engine and Discogs API '
            ' to download missing media and meta data.',
        isEnabled: await UserSettingsService().getCanDownloadArtistMediaAsync(),
      ),
      ApplicationFeature(
        icon: 'assets/images/equalizer-1.png',
        name: 'Smart Equalizer',
        description: 'This feature activates the equalizer '
            'presets based on the playing track\'s genre. '
            'The Discogs API is used to download missing '
            'media and meta data.',
        isEnabled: await UserSettingsService().getUseSmartEqualizerAsync(),
      ),
      const ApplicationFeature(
        icon: 'assets/images/theme.png',
        name: 'Customize Themes',
        description: 'This feature allows you to customize '
            'the application\'s background images '
            'and their colors.',
      ),
      const ApplicationFeature(
        icon: 'assets/images/message.png',
        name: 'Messages',
        description: 'This feature gives you a view into the '
            'application\'s performance and important behaviors. '
            'You can then either dismiss the message or report it '
            'to the developer.',
      ),
      const ApplicationFeature(
        icon: 'assets/images/equalizer.png',
        name: 'Equalizer',
        description:
            'This feature gives you finer control over the device equalizer '
            'You can create custom presets and set them either on a global '
            'level or per individual track. The equalizer will '
            'automatically save the preset against the track and '
            'apply it when the track is played.',
      ),
      ApplicationFeature(
        icon: 'assets/images/newspaper.png',
        name: 'News',
        description: 'This feature scapes news bulletins from sites such as '
            'Billboard and Rolling Stone.',
        isEnabled: await UserSettingsService().getCanFetchNewsAsync(),
      ),
    ];
  }

  @override
  Future<void> handleMessageAsync<T>(String name, T message) async {
    debugPrint(message.toString());
  }
}
