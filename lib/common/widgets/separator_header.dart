import 'package:boombox/common/constants.dart';
import 'package:boombox/common/extensions.dart';
import 'package:boombox/common/helpers/color_helper.dart';
import 'package:flutter/material.dart';

class SeparatorHeaderWidget extends StatelessWidget {
  final String title;
  final bool? isExpandable;
  final Function(String title, bool isExpanded)? onExpanded;

  SeparatorHeaderWidget({
    super.key,
    required this.title,
    this.isExpandable = false,
    this.onExpanded,
  });

  final ValueNotifier _isExpanded = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _isExpanded,
      builder: (context, isExpanded, child) => Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 10),
        color: Theme.of(context).brightness == Brightness.light
            ? ColorHelper.lighten(Theme.of(context).colorScheme.secondary, 70)
            : Theme.of(context).colorScheme.secondary.withOpacity(0.4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(8, 4, 0, 4),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.merge(
                      const TextStyle(fontFamily: FontFamily.PRIMARY),
                    ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: GestureDetector(
                  child: isExpanded
                      ? Icon(
                          Icons.arrow_downward,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : const Icon(Icons.arrow_upward),
                  onTap: () => _onIconExpanded(isExpanded),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onIconExpanded(isExpanded) {
    _isExpanded.value = !isExpanded;
    if(!onExpanded.isNull) onExpanded!(title, isExpanded);
  }
}
