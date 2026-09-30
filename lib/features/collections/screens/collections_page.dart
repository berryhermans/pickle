import 'package:flutter/material.dart';

import '../../../app/pickle_theme.dart';
import '../data/collection_storage.dart';
import '../models/pickle_collection.dart';
import 'collection_page.dart';
import 'new_collection_page.dart';

class CollectionsPage extends StatefulWidget {
  const CollectionsPage({super.key});

  @override
  State<CollectionsPage> createState() => _CollectionsPageState();
}

class _CollectionsPageState extends State<CollectionsPage> {
  final List<PickleCollection> _collections = [];
  final CollectionStorage _storage = CollectionStorage();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  Future<void> _loadCollections() async {
    final collections = await _storage.load();
    if (!mounted) return;
    setState(() {
      _collections
        ..clear()
        ..addAll(collections);
      _isLoading = false;
    });
  }

  Future<void> _saveCollections() => _storage.save(_collections);

  Future<void> _addCollection() async {
    final collection = await Navigator.of(context).push<PickleCollection>(
      MaterialPageRoute(builder: (_) => const NewCollectionPage()),
    );
    if (!mounted || collection == null) return;
    setState(() => _collections.add(collection));
    await _saveCollections();
    await _openCollection(collection);
  }

  Future<void> _openCollection(PickleCollection collection) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) =>
            CollectionPage(collection: collection, onChanged: _saveCollections),
      ),
    );
    if (!mounted) return;
    setState(() {});
    await _saveCollections();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const _BrandTitle(),
      actions: [
        IconButton(
          tooltip: 'About Pickle',
          onPressed: () => showAboutDialog(
            context: context,
            applicationName: 'Pickle',
            children: const [Text('A little help choosing.')],
          ),
          icon: const Icon(Icons.info_outline),
        ),
      ],
    ),
    body: SafeArea(
      child: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _collections.isEmpty
                ? const _EmptyCollections()
                : ListView(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                    children: [
                      Text(
                        'YOUR COLLECTIONS',
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: PickleColors.leaf,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.2,
                            ),
                      ),
                      const SizedBox(height: 12),
                      for (final collection in _collections)
                        _CollectionRow(
                          collection: collection,
                          onTap: () => _openCollection(collection),
                        ),
                    ],
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: FilledButton.icon(
                onPressed: _addCollection,
                icon: const Icon(Icons.add),
                label: const Text('Add collection'),
                style: FilledButton.styleFrom(
                  backgroundColor: PickleColors.forest,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _BrandTitle extends StatelessWidget {
  const _BrandTitle();

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: PickleColors.lime,
          borderRadius: BorderRadius.circular(11),
        ),
        child: const Icon(Icons.spa, color: PickleColors.forest, size: 21),
      ),
      const SizedBox(width: 10),
      Text(
        'pickle',
        style: Theme.of(context).textTheme.titleLarge
            ?.copyWith(color: PickleColors.forest, fontWeight: FontWeight.w900),
      ),
    ],
  );
}

class _EmptyCollections extends StatelessWidget {
  const _EmptyCollections();

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 106,
            height: 106,
            decoration: const BoxDecoration(
              color: Color(0xFFE2EEDC),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.format_list_bulleted,
              size: 44,
              color: PickleColors.forest,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'A list for every little pickle.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: PickleColors.forest,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start with a collection of things you might want to choose.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge
                ?.copyWith(color: Colors.blueGrey.shade700),
          ),
        ],
      ),
    ),
  );
}

class _CollectionRow extends StatelessWidget {
  const _CollectionRow({required this.collection, required this.onTap});

  final PickleCollection collection;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F1E2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(switch (collection.type) {
                  CollectionType.movie => Icons.movie_outlined,
                  CollectionType.tv => Icons.live_tv_outlined,
                  CollectionType.custom => Icons.list_alt,
                }, color: PickleColors.forest),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      collection.name,
                      style: const TextStyle(
                        color: PickleColors.forest,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${collection.type.label}  ·  ${collection.items.length} ${collection.items.length == 1 ? 'option' : 'options'}',
                      style: TextStyle(color: Colors.blueGrey.shade600),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: PickleColors.leaf),
            ],
          ),
        ),
      ),
    ),
  );
}
