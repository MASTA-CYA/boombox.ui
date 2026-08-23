import 'package:boombox/common/extensions.dart';
import 'package:boombox/common/widgets/notifications/notification_message_container.dart';
import 'package:boombox/message-component/services/message_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NotificationScaffoldWidget extends StatelessWidget {
  final Widget child;
  const NotificationScaffoldWidget({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        StreamBuilder(
          stream: Provider.of<MessageService>(context).getNotificationStream,
          builder: (context, snapshot) {
            if (snapshot.hasData && !snapshot.data!.isNull) {
              return NotificationMessageContainerWidget(
                notification: snapshot.data!,
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ],
    );
  }
}
