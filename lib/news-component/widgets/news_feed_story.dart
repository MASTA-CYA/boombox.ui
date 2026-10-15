import 'package:boombox/common/constants.dart';
import 'package:boombox/common/helpers/color_helper.dart';
import 'package:boombox/news-component/models/news_feed_story_model.dart';
import 'package:boombox/news-component/widgets/news_source.dart';
import 'package:boombox/news-component/widgets/story_details.dart';
import 'package:flutter/material.dart';

class NewsFeedStoryWidget extends StatelessWidget {
  final NewsFeedStory story;
  final void Function()? onFeedStoryPressed;

  const NewsFeedStoryWidget({
    super.key,
    required this.story,
    this.onFeedStoryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onFeedStoryPressed,
      child: Container(
        margin: const EdgeInsets.fromLTRB(2, 0, 2, 14),
        child: Column(
          children: [
            _buildNewsSource(story.source),
            _buildStoryImage(),
            _buildHeader(context),
            StoryDetailsWidget(
              author: story.author,
              date: story.date,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsSource(String source) {
    return NewsSourceWidget(source: source);
  }

  Widget _buildStoryImage() {
    return Expanded(
      child: Hero(
        tag: 'story-image-${story.story}',
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: Image.network(
                story.image,
              ).image,
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
          story.title,
          style: Theme.of(context)
              .textTheme
              .titleMedium
              ?.merge(const TextStyle(fontFamily: FontFamily.PRIMARY)),
        ),
      ),
    );
  }
}
