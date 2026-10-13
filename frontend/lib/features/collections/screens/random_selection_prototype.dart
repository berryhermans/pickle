import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/pickle_theme.dart';
import '../../picking/widgets/winner_dialog.dart';

// Three random-picker animation concepts, switchable in the bottom bar.
class RandomSelectionResult {
  const RandomSelectionResult({required this.variantIndex, this.winnerIndex});

  final int variantIndex;
  final int? winnerIndex;
}

class RandomSelectionPrototypePage extends StatefulWidget {
  const RandomSelectionPrototypePage({
    super.key,
    required this.options,
    this.initialVariant = 0,
    this.pickOnOpen = false,
    this.selectedWinnerIndex,
  });

  final List<String> options;
  final int initialVariant;
  final bool pickOnOpen;
  final int? selectedWinnerIndex;

  @override
  State<RandomSelectionPrototypePage> createState() =>
      _RandomSelectionPrototypePageState();
}

class _RandomSelectionPrototypePageState
    extends State<RandomSelectionPrototypePage>
    with SingleTickerProviderStateMixin {
  static const _variants = [
    ('Wheel', 'Prize wheel'),
    ('Reel', 'Slot machine'),
    ('Decode', 'Letter decoder'),
  ];

  final _random = math.Random();
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3600),
  )..addStatusListener(_onAnimationStatus);

  late int _variant = widget.initialVariant;
  int? _winnerIndex;
  bool _spinning = false;
  bool _showingWinner = false;

  @override
  void initState() {
    super.initState();
    if (widget.pickOnOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future<void>.delayed(const Duration(milliseconds: 350), () {
          if (mounted) _startPick();
        });
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || _showingWinner) return;
    if (widget.pickOnOpen) {
      Navigator.pop(
        context,
        RandomSelectionResult(
          variantIndex: _variant,
          winnerIndex: _winnerIndex,
        ),
      );
      return;
    }
    setState(() {
      _spinning = false;
      _showingWinner = true;
    });
    final winner = widget.options[_winnerIndex!];
    showDialog<void>(
      context: context,
      builder: (_) => WinnerDialog(winner: winner),
    ).then((_) {
      if (!mounted) return;
      setState(() => _showingWinner = false);
    });
  }

  void _startPick() {
    if (_spinning) return;
    setState(() {
      _winnerIndex =
          widget.selectedWinnerIndex ?? _random.nextInt(widget.options.length);
      _spinning = true;
      _showingWinner = false;
    });
    _controller.forward(from: 0);
  }

  void _selectVariant(int index) {
    if (index == _variant) return;
    _controller.stop();
    setState(() {
      _variant = index;
      _winnerIndex = null;
      _spinning = false;
      _showingWinner = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final winnerIndex = _winnerIndex;
    if (widget.pickOnOpen) return _buildAutomaticPick(winnerIndex);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Random picker prototype'),
        actions: [
          IconButton(
            tooltip: 'Close prototype',
            onPressed: () => Navigator.pop(
              context,
              RandomSelectionResult(variantIndex: _variant),
            ),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(22, 14, 22, 20),
              child: Column(
                children: [
                  const Text(
                    'THE PICKLE MACHINE',
                    style: TextStyle(
                      color: PickleColors.leaf,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.8,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Let fate make a show of it.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: PickleColors.forest,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${widget.options.length} options. One very important decision.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.blueGrey.shade600),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 260),
                      child: _buildVariant(
                        winnerIndex,
                        key: ValueKey(_variant),
                      ),
                    ),
                  ),
                  if (winnerIndex != null && !_spinning) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Fate has spoken: ${widget.options[winnerIndex]}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: PickleColors.forest,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton.icon(
                      onPressed: _spinning ? null : _startPick,
                      icon: Icon(
                        _spinning
                            ? Icons.hourglass_top_rounded
                            : Icons.casino_outlined,
                      ),
                      label: Text(
                        _spinning ? 'The suspense...' : 'Pick for me',
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: PickleColors.forest,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.only(bottom: 10),
        child: Center(child: _variantSwitcher()),
      ),
    );
  }

  Widget _buildAutomaticPick(int? winnerIndex) => Scaffold(
    appBar: AppBar(
      title: const Text('Making the pick...'),
      leading: IconButton(
        tooltip: 'Cancel pick',
        onPressed: () => Navigator.pop(
          context,
          RandomSelectionResult(variantIndex: _variant),
        ),
        icon: const Icon(Icons.close),
      ),
    ),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
        child: Column(
          children: [
            const Text(
              'THE PICKLE MACHINE',
              style: TextStyle(
                color: PickleColors.leaf,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.8,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _spinning ? 'Fate is deciding...' : 'Getting things ready...',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: PickleColors.forest,
                fontWeight: FontWeight.w900,
              ),
            ),
            Expanded(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, _) =>
                    _buildVariant(winnerIndex, key: ValueKey(_variant)),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _spinning ? 'NO PEEKING...' : 'ONE MOMENT...',
              style: const TextStyle(
                color: PickleColors.leaf,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _buildVariant(int? winnerIndex, {required Key key}) {
    return switch (_variant) {
      0 => _buildWheel(winnerIndex, key),
      1 => _buildReel(winnerIndex, key),
      _ => _buildDecoder(winnerIndex, key),
    };
  }

  Widget _buildWheel(int? winnerIndex, Key key) => Center(
    key: key,
    child: AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final rotation = _wheelRotation(winnerIndex);
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 18),
              child: Transform.rotate(
                angle: rotation,
                child: CustomPaint(
                  size: const Size.square(286),
                  painter: _WheelPainter(widget.options),
                ),
              ),
            ),
            const Icon(
              Icons.arrow_drop_down,
              color: PickleColors.forest,
              size: 48,
            ),
            Positioned(
              bottom: 7,
              child: Text(
                _spinning
                    ? 'ROUND AND ROUND...'
                    : winnerIndex == null
                    ? 'SPIN TO FIND OUT'
                    : 'THE WHEEL HAS SPOKEN',
                style: const TextStyle(
                  color: PickleColors.leaf,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                ),
              ),
            ),
          ],
        );
      },
    ),
  );

  double _wheelRotation(int? winnerIndex) {
    if (winnerIndex == null) return 0;
    final slice = 2 * math.pi / widget.options.length;
    final target = 2 * math.pi * 7 - (winnerIndex + 0.5) * slice;
    final progress = _spinning ? _controller.value : 1.0;
    return Curves.easeOutCubic.transform(progress) * target;
  }

  Widget _buildReel(int? winnerIndex, Key key) => Center(
    key: key,
    child: AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final reelIndex = _reelIndex(winnerIndex);
        final title = reelIndex == null ? 'READY?' : widget.options[reelIndex];
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'LUCKY PICK',
              style: TextStyle(
                color: PickleColors.leaf,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 142),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                color: PickleColors.forest,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: PickleColors.lime, width: 5),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x3024472F),
                    blurRadius: 20,
                    offset: Offset(0, 9),
                  ),
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 75),
                child: Text(
                  title,
                  key: ValueKey('$reelIndex-$title'),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    height: 1.08,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              _spinning ? 'TICK... TICK... TICK...' : 'PULL THE LEVER',
              style: TextStyle(
                color: Colors.blueGrey.shade600,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ],
        );
      },
    ),
  );

  int? _reelIndex(int? winnerIndex) {
    if (winnerIndex == null) return null;
    if (!_spinning) return winnerIndex;
    final progress = Curves.easeOutCubic.transform(_controller.value);
    final remaining = (1 - progress) * 34;
    return remaining < 0.35
        ? winnerIndex
        : (remaining.floor() + _controller.value.floor() * 17) %
              widget.options.length;
  }

  Widget _buildDecoder(int? winnerIndex, Key key) => Center(
    key: key,
    child: AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final progress = _controller.value;
        final result = winnerIndex == null
            ? '?????'
            : widget.options[winnerIndex].toUpperCase();
        final text = _decodedText(result, progress, winnerIndex);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 32, 18, 28),
              decoration: BoxDecoration(
                color: const Color(0xFF102D27),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: PickleColors.leaf, width: 2),
              ),
              child: Column(
                children: [
                  const Text(
                    'DECODING YOUR DESTINY',
                    style: TextStyle(
                      color: PickleColors.lime,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 22),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      text,
                      maxLines: 1,
                      style: const TextStyle(
                        color: Color(0xFFB9F7BB),
                        fontFamily: 'monospace',
                        fontSize: 29,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _spinning ? 'THE SIGNAL IS CLEARING...' : 'CRACK THE CODE',
              style: TextStyle(
                color: Colors.blueGrey.shade600,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ],
        );
      },
    ),
  );

  String _decodedText(String result, double progress, int? winnerIndex) {
    if (!_spinning || winnerIndex == null) return result;
    final chars = result.split('');
    for (var index = 0; index < chars.length; index++) {
      final revealAt = 0.3 + index / math.max(chars.length, 1) * 0.48;
      if (progress < revealAt) {
        final seed = (progress * 1000).floor() + index * 13;
        chars[index] = String.fromCharCode(65 + seed % 26);
      }
    }
    return chars.join();
  }

  Widget _variantSwitcher() => Material(
    color: PickleColors.forest,
    elevation: 8,
    borderRadius: BorderRadius.circular(30),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: 'Previous animation',
            onPressed: () => _selectVariant((_variant - 1) % _variants.length),
            icon: const Icon(Icons.chevron_left, color: Colors.white),
          ),
          Text(
            '${_variants[_variant].$1} (${_variants[_variant].$2})',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          IconButton(
            tooltip: 'Next animation',
            onPressed: () => _selectVariant((_variant + 1) % _variants.length),
            icon: const Icon(Icons.chevron_right, color: Colors.white),
          ),
        ],
      ),
    ),
  );
}

