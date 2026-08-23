import 'package:beautiful_soup_dart/beautiful_soup.dart';
import 'package:boombox/common/extensions.dart';
import 'package:boombox/common/logger/enums/severity_enum.dart';
import 'package:boombox/common/logger/enums/tag_enum.dart';
import 'package:boombox/common/logger/logger.dart';
import 'package:boombox/common/logger/models/log_event_model.dart';
import 'package:boombox/common/http/strategies/smart_http_client.dart';
import 'package:boombox/common/http/services/http_service.dart';
import 'package:boombox/news-component/models/news_feed_article_model.dart';
import 'package:boombox/news-component/models/news_feed_story_model.dart';
import 'package:boombox/news-component/strategy/news_strategy_interface.dart';
import 'package:http/http.dart';

class BillboardStrategy implements NewsStrategy {
  static const String _BILLBOARD_NEWS_FEED_URL =
      'https://www.billboard.com/c/music/music-news/';

  @override
  Future<List<NewsFeedStory>> getFeedStoriesAsync() async {
    List<NewsFeedStory> newsFeedStories = [];
    try {
      Response response = await HttpService().getAsync<SmartHttpClientStrategy>(
        Uri.parse(_BILLBOARD_NEWS_FEED_URL),
      );
      List<Bs4Element>? feed = await _sanitizeHtmlFeedResponse(response.body);
      if (feed.isNull) throw Exception('Feed is empty.');
      newsFeedStories = await _mapNewsFeedStories(feed!);
    } on Exception catch (ex) {
      Logger.logAsync(
        LogEvent<BillboardStrategy>(
          severity: Severity.error,
          tag: Tag.strategy,
          line: ex.toString(),
        ),
      );
    }

    return newsFeedStories;
  }

  Future<List<Bs4Element>?> _sanitizeHtmlFeedResponse(String html) async {
    BeautifulSoup bs = BeautifulSoup(html.replaceAll('<br/>', '\n'));
    List<Bs4Element>? feed = bs
        .find(
          'div',
          class_: 'river-items-wrapper',
        )
        ?.children;

    return feed;
  }

  Future<List<NewsFeedStory>> _mapNewsFeedStories(List<Bs4Element> feed) async {
    List<NewsFeedStory> stories = [];

    String image;
    String title;
    String author;
    String date;
    String storyUrl;
    for (Bs4Element story in feed) {
      image = story.descendants.first.descendants
              .firstWhere(
                (element) => (element.name ?? '').equals('img'),
                orElse: () => story.descendants.elementAt(5),
              )
              .attributes['data-lazy-src'] ??
          '';
      title = story.descendants.first.descendants
          .firstWhere(
            (element) => element.id == 'title-of-a-story',
            orElse: () => story.descendants.elementAt(8),
          )
          .getText()
          .trim();
      author = story.descendants.first.descendants
          .firstWhere(
            (element) => (element.name ?? '').equals('span'),
            orElse: () => story.descendants.elementAt(15),
          )
          .getText()
          .trim();
      date = story.descendants.first.descendants
          .firstWhere(
            (element) => element.className.equals('c-timestamp  '),
            orElse: () => story.descendants.last,
          )
          .getText()
          .trim();
      storyUrl = story.descendants.first.descendants
              .firstWhere(
                (element) => (element.name ?? '').equals('a'),
                orElse: () => story.descendants.first.descendants.elementAt(2),
              )
              .attributes['href'] ??
          '';
      // Add to stories
      stories.add(
        NewsFeedStory(
            image: image,
            title: title,
            author: author,
            date: date,
            story: storyUrl,
            source: 'www.billboard.com'),
      );

      // Clean up
      image = '';
      title = '';
      author = '';
      date = '';
      storyUrl = '';
    }

    return stories;
  }

  @override
  Future<NewsFeedArticle?> getNewsStoryAsync(String url) async {
    NewsFeedArticle? article;
    try {
      Response response = await HttpService().getAsync<SmartHttpClientStrategy>(
        Uri.parse(url),
      );
      Map<String, List<Bs4Element>?> story =
          await _sanitizeHtmlStoryResponseAsync(response.body);
      if (story.entries.isEmpty) {
        throw Exception('Story is missing sections.');
      }
      article = await _mapNewsArticleAsync(story);
    } on Exception catch (ex) {
      Logger.logAsync(
        LogEvent<BillboardStrategy>(
          severity: Severity.error,
          tag: Tag.strategy,
          line: ex.toString(),
        ),
      );
    }

    return article;
  }

