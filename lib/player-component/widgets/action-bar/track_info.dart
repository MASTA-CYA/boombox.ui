import 'package:boombox/common/widgets/circular_progress_indicator.dart';
import 'package:boombox/player-component/models/track_info_model.dart';
import 'package:boombox/player-component/services/player_service.dart';
import 'package:boombox/player-component/widgets/action-bar/action_container.dart';
import 'package:boombox/player-component/widgets/action-bar/no_action.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TrackInfoWidget extends StatelessWidget {
  const TrackInfoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Provider.of<PlayerService>(context).getSequenceStateStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          String details =
              (snapshot.data!.currentSource!.tag as TrackInfo).details ?? '';
          return details.isNotEmpty
              ? ActionContainerWidget<TrackInfoWidget>(
                  child: Text(
                    details,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              : const NoActionWidget<TrackInfoWidget>();
        } else {
          return const CircularProgressIndicatorWidget();
        }
      },
    );
  }
}
