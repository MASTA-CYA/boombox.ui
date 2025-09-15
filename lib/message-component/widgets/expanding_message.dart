import 'package:boombox/common/extensions.dart';
import 'package:boombox/message-component/models/message_model.dart';
import 'package:boombox/message-component/models/message_severity_enum.dart';
import 'package:boombox/message-component/services/message_service.dart';
import 'package:boombox/message-component/widgets/message_actions.dart';
import 'package:boombox/message-component/widgets/message_body.dart';
import 'package:boombox/message-component/widgets/message_info_bar.dart';
import 'package:boombox/message-component/widgets/message_header.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ExpandingMessageWidget extends StatefulWidget {
  final int messageId;
  final void Function() onDismissPressed;

  const ExpandingMessageWidget({
    super.key,
    required this.messageId,
    required this.onDismissPressed,
  });

  @override
  State<StatefulWidget> createState() => _ExpandingMessageWidget();
}

class _ExpandingMessageWidget extends State<ExpandingMessageWidget> {
  final ValueNotifier<bool> _isExpanded = ValueNotifier<bool>(false);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Provider.of<MessageService>(
        context,
        listen: false,
      ).getMessageAsync(widget.messageId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data.isNull) return const SizedBox.shrink();
          
          final Message message = snapshot.data!.model;
          if (message.hasBeenDismissed) return const SizedBox.shrink();

          final String date = DateFormat.yMd().format(
            DateTime.parse(message.date),
          );

          return Column(
            children: [
              _buildHeader(
                message.title,
                message.hasBeenRead,
                message.id,
              ),
              _buildInfoBar(
                date,
                message.severity,
                message.hasBeenRead,
                message.id,
              ),
              _buildBody(message.body),
              _buildActions(
                message.id,
                message.hasBeenReported,
              ),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildHeader(String title, bool hasBeenRead, int id) {
    return MessageHeaderWidget(
      messageId: id,
      heading: title,
      hasBeenRead: hasBeenRead,
      onExpandMessagePressed: (isExpanded) => _onExpandMessagePressed(
        isExpanded,
        hasBeenRead,
        id,
      ),
    );
  }

  Widget _buildInfoBar(
      String date, MessageSeverity severity, bool hasBeenRead, int id) {
    return MessageInfoBarWidget(
      messageId: id,
      date: date,
      severity: severity.name,
      hasBeenRead: hasBeenRead,
      onReadMessagePressed: () => _onReadMessagePressed(id),
    );
  }

  Widget _buildBody(String body) {
    return ValueListenableBuilder(
      valueListenable: _isExpanded,
      builder: (context, isExpanded, child) => AnimatedSwitcher(
        transitionBuilder: (child, animation) => SlideTransition(
          position: CurvedAnimation(
            parent: animation,
            curve: Curves.decelerate,
            reverseCurve: Curves.decelerate,
          ).drive(
            Tween<Offset>(
              begin: const Offset(0.0, -0.15),
              end: Offset.zero,
            ),
          ),
          child: child,
        ),
        duration: const Duration(seconds: 8),
        child: isExpanded
            ? MessageBodyWidget(
                key: UniqueKey(),
                body: body,
              )
            : SizedBox.shrink(key: UniqueKey()),
      ),
    );
  }

  Widget _buildActions(int id, bool hasBeenReported) {
    return MessageActionsWidget(
      messageId: id,
      hasBeenReported: hasBeenReported,
      onReportPressed: () => _onReportPressed(id, hasBeenReported),
      onDismissPressed: () => _onDismissPressed(id),
    );
  }

  void _onExpandMessagePressed(
      bool isExpanded, bool hasBeenRead, int id) async {
    _isExpanded.value = isExpanded;
    if (!hasBeenRead && isExpanded) {
      await Provider.of<MessageService>(
        context,
        listen: false,
      ).readMessageAsync(id);
    }
  }

  _onReportPressed(int id, bool hasBeenReported) async {
    if (hasBeenReported) return;
    await Provider.of<MessageService>(
      context,
      listen: false,
    ).reportMessageAsync(id);
  }

  _onDismissPressed(int id) async {
    await Provider.of<MessageService>(
      context,
      listen: false,
    ).dismissMessageAsync(id);
    widget.onDismissPressed();
  }

  void _onReadMessagePressed(int id) async {
    await Provider.of<MessageService>(
      context,
      listen: false,
    ).readMessageAsync(id);
  }
}
