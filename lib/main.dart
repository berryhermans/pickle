import 'dart:math' as math;

import 'package:flutter/material.dart';

void main() => runApp(const PickleApp());

const _forest = Color(0xFF164B37);
const _leaf = Color(0xFF3D9364);
const _lime = Color(0xFFD8F36A);
const _paper = Color(0xFFF5F7EF);

class PickleApp extends StatelessWidget {
  const PickleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: _leaf,
          brightness: Brightness.light,
        ).copyWith(
          primary: _forest,
          secondary: _leaf,
          tertiary: _lime,
          surface: _paper,
        );
    return MaterialApp(
      title: 'Pickle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: scheme,
        scaffoldBackgroundColor: _paper,
        appBarTheme: const AppBarTheme(
          backgroundColor: _paper,
          foregroundColor: _forest,
          elevation: 0,
          centerTitle: false,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
        useMaterial3: true,
      ),
      home: const CollectionsPage(),
    );
  }
}

enum CollectionType { movie, tv, custom }

extension CollectionTypeLabel on CollectionType {
  String get label => switch (this) {
    CollectionType.movie => 'Movie',
    CollectionType.tv => 'TV',
    CollectionType.custom => 'Custom',
  };
}

class PickleCollection {
  PickleCollection({required this.name, required this.type});

  final String name;
  final CollectionType type;
  final List<String> items = [];
}

class CollectionsPage extends StatefulWidget {
  const CollectionsPage({super.key});

  @override
  State<CollectionsPage> createState() => _CollectionsPageState();
}

class _CollectionsPageState extends State<CollectionsPage> {
  final List<PickleCollection> _collections = [];

  Future<void> _addCollection() async {
    final collection = await Navigator.of(context).push<PickleCollection>(
      MaterialPageRoute(builder: (_) => const NewCollectionPage()),
    );
    if (!mounted || collection == null) return;
    setState(() => _collections.add(collection));
    await _openCollection(collection);
  }

  Future<void> _openCollection(PickleCollection collection) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => CollectionPage(collection: collection)),
    );
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              child: _collections.isEmpty
                  ? const _EmptyCollections()
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      children: [
                        Text(
                          'YOUR COLLECTIONS',
                          style: Theme.of(context).textTheme.labelMedium
                              ?.copyWith(
                                color: _leaf,
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
                    backgroundColor: _forest,
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
          color: _lime,
          borderRadius: BorderRadius.circular(11),
        ),
        child: const Icon(Icons.spa, color: _forest, size: 21),
      ),
      const SizedBox(width: 10),
      Text(
        'pickle',
        style: Theme.of(context).textTheme.titleLarge
            ?.copyWith(color: _forest, fontWeight: FontWeight.w900),
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
              color: _forest,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'A list for every little pickle.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(color: _forest, fontWeight: FontWeight.w800),
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
                child: Icon(
                  collection.type == CollectionType.movie
                      ? Icons.movie_outlined
                      : collection.type == CollectionType.tv
                      ? Icons.live_tv_outlined
                      : Icons.list_alt,
                  color: _forest,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      collection.name,
                      style: const TextStyle(
                        color: _forest,
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
              const Icon(Icons.chevron_right, color: _leaf),
            ],
          ),
        ),
      ),
    ),
  );
}

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
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(color: _forest, fontWeight: FontWeight.w800),
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
                backgroundColor: _forest,
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
      color: _leaf,
      fontSize: 12,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.1,
    ),
  );
}

enum PickMethod { random, tournament, kingOfTheHill }

extension PickMethodLabel on PickMethod {
  String get label => switch (this) {
    PickMethod.random => 'Random',
    PickMethod.tournament => 'Tournament',
    PickMethod.kingOfTheHill => 'King of the hill',
  };

  String get description => switch (this) {
    PickMethod.random => 'Let fate pick one for you.',
    PickMethod.tournament => 'Choose your way through a bracket.',
    PickMethod.kingOfTheHill => 'Keep your favorite. Face a new challenger.',
  };
}

class CollectionPage extends StatefulWidget {
  const CollectionPage({super.key, required this.collection});

  final PickleCollection collection;

  @override
  State<CollectionPage> createState() => _CollectionPageState();
}

