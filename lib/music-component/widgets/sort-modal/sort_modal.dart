import 'package:boombox/common/constants.dart';
import 'package:boombox/common/extensions.dart';
import 'package:boombox/music-component/models/enums/sort_option_order_enum.dart';
import 'package:boombox/music-component/widgets/album_view.dart';
import 'package:boombox/music-component/widgets/artist_view.dart';
import 'package:boombox/music-component/widgets/song_view.dart';
import 'package:boombox/music-component/widgets/sort-modal/sort_option.dart';
import 'package:flutter/material.dart';

class SortModalWidget<T> extends StatefulWidget {
  final MapEntry<String?, SortOptionOrder> order;
  final void Function(String option, SortOptionOrder order) onOrderChanged;

  const SortModalWidget({
    super.key,
    required this.order,
    required this.onOrderChanged,
  });

  @override
  State<SortModalWidget<T>> createState() => _SortModalWidgetState<T>();
}

class _SortModalWidgetState<T> extends State<SortModalWidget<T>> {
  late ValueNotifier<SortOptionOrder> _order;
  late ValueNotifier<Map<String, bool>> _songOptionsAvailability;
  late ValueNotifier<Map<String, bool>> _albumOptionsAvailability;
  late ValueNotifier<Map<String, bool>> _artistOptionsAvailability;

  @override
  void initState() {
    super.initState();

    _order = ValueNotifier<SortOptionOrder>(widget.order.value);
    _songOptionsAvailability = ValueNotifier<Map<String, bool>>(
      {
        'Name': widget.order.key?.equals('Name') ?? true,
        'Added': widget.order.key?.equals('Added') ?? true,
        'Date': widget.order.key?.equals('Date') ?? true,
        'Duration': widget.order.key?.equals('Duration') ?? true,
      },
    );
    _albumOptionsAvailability = ValueNotifier<Map<String, bool>>(
      {
        'Name': widget.order.key?.equals('Name') ?? true,
        'Added': widget.order.key?.equals('Added') ?? true,
        'Date': widget.order.key?.equals('Date') ?? true,
        'Duration': widget.order.key?.equals('Duration') ?? true,
      },
    );
    _artistOptionsAvailability = ValueNotifier<Map<String, bool>>(
      {
        'Name': widget.order.key?.equals('Name') ?? true,
        'Albums': widget.order.key?.equals('Albums') ?? true,
        'Songs': widget.order.key?.equals('Songs') ?? true,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        _buildSortHeader(context),
        _buildSortOptions(context),
      ],
    );
  }

