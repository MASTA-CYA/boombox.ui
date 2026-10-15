import 'package:boombox/common/helpers/color_helper.dart';
import 'package:flutter/material.dart';

class NewsSourceWidget extends StatelessWidget {
  final String source;
  final bool isArticle;

  const NewsSourceWidget({
    super.key,
    required this.source,
    this.isArticle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.light
            ? ColorHelper.lighten(Theme.of(context).colorScheme.secondary, 70)
            : Theme.of(context).colorScheme.secondary,
        borderRadius: isArticle
            ? const BorderRadius.vertical(
                bottom: Radius.circular(5),
              )
            : const BorderRadius.vertical(
                top: Radius.circular(5),
              ),
      ),
      child: Column(
        children: [
          if (!isArticle) _buildNotch(context),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              margin: const EdgeInsets.fromLTRB(8, 0, 8, 3),
              child: Text('Source:\t\t$source'),
            ),
          ),
          if (isArticle) _buildNotch(context),
        ],
      ),
    );
  }

  Widget _buildNotch(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        width: isArticle ? 200 : 100,
        height: isArticle ? 6 : 5,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}
