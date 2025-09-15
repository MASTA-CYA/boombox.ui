import 'package:boombox/news-component/models/news_feed_article_model.dart';
import 'package:boombox/news-component/models/news_feed_story_model.dart';

abstract interface class NewsStrategy {
  Future<List<NewsFeedStory>> getFeedStoriesAsync();
  Future<NewsFeedArticle?> getNewsStoryAsync(String url);
}
