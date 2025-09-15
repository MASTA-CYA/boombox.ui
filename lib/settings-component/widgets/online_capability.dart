import 'package:boombox/common/constants.dart';
import 'package:boombox/settings-component/services/user_settings_service.dart';
import 'package:boombox/common/widgets/filled_icon.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OnlineCapabilityWidget extends StatefulWidget {
  const OnlineCapabilityWidget({super.key});

  @override
  State<StatefulWidget> createState() => _OnlineCapabilityWidget();
}

class _OnlineCapabilityWidget extends State<OnlineCapabilityWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _cloudAnimation;
  late Animation<Color?> _separatorAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 400),
    );
    _cloudAnimation = ColorTween(
      begin: Colors.grey,
      end: Colors.grey,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );
    _separatorAnimation = ColorTween(
      begin: Colors.grey,
      end: Colors.grey,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.linear,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        _cloudAnimation = ColorTween(
          begin: Theme.of(context).brightness == Brightness.dark
              ? Theme.of(context).colorScheme.secondary
              : Colors.black,
          end: Theme.of(context).colorScheme.primary,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.decelerate,
          ),
        )..addListener(() => setState(() {}));
        _separatorAnimation = ColorTween(
          begin: Theme.of(context).colorScheme.primary,
          end: Theme.of(context).brightness == Brightness.dark
              ? Colors.white
              : Colors.black,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.decelerate,
          ),
        )..addListener(() => setState(() {}));
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Provider.of<UserSettingsService>(
        context,
      ).getOnlineCapabilitiesStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return FutureBuilder(
            future: Provider.of<UserSettingsService>(
              context,
              listen: false,
            ).getOnlineCapabilitiesAsync(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                _alignOnlineState(snapshot.data!);
              }

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FilledWidget(
                      color: _cloudAnimation.value,
                      percent: (((snapshot.data ?? 0) / 4) * 100).toInt(),
                      child: const ImageIcon(
                        ResizeImage(
                          AssetImage('assets/images/cloud.png'),
                          width: 70,
                          height: 70,
                          allowUpscaling: false,
                        ),
                      ),
                    ),
                    Container(
                      width: 6.5,
                      height: 6.5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _separatorAnimation.value,
                      ),
                    ),
                    Text(
                      (snapshot.data ?? 0) > 0 ? 'Online' : 'Offline',
                      style: Theme.of(context).textTheme.bodyMedium?.merge(
                            TextStyle(
                              fontFamily: FontFamily.PRIMARY,
                              color: _cloudAnimation.value,
                            ),
                          ),
                    ),
                  ],
                ),
                onTap: () async => _onCapabilityPressed(
                  !((snapshot.data ?? 0) > 0),
                ),
              );
            },
          );
        } else {
          _alignOnlineState(snapshot.data!);

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                FilledWidget(
                  color: _cloudAnimation.value,
                  percent: (((snapshot.data ?? 0) / 4) * 100).toInt().toInt(),
                  child: const ImageIcon(
                    ResizeImage(
                      AssetImage('assets/images/cloud.png'),
                      width: 70,
                      height: 70,
                      allowUpscaling: false,
                    ),
                  ),
                ),
                Container(
                  width: 6.5,
                  height: 6.5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _separatorAnimation.value,
                  ),
                ),
                Text(
                  (snapshot.data ?? 0) > 0 ? 'Online' : 'Offline',
                  style: Theme.of(context).textTheme.bodyMedium?.merge(
                        TextStyle(
                          fontFamily: FontFamily.PRIMARY,
                          color: _cloudAnimation.value,
                        ),
                      ),
                ),
              ],
            ),
            onTap: () async => _onCapabilityPressed(
              !((snapshot.data ?? 0) > 0),
            ),
          );
        }
      },
    );
  }

  void _alignOnlineState(int capabilities) async {
    capabilities > 0
        ? await _controller.forward()
        : await _controller.reverse();
  }

  void _onCapabilityPressed(bool hasCapability) async {
    _controller.isCompleted ? _controller.reverse() : _controller.forward();

    if (mounted) {
      await Provider.of<UserSettingsService>(context, listen: false)
          .updateHasOnlineCapabilitiesAsync(hasCapability);
    }
  }
}
