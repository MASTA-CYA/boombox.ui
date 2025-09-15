enum SortOptionOrder {
  asc,
  desc,
  none,
}

extension SortOptionOrderExtension on SortOptionOrder {
  String get name => _getOrderName();

  String _getOrderName() {
    switch (this) {
      case SortOptionOrder.asc:
        return 'Ascending';
      case SortOptionOrder.desc:
        return 'Descending';
      case SortOptionOrder.none:
        return 'None';
    }
  }
}
