import 'package:boombox/playlist-component/models/enums/search_type_enum.dart';
import 'package:flutter/material.dart';

class SearchTypeToggleWidget extends StatelessWidget {
  final Type searchType;
  final void Function(dynamic type) onSearchTypeChanged;

  const SearchTypeToggleWidget({
    super.key,
    required this.searchType,
    required this.onSearchTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _onSearchTypeChanged(),
      icon: ImageIcon(
        ResizeImage(
          AssetImage('assets/images/'
              '${SearchType.fromMediaCategory(searchType).icon}'
              '.png'),
          width: 70,
          height: 70,
          allowUpscaling: false,
        ),
      ),
      iconSize: 30,
    );
  }

  void _onSearchTypeChanged() {
    SearchType nextSearchType = SearchType.values.elementAt(
      _getSelectedModeIndex(),
    );
    onSearchTypeChanged(nextSearchType.mediaCategory);
  }

  int _getSelectedModeIndex() {
    SearchType currentType =
        SearchType.fromMediaCategory(searchType);
    return currentType.index == SearchType.values.length - 1
        ? 0
        : currentType.index + 1;
  }
}
