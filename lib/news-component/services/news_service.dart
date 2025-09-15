import 'dart:async';
import 'dart:io';

import 'package:boombox/common/debouncer.dart';
import 'package:boombox/common/models/persistable_service.dart';
import 'package:boombox/common/models/serializable_model.dart';
import 'package:boombox/common/services/file_storage_service.dart';
import 'package:boombox/common/services/shared_preferences_service.dart';
import 'package:boombox/commons_barrel.dart';
import 'package:boombox/news-component/models/news_feed_article_model.dart';
import 'package:boombox/news-component/models/news_feed_story_model.dart';
import 'package:boombox/news-component/strategy/billboard_strategy.dart';
import 'package:boombox/news-component/strategy/news_provider_context.dart';
import 'package:boombox/settings-component/models/news_source_model.dart';
import 'package:boombox/settings-component/services/user_settings_service.dart';

class NewsService with ChangeNotifier implements PersistableService {
  late SharedPreferencesService _preferences;
  late List<NewsFeedStory> _newsFeedStories;
  late List<SerializableModel<NewsSource>> _newsSources;
  late NewsProvider _newsProvider;
  late Debouncer _debouncer;
  late bool _canRefreshFeedStories;
  late bool _isServiceActive;
  late StreamSubscription<bool> _isServiceActiveSubscription;

  NewsFeedArticle? _activeArticle;

  static const String _NEWS_SOURCES_KEY = 'NEWSSOURCES';

  static final NewsService _instance = NewsService._internal();
  // using a factory is important
  // because it promises to return _an_ object of this type
  factory NewsService() {
    return _instance;
  }
  // This named constructor is the "real" constructor
  // It'll be called exactly once, by the static property assignment above
  // it's also private, so it can only be called in this class
  NewsService._internal() {
    _init();
  }

  @override
  void dispose() async {
    _isServiceActiveSubscription.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    _preferences = SharedPreferencesService();
    _debouncer = Debouncer(milliseconds: 60000);
    _newsProvider = NewsProvider();
    _canRefreshFeedStories = false;
    _isServiceActive = false;
    _newsFeedStories = [];
    _newsSources = [];

    _getUserSelectedNewsSourcesAsync();
    _isServiceActiveSubscription =
        UserSettingsService().getCanFetchNewsStream.listen(
      (isActive) {
        _isServiceActive = isActive;
        if (!_isServiceActive) {
          for (SerializableModel<NewsSource> source
              in List.from(_newsSources)) {
            _newsSources.modifyElement(
              find: (element) => element.model.name.equals(source.model.name),
              property: 'isSelected',
              value: source.model.name.equals('Billboard'),
            );
          }
        }

        notifyListeners();
      },
    );
  }

  Future<List<NewsFeedStory>> getNewsFeedStoriesAsync() async {
    if (_newsFeedStories.isNotEmpty) return _newsFeedStories;
    _canRefreshFeedStories = false;

    final List<String> sources = _getSelectedNewsSources();
    for (String source in sources) {
      _configureStrategy(source);
      _newsFeedStories.addAll(await _newsProvider.getNewsStoriesAsync());
    }
    _startRefreshTimer();

    return _newsFeedStories;
  }

  Future<NewsFeedArticle?> getNewsFeedStoryAsync(
      String website, String url) async {
    if (!_activeArticle.isNull) return _activeArticle;
    NewsFeedArticle? article;

    _configureStrategy(website.split('.').elementAt(1));
    article = await _newsProvider.getNewsStoryAsync(url);
    _activeArticle = article;

    return article;
  }

  void _configureStrategy(String source) {
    switch (source) {
      case 'Billboard':
        final BillboardStrategy strategy = BillboardStrategy();
        _newsProvider.setStrategy = strategy;
        break;
      default:
        break;
    }
  }

  Future<void> refreshNewsFeedAsync() async {
    if (_canRefreshFeedStories) notifyListeners();
  }

