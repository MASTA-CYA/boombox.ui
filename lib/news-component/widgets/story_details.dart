import 'package:boombox/common/helpers/color_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StoryDetailsWidget extends StatelessWidget {
  final String author;
  final String date;
  final bool isArticle;
  final bool isDate;

  const StoryDetailsWidget({
    super.key,
    required this.author,
    required this.date,
    this.isArticle = false,
    this.isDate = false,
  });

  static const double _ICON_SIZE = 22;

  @override
  Widget build(BuildContext context) {
    final TextStyle? style = isArticle
        ? Theme.of(context)
            .textTheme
            .bodyMedium
            ?.merge(const TextStyle(fontStyle: FontStyle.italic))
        : Theme.of(context)
            .textTheme
            .bodySmall
            ?.merge(const TextStyle(fontStyle: FontStyle.italic));

    return Container(
      margin: isArticle
          ? const EdgeInsets.symmetric(horizontal: 4, vertical: 6)
          : null,
      decoration: isArticle
          ? null
          : BoxDecoration(
              color: Theme.of(context).brightness == Brightness.light
                  ? ColorHelper.lighten(
                      Theme.of(context).colorScheme.secondary, 70)
                  : Theme.of(context).colorScheme.secondary,
              borderRadius: isArticle
                  ? null
                  : const BorderRadius.vertical(
                      bottom: Radius.circular(5),
                    ),
            ),
      child: Container(
        margin: const EdgeInsets.fromLTRB(10, 4, 10, 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildAuthor(context, style),
            _buildDetailsSeparator(context),
            _buildDate(context, style),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthor(BuildContext context, TextStyle? style) {
    return Row(
      children: [
        Icon(
          CupertinoIcons.person,
          size: isArticle ? _ICON_SIZE : 13,
        ),
        const SizedBox(width: 4),
        Text(author, style: style),
      ],
    );
  }

  Widget _buildDate(BuildContext context, TextStyle? style) {
    return Row(
      children: [
        Icon(
          isDate ? CupertinoIcons.calendar : CupertinoIcons.clock,
          size: isArticle ? _ICON_SIZE - 1.15 : 13,
        ),
        const SizedBox(width: 4),
        Text(
          date,
          style: isArticle
              ? Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.merge(const TextStyle(fontStyle: FontStyle.italic))
              : Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.merge(const TextStyle(fontStyle: FontStyle.italic)),
        ),
      ],
    );
  }

  Widget _buildDetailsSeparator(BuildContext context) {
    return Container(
      width: 6.0,
      height: 6.0,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
