import 'package:boombox/settings-component/services/user_settings_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PageBackgroundWidget extends StatelessWidget {
  final Widget child;

  const PageBackgroundWidget({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: Provider.of<UserSettingsService>(
          context,
        ).getActiveThemeStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: ResizeImage(
                    AssetImage(snapshot.data!.path),
                    width: 710,
                    height: MediaQuery.of(context).size.height.toInt(),
                    allowUpscaling: false,
                  ),
                  fit: snapshot.data!.fit,
                  invertColors: snapshot.data!.invertColors,
                  opacity: Theme.of(context).brightness == Brightness.dark
                      ? 0.3
                      : 0.1,
                ),
              ),
              child: child,
            );
          } else {
            return FutureBuilder(
              future: Provider.of<UserSettingsService>(
                context,
                listen: false,
              ).getActiveThemeAsync(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: ResizeImage(
                          AssetImage(snapshot.data!.path),
                          width: 710,
                          height: MediaQuery.of(context).size.height.toInt(),
                          allowUpscaling: false,
                        ),
                        fit: snapshot.data!.fit,
                        invertColors: snapshot.data!.invertColors,
                        opacity: Theme.of(context).brightness == Brightness.dark
                            ? 0.3
                            : 0.1,
                      ),
                    ),
                    child: child,
                  );
                } else {
                  return child;
                }
              },
            );
          }
        }

        //  FutureBuilder(
        //   future: Provider.of<UserSettingsService>(
        //     context,
        //     listen: false,
        //   ).getActiveThemeAsync(),
        //   builder: (context, snapshot) {
        //     if (snapshot.connectionState == ConnectionState.done) {
        //       return Container(
        //         decoration: BoxDecoration(
        //           image: DecorationImage(
        //             image: ResizeImage(
        //               AssetImage(snapshot.data!.path),
        //               width: 710,
        //               height: MediaQuery.of(context).size.height.toInt(),
        //               allowUpscaling: false,
        //             ),
        //             fit: snapshot.data!.fit,
        //             invertColors: snapshot.data!.invertColors,
        //             opacity: Theme.of(context).brightness == Brightness.dark
        //                 ? 0.3
        //                 : 0.1,
        //           ),
        //         ),
        //         child: child,
        //       );
        //     } else {
        //       return child;
        //     }
        //   },
        // ),
        );
  }
}