  void _startRefreshTimer() {
    _debouncer.run((timestamp) => _canRefreshFeedStories = true);
  }

  Future<List<SerializableModel<NewsSource>>> getNewsSourcesAsync() async {
    if (_newsSources.isEmpty) {
      await _getUserSelectedNewsSourcesAsync();
    }

    return _newsSources;
  }

  Future<void> _getUserSelectedNewsSourcesAsync() async {
    try {
      _newsSources = NewsSource.decode(
        await _preferences.readAsync(_NEWS_SOURCES_KEY),
      );
    } on Exception {
      String? result = await FileStorageService.readAsync<NewsSource>();
      if (!result.isNull) {
        _newsSources = NewsSource.decode(result!);
      }
    } finally {
      if (_newsSources.isEmpty) {
        _newsSources = [
          const NewsSource(
            image: 'https://www.billboard.com/wp-content/themes/vip'
                '/pmc-billboard-2021/assets/app/icons/icon-512x512.png',
            name: 'Billboard',
            url: 'www.billboard.com',
            isSelected: true,
          ),
          const NewsSource(
            image: 'https://media.pitchfork.com/photos/'
                '5931d7cd4fc0406ca110bbea/2:1/w_2560%2Cc_limit/15fd4b8c.jpg',
            name: 'Pitchfork ',
            url: 'www.pitchfork.com',
          ),
          const NewsSource(
            image: 'https://cdns-images.dzcdn.net/images/artist/'
                '2ceac184bc846327f60c5b0d4247cc7a/500x500.jpg',
            name: 'RollingStone',
            url: 'www.rollingstone.com',
          ),
        ];
      } else if (!await _hasSelectedNewsSources()) {
        _newsSources.modifyElement(
          find: (element) => element.model.name.equals('Billboard'),
          property: 'isSelected',
          value: true,
        );
      }
    }
  }

  Future<void> updateNewsSourceAsync(NewsSource source, bool isSelected) async {
    _newsSources.modifyElement(
      find: (element) => element.model.name.equals(source.name),
      property: 'isSelected',
      value: isSelected,
    );
    await saveChangesAsync<NewsSource>(shouldNotifyListeners: true);
  }

  Future<bool> _hasSelectedNewsSources() async {
    return _newsSources.where((source) => source.model.isSelected).isNotEmpty;
  }

  List<String> _getSelectedNewsSources() {
    return _newsSources
        .where((source) => source.model.isSelected)
        .toList()
        .map((e) => e.model.name)
        .toList();
  }

  Future<bool> isNewsServiceActive() async {
    return _isServiceActive;
  }

  @override
  Future<void> saveChangesAsync<T>({
    bool shouldNotifyListeners = false,
  }) async {
    try {
      String? json = _jsonEncodeModel<T>();
      if (json.isNull) throw Exception('Failed to encode model $T');

      await _saveToPreferences<T>(json!);
      await _saveToStorage<T>(json);
      if (shouldNotifyListeners) notifyListeners();
    } on Exception catch (ex) {
      await Logger.logAsync(
        LogEvent<T>(
          severity: Severity.error,
          tag: Tag.service,
          line: ex.toString(),
        ),
      );
    }
  }

  String? _jsonEncodeModel<T>() {
    switch (T) {
      case NewsSource:
        return NewsSource.encode(_newsSources.map((e) => e.model).toList());
      default:
        return null;
    }
  }

  Future<void> _saveToPreferences<T>(String json) async {
    try {
      await _preferences.saveAsync(_NEWS_SOURCES_KEY, json);
    } on Exception catch (ex) {
      await Logger.logAsync(
        LogEvent<T>(
          severity: Severity.error,
          tag: Tag.service,
          line: ex.toString(),
        ),
      );
    }
  }

  Future<void> _saveToStorage<T>(String json) async {
    await FileStorageService.writeStringAsync<T>(
      json,
      mode: FileMode.writeOnly,
    );
  }
}
