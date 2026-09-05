import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/database.dart';
import '../models/food.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.database});

  final FoodDatabase? database;

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late final FoodDatabase _database = widget.database ?? FoodDatabase();
  List<Food>? _foods;
  String? _result;

  @override
  void initState() {
    super.initState();
    _loadFoods();
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
    if (foods == null || foods.isEmpty) return;
    setState(() {
      _result = foods[math.Random().nextInt(foods.length)].name;
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

class _PickButton extends StatelessWidget {
  const _PickButton({this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final enabled = onPressed != null;
    final borderShape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(32),
    );
    final foreground =
        enabled ? colorScheme.onPrimary : colorScheme.onSurfaceVariant;
    return Material(
      color: enabled
          ? colorScheme.primary
          : colorScheme.surfaceContainerHighest,
      shape: borderShape,
      clipBehavior: Clip.antiAlias,
      elevation: enabled ? 4 : 0,
      shadowColor: colorScheme.primary.withValues(alpha: 0.35),
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: 240,
          height: 68,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shuffle, size: 26, color: foreground),
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
    );
  }
}