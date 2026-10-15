import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:boombox/common/http/widgets/no_network_connectivity.dart';
import 'package:boombox/common/services/connectivity_service.dart';
import 'package:boombox/common/widgets/circular_progress_indicator.dart';
import 'package:boombox/common/navigator/transition_direction_enum.dart';
import 'package:boombox/commons_barrel.dart';
import 'package:boombox/news-component/models/news_feed_story_model.dart';
import 'package:boombox/news-component/services/news_service.dart';
import 'package:boombox/news-component/widgets/empty_news_feed.dart';
import 'package:boombox/news-component/widgets/news_feed_article_view.dart';
import 'package:boombox/news-component/widgets/news_feed_story.dart';
import 'package:provider/provider.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({super.key});

  @override
  State<StatefulWidget> createState() => _NewsPage();
}

class _NewsPage extends State<NewsPage> {
  final String _title = 'News';

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return ThemeSwitchingArea(
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBarWidget<NewsPage>(title: _title),
          body: Container(
            margin: EdgeInsets.symmetric(
              horizontal: Functions.horizontalScreenMargin(context),
              vertical: 10,
            ),
            child: RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: () async => await _onNewsFeedRefreshed(),
              child: _buildNewsFeedScaffold(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNewsFeedScaffold() {
    return Consumer<NewsService>(
      builder: (context, service, child) => FutureBuilder(
        future: service.getNewsFeedStoriesAsync(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return _buildNewsStories(snapshot.data!);
            } else {
              return Center(
                child: FutureBuilder(
                  future: Provider.of<ConnectivityService>(
                    context,
                    listen: false,
                  ).hasNetworkConnectivityAsync(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState.equals(ConnectionState.done) &&
                        snapshot.hasData) {
                      if (snapshot.data!) {
                        return const EmptyNewsFeedWidget();
                      } else {
                        return const NoNetworkConnectivityWidget();
                      }
                    } else {
                      return const SizedBox.shrink();
                    }
                  },
                ),
              );
            }
          } else {
            return const Center(child: CircularProgressIndicatorWidget());
          }
        },
      ),
    );
  }

  Widget _buildNewsStories(List<NewsFeedStory> stories) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        itemCount: stories.length,
        itemExtent: 350,
        itemBuilder: (context, index) => NewsFeedStoryWidget(
          story: stories.elementAt(index),
          onFeedStoryPressed: () => _navigateTo(
            NewsFeedArticleWidget(
              story: stories.elementAt(index),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onNewsFeedRefreshed() async {
    await Provider.of<NewsService>(
      context,
      listen: false,
    ).refreshNewsFeedAsync();
  }

  void _navigateTo(
    Widget widget, {
    TransitionDirection direction = TransitionDirection.ltr,
  }) {
    PageNavigator.navigateTo<NewsPage>(
      context,
      widget,
      direction: direction,
      useScheduler: false,
    );
  }
}