  Widget _buildSortHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(14, 5, 14, 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Sort',
            style: Theme.of(context).textTheme.titleMedium?.merge(
                  const TextStyle(
                    fontFamily: FontFamily.PRIMARY,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          ),
          ValueListenableBuilder(
            valueListenable: _order,
            builder: (context, order, child) => Row(
              children: [
                const Text('Order'),
                const SizedBox(width: 5),
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: order == SortOptionOrder.none
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  order.name,
                  style: Theme.of(context).textTheme.bodyMedium?.merge(
                        TextStyle(
                          // fontFamily: FontFamilies.PRIMARY,
                          color: order == SortOptionOrder.none
                              ? Theme.of(context).colorScheme.secondary
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSortOptions(BuildContext context) {
    Widget options;

    switch (T) {
      case SongViewWidget:
        options = ValueListenableBuilder(
          valueListenable: _songOptionsAvailability,
          builder: (context, map, child) => _buildSongViewOptions(context, map),
        );
        break;
      case AlbumViewWidget:
        options = ValueListenableBuilder(
          valueListenable: _albumOptionsAvailability,
          builder: (context, map, child) =>
              _buildAlbumViewOptions(context, map),
        );
        break;
      case ArtistViewWidget:
        options = ValueListenableBuilder(
          valueListenable: _artistOptionsAvailability,
          builder: (context, map, child) =>
              _buildArtistViewOptions(context, map),
        );
        break;
      default:
        options = const SizedBox.shrink();
    }

    return Expanded(child: options);
  }

  Widget _buildSongViewOptions(
    BuildContext context,
    Map<String, bool> availabilities,
  ) {
    return Column(
      children: [
        SortOptionWidget(
          text: 'Name',
          isAvailable: availabilities['Name'],
          previousOrder: widget.order.key?.equals('Name') ?? false
              ? widget.order.value
              : null,
          onOptionChanged: (order) => _onSongOrderChange('Name', order),
        ),
        SortOptionWidget(
          text: 'Date Added',
          isAvailable: availabilities['Added'],
          previousOrder: widget.order.key?.equals('Added') ?? false
              ? widget.order.value
              : null,
          onOptionChanged: (order) => _onSongOrderChange('Added', order),
        ),
        SortOptionWidget(
          text: 'Year Released',
          isAvailable: availabilities['Date'],
          previousOrder: widget.order.key?.equals('Date') ?? false
              ? widget.order.value
              : null,
          onOptionChanged: (order) => _onSongOrderChange('Date', order),
        ),
        SortOptionWidget(
          text: 'Duration',
          isAvailable: availabilities['Duration'],
          previousOrder: widget.order.key?.equals('Duration') ?? false
              ? widget.order.value
              : null,
          onOptionChanged: (order) => _onSongOrderChange('Duration', order),
        ),
      ],
    );
  }

  Widget _buildArtistViewOptions(
    BuildContext context,
    Map<String, bool> availabilities,
  ) {
    return Column(
      children: [
        SortOptionWidget(
          text: 'Name',
          isAvailable: availabilities['Name'],
          previousOrder: widget.order.key?.equals('Name') ?? false
              ? widget.order.value
              : null,
          onOptionChanged: (order) => _onArtistOrderChange('Name', order),
        ),
        SortOptionWidget(
          text: 'Albums',
          isAvailable: availabilities['Albums'],
          previousOrder: widget.order.key?.equals('Albums') ?? false
              ? widget.order.value
              : null,
          onOptionChanged: (order) => _onArtistOrderChange('Albums', order),
        ),
        SortOptionWidget(
          text: 'Songs',
          isAvailable: availabilities['Songs'],
          previousOrder: widget.order.key?.equals('Songs') ?? false
              ? widget.order.value
              : null,
          onOptionChanged: (order) => _onArtistOrderChange('Songs', order),
        ),
      ],
    );
  }

  void _onSongOrderChange(String option, SortOptionOrder order) {
    Map<String, bool> newAvailabilities = {};

    switch (order) {
      case SortOptionOrder.asc:
      case SortOptionOrder.desc:
        for (MapEntry<String, bool> map
            in _songOptionsAvailability.value.entries) {
          newAvailabilities.addEntries(
            [MapEntry<String, bool>(map.key, map.key.equals(option))],
          );
        }
        break;
      case SortOptionOrder.none:
        for (MapEntry<String, bool> map
            in _songOptionsAvailability.value.entries) {
          newAvailabilities.addEntries(
            [MapEntry<String, bool>(map.key, true)],
          );
        }
        break;
    }
    _songOptionsAvailability.value = newAvailabilities;
    _order.value = order;
    widget.onOrderChanged(option, order);
  }

  Widget _buildAlbumViewOptions(
    BuildContext context,
    Map<String, bool> availabilities,
  ) {
    return Column(
      children: [
        SortOptionWidget(
          text: 'Name',
          isAvailable: availabilities['Name'],
          previousOrder: widget.order.key?.equals('Name') ?? false
              ? widget.order.value
              : null,
          onOptionChanged: (order) => _onAlbumOrderChange('Name', order),
        ),
        SortOptionWidget(
          text: 'Date Added',
          isAvailable: availabilities['Added'],
          previousOrder: widget.order.key?.equals('Added') ?? false
              ? widget.order.value
              : null,
          onOptionChanged: (order) => _onAlbumOrderChange('Added', order),
        ),
        SortOptionWidget(
          text: 'Year Released',
          isAvailable: availabilities['Date'],
          previousOrder: widget.order.key?.equals('Date') ?? false
              ? widget.order.value
              : null,
          onOptionChanged: (order) => _onAlbumOrderChange('Date', order),
        ),
        SortOptionWidget(
          text: 'Total Duration',
          isAvailable: availabilities['Duration'],
          previousOrder: widget.order.key?.equals('Duration') ?? false
              ? widget.order.value
              : null,
          onOptionChanged: (order) => _onAlbumOrderChange('Duration', order),
        ),
      ],
    );
  }

  void _onAlbumOrderChange(String option, SortOptionOrder order) {
    Map<String, bool> newAvailabilities = {};

    switch (order) {
      case SortOptionOrder.asc:
      case SortOptionOrder.desc:
        for (MapEntry<String, bool> map
            in _albumOptionsAvailability.value.entries) {
          newAvailabilities.addEntries(
            [MapEntry<String, bool>(map.key, map.key.equals(option))],
          );
        }
        break;
      case SortOptionOrder.none:
        for (MapEntry<String, bool> map
            in _albumOptionsAvailability.value.entries) {
          newAvailabilities.addEntries(
            [MapEntry<String, bool>(map.key, true)],
          );
        }
        break;
    }
    _albumOptionsAvailability.value = newAvailabilities;
    _order.value = order;
    widget.onOrderChanged(option, order);
  }

  void _onArtistOrderChange(String option, SortOptionOrder order) {
    Map<String, bool> newAvailabilities = {};

    switch (order) {
      case SortOptionOrder.asc:
      case SortOptionOrder.desc:
        for (MapEntry<String, bool> map
            in _albumOptionsAvailability.value.entries) {
          newAvailabilities.addEntries(
            [MapEntry<String, bool>(map.key, map.key.equals(option))],
          );
        }
        break;
      case SortOptionOrder.none:
        for (MapEntry<String, bool> map
            in _albumOptionsAvailability.value.entries) {
          newAvailabilities.addEntries(
            [MapEntry<String, bool>(map.key, true)],
          );
        }
        break;
    }
    _albumOptionsAvailability.value = newAvailabilities;
    _order.value = order;
    widget.onOrderChanged(option, order);
  }
}