  Future<Map<String, List<Bs4Element>?>> _sanitizeHtmlStoryResponseAsync(
      String html) async {
    Map<String, List<Bs4Element>?> sections = {};
    BeautifulSoup bs = BeautifulSoup(html.replaceAll('<br/>', '\n'));
    sections.addAll(
      {
        'header': bs.find('header', class_: 'a-article-grid__header')?.children,
        'article': bs.find('article')?.children
      },
    );

    return sections;
  }

  Future<NewsFeedArticle> _mapNewsArticleAsync(
      Map<String, List<Bs4Element>?> article) async {
    NewsFeedArticle story;
    // Header
    String title = article['header']!
        .firstWhere(
            (element) =>
                (element.element?.className ?? '').contains('article-title'),
            orElse: () => article['header']!.elementAt(2))
        .strippedStrings;
    String subtitle = article['header']!
        .firstWhere(
            (element) =>
                (element.element?.className ?? '').contains('article-excerpt'),
            orElse: () => article['header']!.elementAt(3))
        .strippedStrings;
    String author = article['header']!
        .elementAt(4)
        .children
        .firstWhere(
            (element) => element.className
                .equals('a-article-grid__author  lrv-u-display-block'),
            orElse: () => article['header']!.elementAt(3).children.first)
        .descendants
        .firstWhere((element) => element.className.equals('c-link  '),
            orElse: () => article['header']!
                .elementAt(4)
                .children
                .firstWhere(
                    (element) => element.className
                        .equals('a-article-grid__author  lrv-u-display-block'),
                    orElse: () =>
                        article['header']!.elementAt(3).children.first)
                .descendants
                .elementAt(6))
        .strippedStrings;
    String date = article['header']!
        .elementAt(4)
        .children
        .firstWhere(
            (element) => element.className
                .equals('a-article-grid__author  lrv-u-display-block'),
            orElse: () => article['header']!.elementAt(3).children.first)
        .descendants
        .firstWhere(
            (element) => element.className
                .equals('article-timestamp // lrv-u-display-block'),
            orElse: () => article['header']!
                .elementAt(4)
                .children
                .firstWhere(
                    (element) => element.className
                        .equals('a-article-grid__author  lrv-u-display-block'),
                    orElse: () =>
                        article['header']!.elementAt(3).children.first)
                .descendants
                .elementAt(27))
        .strippedStrings;

    // Article
    List<Bs4Element?> imageSections = article['article']!
        .firstWhere(
          (element) => element.className.equals(
              'featured-image // u-margin-lr-n10@mobile-max lrv-u-margin-b-1 a-become-display-width@mobile-max'),
          orElse: () => article['article']!.elementAt(0),
        )
        .descendants;
    String image = imageSections.isNotEmpty
        ? imageSections
                .firstWhere(
                  (element) => (element?.name ?? '').equals('img'),
                )
                ?.attributes['src'] ??
            ''
        : '';

    List<Bs4Element>? articleDescendants = article['article']!
        .firstWhere(
            (element) => element.className.equals(
                'a-content lrv-a-floated-parent lrv-a-glue-parent a-font-body-m'),
            orElse: () => article['article']!.elementAt(0))
        .descendants;
    List<String> paragraphs = articleDescendants
        .where((element) => (element.element?.localName ?? '').equals('p'))
        .map((e) => e.strippedStrings)
        .toList();
    String preamble = paragraphs.take(paragraphs.indexOf('') - 1).reduce(
        (value, element) =>
            '$value${value.equals('') ? '' : '\n\n'}$element'.trim());
    String body = paragraphs
        .skip(paragraphs.indexOf('') - 1)
        .take(paragraphs.lastIndexOf(''))
        .reduce((value, element) =>
            '$value${value.equals('') ? '' : '\n\n'}$element'.trim());

    story = NewsFeedArticle(
        title: title.trim(),
        subtitle: subtitle.trim(),
        image: image,
        author: author.trim(),
        date: date.trim(),
        preamble: preamble,
        body: body,
        source: 'www.billboard.com');

    return story;
  }
}
