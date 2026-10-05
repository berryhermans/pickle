import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/pickle_theme.dart';
import '../../picking/models/pick_method.dart';
import '../../picking/widgets/winner_dialog.dart';
import '../data/media_search_service.dart';
import '../models/collection_item.dart';
import '../models/pickle_collection.dart';
import 'new_collection_page.dart';

class CollectionPage extends StatefulWidget {
  const CollectionPage({
    super.key,
    required this.collection,
    required this.onChanged,
    required this.onDeleted,
  });

  final PickleCollection collection;
  final Future<void> Function() onChanged;
  final Future<void> Function(PickleCollection collection) onDeleted;

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  final _random = math.Random();
  List<CollectionItem> _players = [];
  List<CollectionItem> _roundWinners = [];
  CollectionItem? _king;
  CollectionItem? _challenger;
  bool _kingOnLeft = true;
  int _matchIndex = 0;
  PickMethod? _method;

  Future<void> _addItem() async {
    if (widget.collection.type == CollectionType.custom) {
      var enteredItem = '';
      final item = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Add an option'),
          content: TextField(
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            onChanged: (value) => enteredItem = value,
            onSubmitted: (value) => Navigator.pop(dialogContext, value),
            decoration: const InputDecoration(hintText: 'Name your option'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, enteredItem),
              child: const Text('Add'),
            ),
          ],
        ),
      );
      final value = item?.trim();
      if (!mounted || value == null || value.isEmpty) return;
      setState(() => widget.collection.items.add(CollectionItem.manual(value)));
      await widget.onChanged();
      return;
    }

    var query = '';
    var isSearching = false;
    var results = <CollectionItem>[];

    final picked = await showDialog<CollectionItem?>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          Future<void> runSearch(String currentQuery) async {
            final trimmed = currentQuery.trim();
            query = trimmed;
            if (trimmed.isEmpty) {
              setDialogState(() {
                isSearching = false;
                results = const [];
              });
              return;
            }

            setDialogState(() => isSearching = true);
            final suggestions = await MediaSearchService.search(
              widget.collection.type,
              trimmed,
            );
            if (!dialogContext.mounted || query != trimmed) return;
            setDialogState(() {
              results = suggestions;
              isSearching = false;
            });
          }

          return AlertDialog(
            title: Text('Add ${widget.collection.type.label.toLowerCase()}'),
            content: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    autofocus: true,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.search,
                    onChanged: runSearch,
                    onSubmitted: (value) {
                      final manual = value.trim();
                      if (manual.isNotEmpty) {
                        Navigator.pop(
                          dialogContext,
                          CollectionItem.manual(manual),
                        );
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Search ${widget.collection.type.label} titles',
                    ),
                  ),
                  if (isSearching) ...[
                    const SizedBox(height: 12),
                    const LinearProgressIndicator(minHeight: 2),
                  ],
                  if (!isSearching && query.isNotEmpty && results.isEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      'No matches found. Try a different title or add it manually.',
                      style: TextStyle(color: Colors.blueGrey.shade700),
                    ),
                  ],
                  if (results.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 220),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: results.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (listContext, index) {
                          final suggestion = results[index];
                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: suggestion.posterUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      suggestion.posterUrl!,
                                      width: 38,
                                      height: 58,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) => const Icon(
                                        Icons.image_not_supported_outlined,
                                        size: 22,
                                      ),
                                    ),
                                  )
                                : const CircleAvatar(
                                    child: Icon(Icons.movie_outlined, size: 18),
                                  ),
                            title: Text(suggestion.title),
                            subtitle: suggestion.genres.isNotEmpty
                                ? Text(suggestion.genres.take(2).join(', '))
                                : null,
                            onTap: () =>
                                Navigator.pop(dialogContext, suggestion),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  final manualValue = query.trim();
                  if (manualValue.isEmpty) return;
                  Navigator.pop(
                    dialogContext,
                    CollectionItem.manual(manualValue),
                  );
                },
                child: const Text('Add manually'),
              ),
            ],
          );
        },
      ),
    );

    final selected = picked;
    if (!mounted || selected == null) return;
    setState(() => widget.collection.items.add(selected));
    await widget.onChanged();
  }

  Future<void> _removeItem(int index) async {
    setState(() => widget.collection.items.removeAt(index));
    await widget.onChanged();
  }

  Future<void> _editCollection() async {
    final result = await Navigator.of(context).push<CollectionEditorResult>(
      MaterialPageRoute(
        builder: (_) => NewCollectionPage(collection: widget.collection),
      ),
    );
    if (!mounted || result == null) return;
    if (result.deleted) {
      await widget.onDeleted(widget.collection);
      if (mounted) Navigator.of(context).pop();
      return;
    }

    final updatedCollection = result.collection;
    if (updatedCollection == null) return;
    setState(() => widget.collection.name = updatedCollection.name);
    await widget.onChanged();
  }

  Future<void> _chooseMethod() async {
    if (widget.collection.items.isEmpty) return;
    final method = await showModalBottomSheet<PickMethod>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How should we choose?',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: PickleColors.forest,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              for (final method in PickMethod.values)
                Builder(
                  builder: (context) {
                    final enabled =
                        method == PickMethod.random ||
                        widget.collection.items.length >= 2;
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      enabled: enabled,
                      leading: Icon(
                        _methodIcon(method),
                        color: PickleColors.leaf,
                      ),
                      title: Text(method.label),
                      subtitle: Text(
                        enabled
                            ? method.description
                            : 'Add one more option to use this method.',
                      ),
                      onTap: enabled
                          ? () => Navigator.pop(context, method)
                          : null,
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || method == null) return;
    _method = method;
    switch (method) {
      case PickMethod.random:
        _declareWinner(
          widget.collection.items[_random.nextInt(
            widget.collection.items.length,
          )],
        );
      case PickMethod.tournament:
        _startTournament();
      case PickMethod.kingOfTheHill:
        _startKingOfTheHill();
    }
  }

  IconData _methodIcon(PickMethod method) => switch (method) {
    PickMethod.random => Icons.casino_outlined,
    PickMethod.tournament => Icons.account_tree_outlined,
    PickMethod.kingOfTheHill => Icons.military_tech_outlined,
  };

  void _startTournament() {
    final shuffled = List<CollectionItem>.of(widget.collection.items)
      ..shuffle(_random);
    var bracketSize = 1;
    while (bracketSize * 2 <= shuffled.length) {
      bracketSize *= 2;
    }
    _players = shuffled.take(bracketSize).toList();
    _roundWinners = [];
    _matchIndex = 0;
    setState(() {});
  }

  void _startKingOfTheHill() {
    final options = List<CollectionItem>.of(widget.collection.items)
      ..shuffle(_random);
    _king = options.removeLast();
    _kingOnLeft = true;
    _players = options;
    _challenger = _players.removeLast();
    setState(() {});
  }

  void _selectOption(CollectionItem option) {
    if (_method == PickMethod.tournament) {
      _roundWinners.add(option);
      _matchIndex++;
      if (_matchIndex == _players.length ~/ 2) {
        if (_roundWinners.length == 1) {
          _declareWinner(_roundWinners.single);
          return;
        }
        _players = _roundWinners;
        _roundWinners = [];
        _matchIndex = 0;
      }
      setState(() {});
      return;
    }

    if (_method == PickMethod.kingOfTheHill) {
      final leftOption = _kingOnLeft ? _king : _challenger;
      _kingOnLeft = identical(option, leftOption);
      _king = option;
      if (_players.isEmpty) {
        _declareWinner(_king!);
        return;
      }
      _challenger = _players.removeLast();
      setState(() {});
    }
  }

  Future<void> _declareWinner(CollectionItem winner) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => WinnerDialog(winner: winner.title),
    );
    if (!mounted) return;
    setState(() {
      _method = null;
      _players = [];
      _roundWinners = [];
      _king = null;
      _challenger = null;
      _matchIndex = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.collection.items;
    final choosing =
        _method == PickMethod.tournament || _method == PickMethod.kingOfTheHill;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.collection.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            tooltip: 'Edit collection',
            onPressed: _editCollection,
            icon: const Icon(Icons.edit_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: choosing
                  ? _buildMatch()
                  : items.isEmpty
                  ? _buildEmptyItems()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                      itemCount: items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) => Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFE6F1E2),
                            foregroundColor: PickleColors.forest,
                            child: Text('${index + 1}'),
                          ),
                          title: Text(
                            items[index].title,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          trailing: IconButton(
                            tooltip: 'Remove ${items[index].title}',
                            icon: const Icon(Icons.close),
                            onPressed: () => _removeItem(index),
                          ),
                        ),
                      ),
                    ),
            ),
            if (!choosing)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 18),
                child: Column(
                  children: [
                    SizedBox(
                      height: 48,
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _addItem,
                        icon: const Icon(Icons.add),
                        label: const Text('Add an option'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: PickleColors.forest,
                          side: const BorderSide(color: Color(0xFFBCD1BE)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 56,
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: items.isEmpty ? null : _chooseMethod,
                        icon: const Icon(Icons.casino_outlined),
                        label: const Text("I'm in a pickle!"),
                        style: FilledButton.styleFrom(
                          backgroundColor: PickleColors.forest,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFFD8DED5),
                          disabledForegroundColor: Colors.blueGrey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyItems() => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.splitscreen, size: 50, color: PickleColors.leaf),
          const SizedBox(height: 14),
          Text(
            'Add a few options',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: PickleColors.forest,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your list is ready. Add an option to start choosing.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.blueGrey.shade700),
          ),
        ],
      ),
    ),
  );

  Widget _buildMatch() {
    final isTournament = _method == PickMethod.tournament;
    final left = isTournament
        ? _players[_matchIndex * 2]
        : _kingOnLeft
        ? _king!
        : _challenger!;
    final right = isTournament
        ? _players[_matchIndex * 2 + 1]
        : _kingOnLeft
        ? _challenger!
        : _king!;
    final matchNumber = isTournament ? _matchIndex + 1 : null;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isTournament ? 'TOURNAMENT' : 'KING OF THE HILL',
            style: const TextStyle(
              color: PickleColors.leaf,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.3,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            isTournament ? 'Pick the one that wins' : 'Who stays on top?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: PickleColors.forest,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (matchNumber != null) ...[
            const SizedBox(height: 7),
            Text(
              'Match $matchNumber of ${_players.length ~/ 2}',
              style: TextStyle(color: Colors.blueGrey.shade600),
            ),
          ],
          const SizedBox(height: 30),
          _OptionButton(label: left.title, onTap: () => _selectOption(left)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 13),
            child: Text(
              'OR',
              style: TextStyle(
                color: PickleColors.leaf,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.4,
              ),
            ),
          ),
          _OptionButton(label: right.title, onTap: () => _selectOption(right)),
          const SizedBox(height: 22),
          TextButton.icon(
            onPressed: () => setState(() {
              _method = null;
              _players = [];
              _roundWinners = [];
              _king = null;
              _challenger = null;
            }),
            icon: const Icon(Icons.close, size: 18),
            label: const Text('End this pickle'),
            style: TextButton.styleFrom(foregroundColor: Colors.blueGrey),
          ),
        ],
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 82,
    child: FilledButton(
      onPressed: onTap,
      style: FilledButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: PickleColors.forest,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(17),
          side: const BorderSide(color: Color(0xFFDCE7D9)),
        ),
      ),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
      ),
    ),
  );
}