class _CollectionPageState extends State<CollectionPage> {
  final _random = math.Random();
  List<String> _players = [];
  List<String> _roundWinners = [];
  String? _king;
  String? _challenger;
  int _matchIndex = 0;
  PickMethod? _method;

  Future<void> _addItem() async {
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
    setState(() => widget.collection.items.add(value));
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
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(color: _forest, fontWeight: FontWeight.w800),
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
                      leading: Icon(_methodIcon(method), color: _leaf),
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
    final shuffled = List<String>.of(widget.collection.items)..shuffle(_random);
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
    final options = List<String>.of(widget.collection.items)..shuffle(_random);
    _king = options.removeLast();
    _players = options;
    _challenger = _players.removeLast();
    setState(() {});
  }

  void _selectOption(String option) {
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
      _king = option;
      if (_players.isEmpty) {
        _declareWinner(_king!);
        return;
      }
      _challenger = _players.removeLast();
      setState(() {});
    }
  }

  Future<void> _declareWinner(String winner) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) => _WinnerDialog(winner: winner),
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
        title: Text(widget.collection.name),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: Center(
              child: Text(
                widget.collection.type.label.toUpperCase(),
                style: const TextStyle(
                  color: _leaf,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ),
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
                            foregroundColor: _forest,
                            child: Text('${index + 1}'),
                          ),
                          title: Text(
                            items[index],
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          trailing: IconButton(
                            tooltip: 'Remove ${items[index]}',
                            icon: const Icon(Icons.close),
                            onPressed: () =>
                                setState(() => items.removeAt(index)),
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
                          foregroundColor: _forest,
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
                          backgroundColor: _forest,
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
          const Icon(Icons.splitscreen, size: 50, color: _leaf),
          const SizedBox(height: 14),
          Text(
            'Add a few options',
            style: Theme.of(context).textTheme.titleLarge
                ?.copyWith(color: _forest, fontWeight: FontWeight.w800),
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
    final left = isTournament ? _players[_matchIndex * 2] : _king!;
    final right = isTournament ? _players[_matchIndex * 2 + 1] : _challenger!;
    final matchNumber = isTournament ? _matchIndex + 1 : null;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            isTournament ? 'TOURNAMENT' : 'KING OF THE HILL',
            style: const TextStyle(
              color: _leaf,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.3,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            isTournament ? 'Pick the one that wins' : 'Who stays on top?',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(color: _forest, fontWeight: FontWeight.w800),
          ),
          if (matchNumber != null) ...[
            const SizedBox(height: 7),
            Text(
              'Match $matchNumber of ${_players.length ~/ 2}',
              style: TextStyle(color: Colors.blueGrey.shade600),
            ),
          ],
          const SizedBox(height: 30),
          _OptionButton(label: left, onTap: () => _selectOption(left)),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 13),
            child: Text(
              'OR',
              style: TextStyle(
                color: _leaf,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.4,
              ),
            ),
          ),
          _OptionButton(label: right, onTap: () => _selectOption(right)),
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
        foregroundColor: _forest,
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

class _WinnerDialog extends StatefulWidget {
  const _WinnerDialog({required this.winner});

  final String winner;

  @override
  State<_WinnerDialog> createState() => _WinnerDialogState();
}

class _WinnerDialogState extends State<_WinnerDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    child: Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Positioned(
          top: -40,
          left: 0,
          right: 0,
          height: 100,
          child: IgnorePointer(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (_, _) =>
                  CustomPaint(painter: _ConfettiPainter(_controller.value)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 34, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: const BoxDecoration(
                  color: Color(0xFFEAF5D5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.celebration, color: _forest, size: 31),
              ),
              const SizedBox(height: 17),
              Text(
                'Your pickle is solved!',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(color: _forest, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 7),
              Text(
                widget.winner,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(color: _leaf, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 21),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: _forest,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Lovely'),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.progress);

  final double progress;

  static const _colors = [
    _lime,
    _leaf,
    Color(0xFFFFB24A),
    Color(0xFFEF7471),
    Color(0xFF64B7B0),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (var index = 0; index < 34; index++) {
      final seed = index * 2.399;
      final startX = (index * 47.0 + 13) % size.width;
      final x = startX + math.sin(seed + progress * 5) * 16;
      final y = ((index * 31.0 + progress * 120) % (size.height + 30)) - 15;
      final paint = Paint()..color = _colors[index % _colors.length];
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(seed + progress * 4);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: 6, height: 10),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
