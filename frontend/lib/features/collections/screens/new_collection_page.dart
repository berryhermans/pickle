import 'package:flutter/material.dart';

import '../../../app/pickle_theme.dart';
import '../models/pickle_collection.dart';

class NewCollectionPage extends StatefulWidget {
  const NewCollectionPage({super.key});

  @override
  State<NewCollectionPage> createState() => _NewCollectionPageState();
}

class _NewCollectionPageState extends State<NewCollectionPage> {
  final _nameController = TextEditingController();
  CollectionType _type = CollectionType.movie;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _finish() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    Navigator.of(context).pop(PickleCollection(name: name, type: _type));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('New collection')),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        children: [
          Text(
            'What are we choosing?',
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
          const SizedBox(height: 30),
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
