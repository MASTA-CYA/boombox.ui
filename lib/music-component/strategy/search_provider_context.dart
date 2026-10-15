import 'package:boombox/commons_barrel.dart';
import 'package:boombox/music-component/models/media_category_interface.dart';
import 'package:boombox/music-component/strategy/search_strategy_interface.dart';

class SearchProvider {
  SearchStrategy? _searchStrategy;

  set setStrategy(SearchStrategy strategy) => _searchStrategy = strategy;

  SearchProvider();
  factory SearchProvider.fromStrategy({required SearchStrategy strategy}) {
    final SearchProvider provider = SearchProvider();
    provider._searchStrategy = strategy;
    return provider;
  }

  Future<dynamic> searchMediaAsync(String? text, List<MediaCategory> media) async {
    if (_searchStrategy.isNull) return [];
    return await _searchStrategy!.search(text, media);
  }
}
