import 'package:boombox/common/constants.dart';
import 'package:boombox/common/extensions.dart';
import 'package:flutter/material.dart';

class ReadMoreTextWidget extends StatefulWidget {
  final String text;
  final TextStyle? style;
  const ReadMoreTextWidget({
    super.key,
    required this.text,
    this.style,
  });

  @override
  State<StatefulWidget> createState() => _ReadMoreTextWidget();
}

class _ReadMoreTextWidget extends State<ReadMoreTextWidget> {
  final ValueNotifier _isExpanded = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: _isExpanded,
      builder: (context, isExpanded, child) => Wrap(
        children: [
          widget.style.isNull
              ? Text(
                  widget.text,
                  maxLines: isExpanded ? 5 : 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  style: widget.style,
                )
              : Text(
                  widget.text,
                  maxLines: isExpanded ? 5 : 2,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                ),
          Container(
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              child: Text(
                isExpanded ? "Read less" : "Read more",
                style: Theme.of(context).textTheme.bodyMedium?.merge(
                      TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontFamily: FontFamily.PRIMARY,
                      ),
                    ),
              ),
              onTap: () => _isExpanded.value = !isExpanded,
            ),
          ),
        ],
      ),
    );
  }
}
