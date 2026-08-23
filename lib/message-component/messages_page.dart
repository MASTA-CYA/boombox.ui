import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:boombox/common/extensions.dart';
import 'package:boombox/common/functions.dart';
import 'package:boombox/common/widgets/appbar.dart';
import 'package:boombox/common/widgets/circular_progress_indicator.dart';
import 'package:boombox/message-component/services/message_service.dart';
import 'package:boombox/message-component/widgets/expanding_message.dart';
import 'package:boombox/message-component/widgets/message_button.dart';
import 'package:boombox/message-component/widgets/no_messages.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MessagesPage extends StatefulWidget {
  const MessagesPage({super.key});

  @override
  State<StatefulWidget> createState() => _MessagesPage();
}

class _MessagesPage extends State<MessagesPage> {
  final String _title = 'Messages';

  @override
  Widget build(BuildContext context) {
    return ThemeSwitchingArea(
      child: Builder(
        builder: (context) => Scaffold(
          appBar: AppBarWidget<MessagesPage>(title: _title),
          drawer: null,
          body: Container(
            margin: EdgeInsets.symmetric(
              horizontal: Functions.horizontalScreenMargin(context),
              vertical: 10,
            ),
            child:
                // SingleChildScrollView(
                //   physics: const BouncingScrollPhysics(),
                //   child:
                _buildMessagesScaffold(),
            // ),
          ),
        ),
      ),
    );
  }

  Widget _buildMessagesScaffold() {
    return FutureBuilder(
      future: Provider.of<MessageService>(
        context,
        listen: false,
      ).getMessageCountAsync(),
      builder: (context, snapshot) =>
          snapshot.connectionState == ConnectionState.done
              ? Column(
                  children: [
                    ...[
                      Expanded(child: _buildMessageList(snapshot.data!)),
                      _buildButtonBar(snapshot.data!),
                    ]
                  ],
                )
              : const CircularProgressIndicatorWidget(),
    );
  }

  Widget _buildMessageList(int count) {
    return count.isZero
        ? const Align(
            alignment: Alignment.center,
            child: NoMessagesWidget(),
          )
        : ListView.builder(
            physics: const BouncingScrollPhysics(),
            shrinkWrap: true,
            reverse: true,
            itemCount: count,
            itemBuilder: (context, index) => AnimatedSwitcher(
              duration: const Duration(seconds: 1),
              child: StatefulBuilder(
                builder: (context, setState) => ExpandingMessageWidget(
                  messageId: index,
                  onDismissPressed: () => setState(() => {}),
                ),
              ),
            ),
          );
  }

  Widget _buildButtonBar(int count) {
    return count.isZero
        ? const SizedBox.shrink()
        : Align(
            alignment: Alignment.bottomCenter,
            child: ButtonBar(
              alignment: MainAxisAlignment.spaceEvenly,
              children: [
                MessageButtonWidget(
                  isPrimary: false,
                  icon: const Icon(Icons.menu_book_outlined),
                  text: 'Read All',
                  onPressed: () => _onReadAllMessagesPressed(),
                ),
                MessageButtonWidget(
                  icon: const Icon(Icons.delete_sweep),
                  text: 'Dismiss All',
                  onPressed: () => _onDismissAllMessagesPressed(),
                ),
              ],
            ),
          );
  }

  void _onReadAllMessagesPressed() async {
    await Provider.of<MessageService>(
      context,
      listen: false,
    ).readAllMessagesAsync();
  }

  void _onDismissAllMessagesPressed() async {
    await Provider.of<MessageService>(
      context,
      listen: false,
    ).dismissAllMessagesAsync();
    setState(() {});
  }
}
