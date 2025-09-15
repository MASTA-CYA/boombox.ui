import 'package:boombox/message-component/services/message_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MessageActionsWidget extends StatelessWidget {
  final int messageId;
  final bool hasBeenReported;
  final void Function() onReportPressed;
  final void Function() onDismissPressed;

  const MessageActionsWidget({
    super.key,
    required this.messageId,
    required this.hasBeenReported,
    required this.onReportPressed,
    required this.onDismissPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<MessageService>(
      builder: (context, service, child) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildReportButton(context, service),
          _buildDismissButton(context, service),
        ],
      ),
    );
  }

  Widget _buildReportButton(BuildContext context, MessageService service) {
    return FutureBuilder(
      future: service.getMessageReportStatus(messageId),
      builder: (context, snapshot) => TextButton(
        onPressed: (snapshot.hasData ? !snapshot.data! : !hasBeenReported)
            ? onReportPressed
            : null,
        style: ButtonStyle(
          foregroundColor: MaterialStateProperty.resolveWith<Color?>(
            (states) => Theme.of(context).brightness == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
        ),
        child: Text(
          'Report',
          style: Theme.of(context).textTheme.bodyMedium?.merge(
                TextStyle(
                    color:
                        (snapshot.hasData ? !snapshot.data! : !hasBeenReported)
                            ? Colors.red
                            : Theme.of(context).colorScheme.secondary),
              ),
        ),
      ),
    );
  }

  _buildDismissButton(BuildContext context, MessageService service) {
    return TextButton(
      onPressed: onDismissPressed,
      child: Text(
        'Dismiss',
        style: Theme.of(context).textTheme.bodyMedium?.merge(
              const TextStyle(color: Colors.blue),
            ),
      ),
    );
  }
}
