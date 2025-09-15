import 'package:boombox/commons_barrel.dart';
import 'package:boombox/news-component/models/news_feed_article_model.dart';
import 'package:boombox/news-component/models/news_feed_story_model.dart';
import 'package:boombox/news-component/strategy/news_strategy_interface.dart';

class NewsProvider {
  NewsStrategy? _newsStrategy;

  set setStrategy(NewsStrategy strategy) => _newsStrategy = strategy;

  NewsProvider();
  factory NewsProvider.fromStrategy({required NewsStrategy strategy}) {
    final NewsProvider provider = NewsProvider();
    provider._newsStrategy = strategy;
    return provider;
  }

  Future<List<NewsFeedStory>> getNewsStoriesAsync() async {
    if (_newsStrategy.isNull) return [];
    return await _newsStrategy!.getFeedStoriesAsync();
  }

  Future<NewsFeedArticle?> getNewsStoryAsync(String url) async {
    if (_newsStrategy.isNull) return null;
    return await _newsStrategy!.getNewsStoryAsync(url);
  }
}
