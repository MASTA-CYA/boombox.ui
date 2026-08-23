import 'package:boombox/common/constants.dart';
import 'package:boombox/message-component/messages_page.dart';
import 'package:boombox/message-component/services/message_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MessagesSettingsWidget extends StatelessWidget {
  final void Function(Widget widget) onSettingPressed;

  const MessagesSettingsWidget({
    super.key,
    required this.onSettingPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Consumer<MessageService>(
        builder: (context, service, child) => FutureBuilder(
          future: service.getUnreadMessageCountAsync(),
          builder: (context, snapshot) => Badge(
            label: Text(
              snapshot.hasData ? snapshot.data!.toString() : '0',
              style: Theme.of(context).textTheme.bodySmall?.merge(
                    const TextStyle(
                      color: Colors.white,
                      fontFamily: FontFamily.PRIMARY,
                    ),
                  ),
            ),
            child: const ImageIcon(
              ResizeImage(
                AssetImage('assets/images/message.png'),
                width: 70,
                height: 70,
                allowUpscaling: false,
              ),
            ),
          ),
        ),
      ),
      title: const Text('Messages'),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: () => onSettingPressed(const MessagesPage()),
    );
  }
}
