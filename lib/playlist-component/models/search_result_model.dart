class SearchResult<T> {
  final T media;
  bool? isSelected;

  SearchResult({
    required this.media,
    this.isSelected = false,
  });
}
