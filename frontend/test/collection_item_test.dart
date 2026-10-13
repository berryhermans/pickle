import 'package:flutter_test/flutter_test.dart';
import 'package:pickle/features/collections/models/collection_item.dart';

void main() {
  test('round trips provider metadata', () {
    final item = CollectionItem(
      title: 'A Movie',
      source: CollectionItemSource.omdb,
      providerId: '42',
      posterUrl: 'https://image.example/poster.jpg',
      durationMinutes: 108,
      genres: ['Drama', 'Mystery'],
    );

    final restored = CollectionItem.fromJson(item.toJson());

    expect(restored.title, item.title);
    expect(restored.source, item.source);
    expect(restored.providerId, item.providerId);
    expect(restored.posterUrl, item.posterUrl);
    expect(restored.durationMinutes, item.durationMinutes);
    expect(restored.genres, item.genres);
    expect(restored.id, item.id);
  });

  test('loads legacy string entries as manual items', () {
    final restored = CollectionItem.fromStorage('Old saved option');

    expect(restored?.title, 'Old saved option');
    expect(restored?.source, CollectionItemSource.manual);
    expect(restored?.posterUrl, isNull);
    expect(restored?.id, isNotEmpty);
  });

  test('duplicate-title entries receive distinct stable identities', () {
    final first = CollectionItem.manual('Same title');
    final second = CollectionItem.manual('Same title');

    expect(first.id, isNot(second.id));
    expect(CollectionItem.fromJson(first.toJson()).id, first.id);
  });
}