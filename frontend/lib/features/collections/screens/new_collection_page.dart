import 'package:flutter/material.dart';

import '../../../app/pickle_theme.dart';
import '../models/pickle_collection.dart';

class CollectionEditorResult {
  const CollectionEditorResult({this.collection, this.deleted = false});

  final PickleCollection? collection;
  final bool deleted;
}

class NewCollectionPage extends StatefulWidget {
  const NewCollectionPage({super.key, this.collection});

  final PickleCollection? collection;

  @override
  State<NewCollectionPage> createState() => _NewCollectionPageState();
}

class _NewCollectionPageState extends State<NewCollectionPage> {
  final _nameController = TextEditingController();
  CollectionType _type = CollectionType.movie;

  @override
  void initState() {
    super.initState();
    final collection = widget.collection;
    if (collection != null) {
      _nameController.text = collection.name;
      _type = collection.type;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _finish() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop(
      CollectionEditorResult(
        collection: PickleCollection(
          name: name,
          type: _type,
          items: widget.collection?.items,
        ),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final collection = widget.collection;
    if (collection == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete collection?'),
        content: Text('Delete "${collection.name}" and all its options?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      Navigator.of(context).pop(const CollectionEditorResult(deleted: true));
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.collection == null ? 'New collection' : 'Edit collection',
      ),
    ),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        children: [
          Text(
            widget.collection == null
                ? 'What are we choosing?'
                : 'Update your collection',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: PickleColors.forest,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 22),
          const _FieldLabel('COLLECTION NAME'),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _finish(),
            decoration: const InputDecoration(
              hintText: 'e.g. Friday night picks',
            ),
          ),
          const SizedBox(height: 25),
          const _FieldLabel('TYPE'),
          const SizedBox(height: 8),
          if (widget.collection == null) ...[
            SegmentedButton<CollectionType>(
              segments: const [
                ButtonSegment(
                  value: CollectionType.movie,
                  label: Text('Movie'),
                  icon: Icon(Icons.movie_outlined),
                ),
                ButtonSegment(
                  value: CollectionType.tv,
                  label: Text('TV'),
                  icon: Icon(Icons.live_tv_outlined),
                ),
                ButtonSegment(
                  value: CollectionType.custom,
                  label: Text('Custom'),
                  icon: Icon(Icons.tune),
                ),
              ],
              selected: {_type},
              onSelectionChanged: (selected) =>
                  setState(() => _type = selected.first),
            ),
            const SizedBox(height: 12),
            Text(switch (_type) {
              CollectionType.movie => 'A shortlist of movies to watch.',
              CollectionType.tv => 'A shortlist of shows or episodes.',
              CollectionType.custom => 'Make a list of absolutely anything.',
            }, style: TextStyle(color: Colors.blueGrey.shade700)),
          ] else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F6F0),
                border: Border.all(color: const Color(0xFFBCD1BE)),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Icon(_typeIcon(_type), color: PickleColors.forest),
                  const SizedBox(width: 12),
                  Text(
                    _type.label,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 30),
          if (widget.collection != null) ...[
            SizedBox(
              height: 50,
              child: OutlinedButton.icon(
                onPressed: _confirmDelete,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Delete collection'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                  side: BorderSide(color: Theme.of(context).colorScheme.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            height: 54,
            child: FilledButton(
              onPressed: _finish,
              style: FilledButton.styleFrom(
                backgroundColor: PickleColors.forest,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    ),
  );

  IconData _typeIcon(CollectionType type) => switch (type) {
    CollectionType.movie => Icons.movie_outlined,
    CollectionType.tv => Icons.live_tv_outlined,
    CollectionType.custom => Icons.tune,
  };
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      color: PickleColors.leaf,
      fontSize: 12,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.1,
    ),
  );
}
