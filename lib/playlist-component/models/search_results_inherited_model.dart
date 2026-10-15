import 'package:boombox/music-component/models/song_model.dart';
import 'package:flutter/material.dart';

class SearchResultsInheritedWidget extends InheritedWidget {
  final List<Song> songs;

  const SearchResultsInheritedWidget({
    super.key,
    required this.songs,
    required super.child,
  });

  @override
  bool updateShouldNotify(SearchResultsInheritedWidget oldWidget) =>
      songs != oldWidget.songs;

  static SearchResultsInheritedWidget? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<SearchResultsInheritedWidget>();
  }

  static SearchResultsInheritedWidget? of(BuildContext context) {
    final SearchResultsInheritedWidget? result = maybeOf(context);
    return result;
  }
}
