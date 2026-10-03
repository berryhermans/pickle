import 'package:flutter_test/flutter_test.dart';
import 'package:pickle/features/collections/data/media_search_service.dart';
import 'package:pickle/features/collections/models/collection_item.dart';
import 'package:pickle/features/collections/models/pickle_collection.dart';

void main() {
  test(
    'parses a movie search payload into provider-backed collection items',
    () {
      final items = MediaSearchService.parseResults(
        type: CollectionType.movie,
        payload: [
          {
            'title': 'Arrival',
            'providerId': '42',
            'posterUrl': 'https://example.com/arrival.jpg',
            'durationMinutes': 116,
            'genres': ['Sci-Fi', 'Drama'],
          },
        ],
      );

      expect(items, hasLength(1));
      expect(items.first.title, 'Arrival');
      expect(items.first.source, CollectionItemSource.tmdb);
      expect(items.first.providerId, '42');
      expect(items.first.durationMinutes, 116);
      expect(items.first.genres, ['Sci-Fi', 'Drama']);
    },
  );
}
