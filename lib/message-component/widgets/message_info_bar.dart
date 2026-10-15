import 'package:boombox/common/helpers/color_helper.dart';
import 'package:boombox/message-component/services/message_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class MessageInfoBarWidget extends StatelessWidget {
  final int messageId;
  final String date;
  final String severity;
  final bool hasBeenRead;
  final void Function() onReadMessagePressed;

  const MessageInfoBarWidget({
    super.key,
    required this.messageId,
    required this.date,
    required this.severity,
    required this.hasBeenRead,
    required this.onReadMessagePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.light
              ? ColorHelper.lighten(Theme.of(context).colorScheme.secondary, 70)
              : Theme.of(context).colorScheme.secondary.withOpacity(0.4),
          width: 5,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.all(4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(severity),
            _buildDetailsSeparator(context),
            _buildReadStatus(context),
            _buildDetailsSeparator(context),
            Text(
              date,
              style: Theme.of(context).textTheme.bodyMedium?.merge(
                    const TextStyle(fontStyle: FontStyle.italic),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadStatus(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Consumer<MessageService>(
        builder: (context, service, child) => FutureBuilder(
          future: service.getMessageReadStatus(messageId),
          builder: (context, snapshot) => GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => onReadMessagePressed(),
            child: Text(
              (snapshot.hasData ? snapshot.data! : hasBeenRead)
                  ? 'Read'
                  : 'Unread',
              style: TextStyle(
                color: (snapshot.hasData ? snapshot.data! : hasBeenRead)
                    ? Theme.of(context).iconTheme.color
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsSeparator(BuildContext context) {
    return Consumer<MessageService>(
      builder: (context, service, child) => FutureBuilder(
        future: service.getMessageReadStatus(messageId),
        builder: (context, snapshot) => Container(
          width: 5.5,
          height: 5.5,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: (snapshot.hasData ? snapshot.data! : hasBeenRead)
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    );
  }
}
