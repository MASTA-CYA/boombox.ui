import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:boombox/common/constants.dart';
import 'package:boombox/common/extensions.dart';
import 'package:boombox/common/functions.dart';
import 'package:boombox/common/helpers/color_helper.dart';
import 'package:boombox/common/http/widgets/no_network_connectivity.dart';
import 'package:boombox/common/services/connectivity_service.dart';
import 'package:boombox/common/widgets/appbar.dart';
import 'package:boombox/common/widgets/circular_progress_indicator.dart';
import 'package:boombox/news-component/models/news_feed_article_model.dart';
import 'package:boombox/news-component/models/news_feed_story_model.dart';
import 'package:boombox/news-component/services/news_service.dart';
import 'package:boombox/news-component/widgets/news_source.dart';
import 'package:boombox/news-component/widgets/story_details.dart';
import 'package:boombox/news-component/widgets/unavailable_news_article.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NewsFeedArticleWidget extends StatefulWidget {
  final NewsFeedStory story;

  const NewsFeedArticleWidget({
    super.key,
    required this.story,
  });

  @override
  State<NewsFeedArticleWidget> createState() => _NewsFeedArticleWidgetState();
}

class _NewsFeedArticleWidgetState extends State<NewsFeedArticleWidget> {
  final String _title = 'Article';

  @override
  Widget build(BuildContext context) {
    return ThemeSwitchingArea(
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBarWidget<NewsFeedArticleWidget>(title: _title),
          body: Container(
            margin: EdgeInsets.symmetric(
              horizontal: Functions.horizontalScreenMargin(context),
              vertical: 10,
            ),
            child: _buildNewsFeedArticleScaffold(),
          ),
        ),
      ),
    );
  }

  Widget _buildNewsFeedArticleScaffold() {
    return FutureBuilder(
      future: Provider.of<NewsService>(
        context,
        listen: false,
      ).getNewsFeedStoryAsync(widget.story.source, widget.story.story),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            final NewsFeedArticle article = snapshot.data!;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildArticleImage(article.image),
                  _buildArticleTitle(article.title),
                  const SizedBox(height: 4),
                  _buildArticleSubtitle(article.subtitle),
                  const SizedBox(height: 4),
                  _buildArticleDetails(article.author, article.date),
                  if (article.preamble.isNotEmpty) ...{
                    const SizedBox(height: 20),
                    _buildArticlePreamble(article.preamble),
                  },
                  if (article.body.isNotEmpty) ...{
                    const SizedBox(height: 10),
                    _buildArticleBody(article.body),
                  },
                  const SizedBox(height: 10),
                  _buildArticleSource(article.source),
                ],
              ),
            );
          } else {
            return FutureBuilder(
              future: Provider.of<ConnectivityService>(
                context,
                listen: false,
              ).hasNetworkConnectivityAsync(),
              builder: (context, snapshot) {
                if (snapshot.connectionState.equals(ConnectionState.done) &&
                    snapshot.hasData) {
                  if (snapshot.data!) {
                    return const UnavailableNewsArticleWidget();
                  } else {
                    return const NoNetworkConnectivityWidget();
                  }
                } else {
                  return const SizedBox.shrink();
                }
              },
            );
          }
        } else {
          return const Center(child: CircularProgressIndicatorWidget());
        }
      },
    );
  }

  Widget _buildArticleImage(String image) {
    return ClipRRect(
      child: Image.network(
        image.isEmpty ? widget.story.image : image,
      ),
    );
  }

  Widget _buildArticleTitle(String title) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.light
              ? ColorHelper.lighten(Theme.of(context).colorScheme.secondary, 70)
              : Theme.of(context).colorScheme.secondary,
        ),
        child: Text(
          title.isEmpty ? widget.story.title : title,
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.merge(const TextStyle(fontFamily: FontFamily.PRIMARY)),
        ),
      ),
    );
  }

  Widget _buildArticleDetails(String author, String date) {
    return StoryDetailsWidget(
      author: author.isEmpty ? widget.story.author : author,
      date: date.isEmpty ? widget.story.date : date,
      isDate: date.isNotEmpty,
      isArticle: true,
    );
  }

  Widget _buildArticleSubtitle(String subtitle) {
    return Text(
      subtitle.isEmpty ? widget.story.title : subtitle,
      style: Theme.of(context).textTheme.titleMedium?.merge(
            TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
    );
  }

  Widget _buildArticlePreamble(String preamble) {
    return Text(preamble);
  }

  Widget _buildArticleBody(String body) {
    return Text(body);
  }

  Widget _buildArticleSource(String source) {
    return NewsSourceWidget(
      source: source,
      isArticle: true,
    );
  }
}
