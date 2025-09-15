import 'package:boombox/player-component/services/player_service.dart';
import 'package:boombox/player-component/widgets/action-bar/action_container.dart';
import 'package:boombox/player-component/widgets/action-bar/no_action.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LyricsWidget extends StatelessWidget {
  const LyricsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Provider.of<PlayerService>(context).getLyricsStream,
      builder: (context, snapshot) {
        if (snapshot.data?.isEmpty ?? true) {
          return const NoActionWidget<LyricsWidget>();
        } else {
          return ActionContainerWidget<LyricsWidget>(
            child: Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, \n\n'
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, \n\n'
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, \n\n'
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, \n\n'
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, \n\n'
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, \n\n',
              style: Theme.of(context).textTheme.bodyLarge,
              // snapshot.data!,
              // style: Theme.of(context)
              //     .textTheme
              //     .bodyLarge!
              //     .merge(const TextStyle(fontWeight: FontWeight.bold)),
            ),
          );
        }
      },
    );
  }
}
