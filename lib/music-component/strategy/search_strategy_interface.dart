abstract interface class SearchStrategy<T> {
  Future<List<T>> search(String? text, List<T> media);
}
