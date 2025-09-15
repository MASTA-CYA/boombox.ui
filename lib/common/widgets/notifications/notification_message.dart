import 'package:boombox/common/widgets/scrolling_text.dart';
import 'package:flutter/material.dart';

class NotificationMessageWidget extends StatelessWidget {
  final String message;
  const NotificationMessageWidget({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildLeadingIcon(),
          const SizedBox(width: 12),
          _buildMessage(),
        ],
      ),
    );
  }

  Widget _buildLeadingIcon() {
    return const Badge(
      child: ImageIcon(
        ResizeImage(
          AssetImage('assets/images/message.png'),
          width: 200,
          height: 200,
          allowUpscaling: false,
        ),
        size: 35,
      ),
    );
  }

  Widget _buildMessage() {
    return message.length < 32
        ? Text(
            message,
            overflow: TextOverflow.fade,
            softWrap: true,
          )
        : ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 245),
            child: ScrollingTextWidget(text: message),
          );
  }
}