class _WheelPainter extends CustomPainter {
  _WheelPainter(this.options);

  final List<String> options;
  static const _colors = [
    PickleColors.leaf,
    Color(0xFFFFB24A),
    Color(0xFFEF7471),
    Color(0xFF64B7B0),
    PickleColors.forest,
    Color(0xFFAACB58),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2;
    final slice = 2 * math.pi / options.length;
    for (var index = 0; index < options.length; index++) {
      final start = -math.pi / 2 + slice * index;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        slice,
        true,
        Paint()..color = _colors[index % _colors.length],
      );
      final option = options[index].trim();
      final label = option.isEmpty
          ? '?'
          : options.length <= 8
          ? option
          : option.characters.first.toUpperCase();
      final text = TextPainter(
        text: TextSpan(
          text: label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
        ellipsis: '…',
      )..layout(maxWidth: math.max(14, radius * 0.88 * slice));
      final angle = start + slice / 2;
      final labelCenter =
          center + Offset(math.cos(angle), math.sin(angle)) * radius * 0.68;
      text.paint(canvas, labelCenter - Offset(text.width / 2, text.height / 2));
    }
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = PickleColors.forest
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    canvas.drawCircle(center, 20, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _WheelPainter oldDelegate) =>
      oldDelegate.options != options;
}
