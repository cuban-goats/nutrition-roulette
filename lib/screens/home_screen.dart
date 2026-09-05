import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/database.dart';
import '../models/food.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.database});

  final FoodDatabase? database;

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  static const _cycleInterval = Duration(milliseconds: 70);
  static const _cycleDuration = Duration(milliseconds: 800);

  late final FoodDatabase _database = widget.database ?? FoodDatabase();
  List<Food>? _foods;
  String? _result;
  bool _picking = false;
  Timer? _cycleTimer;

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  @override
  void dispose() {
    _cycleTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadFoods() async {
    final foods = await _database.getFoods();
    setState(() => _foods = foods);
  }

  void reload() {
    _loadFoods();
  }

  void _pickRandom() {
    final foods = _foods;
    if (foods == null || foods.isEmpty || _picking) return;
    final names = foods.map((f) => f.name).toList();
    _cycleTimer?.cancel();
    setState(() {
      _picking = true;
      _result = names[math.Random().nextInt(names.length)];
    });
    final start = DateTime.now();
    _cycleTimer = Timer.periodic(_cycleInterval, (timer) {
      if (!mounted) return;
      final done = DateTime.now().difference(start) >= _cycleDuration;
      setState(() {
        if (done) _picking = false;
        _result = names[math.Random().nextInt(names.length)];
      });
      if (done) {
        timer.cancel();
        HapticFeedback.mediumImpact();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final foods = _foods;
    final empty = foods != null && foods.isEmpty;

    if (foods == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                Icons.restaurant,
                size: 44,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'What should I eat?',
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the button and let fate decide.',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 40),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: animation,
                  child: child,
                ),
              ),
              child: _result != null
                  ? Container(
                      key: ValueKey(_result),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _result!,
                        textAlign: TextAlign.center,
                        style: textTheme.titleLarge?.copyWith(
                          color: colorScheme.onTertiaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  : Text(
                      'Nothing picked yet',
                      key: const ValueKey('hint'),
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
            ),
            const SizedBox(height: 40),
            _PickButton(
              onPressed: empty ? null : _pickRandom,
              busy: _picking,
            ),
            const SizedBox(height: 24),
            if (empty)
              Text(
                'No foods yet. Add some in the menu above.',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PickButton extends StatefulWidget {
  const _PickButton({this.onPressed, required this.busy});

  final VoidCallback? onPressed;
  final bool busy;

  @override
  State<_PickButton> createState() => _PickButtonState();
}

class _PickButtonState extends State<_PickButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  );

  @override
  void didUpdateWidget(covariant _PickButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.busy && !oldWidget.busy) {
      _spin.repeat();
    } else if (!widget.busy && _spin.isAnimating) {
      _spin.stop();
      _spin.value = 0;
    }
  }

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final enabled = widget.onPressed != null;
    final active = enabled || widget.busy;
    final borderShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(32),
    );
    final foreground =
        active ? colorScheme.onPrimary : colorScheme.onSurfaceVariant;
    return AnimatedScale(
      scale: widget.busy ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      child: Material(
        color: active
            ? colorScheme.primary
            : colorScheme.surfaceContainerHighest,
        shape: borderShape,
        clipBehavior: Clip.antiAlias,
        elevation: active ? 4 : 0,
        shadowColor: colorScheme.primary.withValues(alpha: 0.35),
        child: InkWell(
          onTap: enabled ? widget.onPressed : null,
          child: SizedBox(
            width: 240,
            height: 68,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RotationTransition(
                  turns: _spin,
                  child: Icon(Icons.shuffle, size: 26, color: foreground),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      'Pick a food!',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: foreground,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}