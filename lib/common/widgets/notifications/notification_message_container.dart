import 'dart:async';

import 'package:boombox/common/debouncer.dart';
import 'package:boombox/common/widgets/notifications/notification_message.dart';
import 'package:boombox/message-component/models/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class NotificationMessageContainerWidget extends StatefulWidget {
  final AppNotification notification;

  const NotificationMessageContainerWidget({
    super.key,
    required this.notification,
  });

  @override
  State<StatefulWidget> createState() => _NotificationMessageContainerWidget();
}

class _NotificationMessageContainerWidget
    extends State<NotificationMessageContainerWidget>
    with TickerProviderStateMixin {
  late AnimationController _opacityController;
  late AnimationController _slideController;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;

  late Debouncer _animationDebouncer;
  late Timer? _animationTimer;
  late bool _canHideMessage;

  @override
  void initState() {
    super.initState();

    _animationDebouncer = Debouncer(milliseconds: 500);
    _animationTimer = Timer(Duration.zero, () {});
    _canHideMessage = false;

    _opacityController = AnimationController(
      vsync: this,
      duration: Duration.zero,
    );
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      _opacityController,
    )..addListener(
        () async {
          await _clearNotification();
          setState(() {});
        },
      );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: Curves.easeInOut,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        await _slideController.forward();
        _animationTimer = _animationDebouncer.runAnimation(
          (_) async {
            await _opacityController.forward();
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    _opacityController.stop();
    _opacityController.dispose();
    _slideController.stop();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      child: _canHideMessage
          ? const SizedBox.shrink()
          : SlideTransition(
              position: _slideAnimation,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 65, minHeight: 50),
                child: ClipRRect(
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      color: Theme.of(context).colorScheme.background,
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.secondary,
                          offset: Offset.zero,
                          blurRadius: 4.0,
                        ),
                      ],
                    ),
                    child: AnimatedOpacity(
                      opacity: _opacityAnimation.value,
                      duration: const Duration(seconds: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          NotificationMessageWidget(
                            message: widget.notification.notificationText,
                          ),
                          _buildDismissIcon(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildDismissIcon() {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      child: const Padding(
        padding: EdgeInsets.all(5),
        child: Icon(
          Icons.close,
          color: Colors.red,
        ),
      ),
      onTap: () => _onDismissPressed(),
    );
  }

  Future<void> _clearNotification({bool isInterrupt = false}) async {
    if (isInterrupt) {
      _animationTimer?.cancel();
      await _opacityController.forward();
      _canHideMessage = _slideAnimation.isCompleted;
      await _slideController.reverse();
      setState(() {});
    } else if (_slideAnimation.isCompleted) {
      _animationDebouncer.runAnimation(
        (_) => SchedulerBinding.instance.addPostFrameCallback(
          (_) async {
            _canHideMessage = _slideAnimation.isCompleted;
            await _slideController.reverse();
            setState(() {});
          },
        ),
      );
    }
  }

  void _onDismissPressed() async {
    _clearNotification(isInterrupt: true);
  }
}
