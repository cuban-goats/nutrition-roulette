import 'dart:async';

import 'package:flutter/material.dart';

import '../data/database.dart';
import '../models/food.dart';
import 'add_food_screen.dart';

class ManageFoodsScreen extends StatefulWidget {
  const ManageFoodsScreen({super.key, this.database});

  final FoodDatabase? database;

  @override
  State<ManageFoodsScreen> createState() => _ManageFoodsScreenState();
}

class _ManageFoodsScreenState extends State<ManageFoodsScreen> {
  late final FoodDatabase _database = widget.database ?? FoodDatabase();
  List<Food> _items = [];
  bool _loading = true;
  final Set<int> _removing = {};
  final Map<int, int> _editGen = {};

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  Future<void> _loadFoods() async {
    final foods = await _database.getFoods();
    setState(() {
      _items = foods;
      _loading = false;
    });
  }

  Future<void> _openAddFood() async {
    final result = await Navigator.of(context).push<(String, String?)>(
      MaterialPageRoute(builder: (_) => const AddFoodScreen()),
    );
    if (result == null) return;
    final (name, description) = result;
    final id = await _database.addFood(name, description: description);
    final food = Food(id: id, name: name, description: description);
    if (!mounted) return;
    setState(() {
      _items = [..._items, food]
        ..sort((a, b) => a.name.compareTo(b.name));
    });
  }

  Future<void> _openEditFood(Food food) async {
    final result = await Navigator.of(context).push<(String, String?)>(
      MaterialPageRoute(builder: (_) => AddFoodScreen(food: food)),
    );
    if (result == null) return;
    final (name, description) = result;
    await _database.updateFood(
      Food(id: food.id, name: name, description: description),
    );
    if (!mounted) return;
    setState(() {
      _editGen[food.id!] = (_editGen[food.id!] ?? 0) + 1;
    });
    await _loadFoods();
  }

  void _deleteFood(Food food) {
    setState(() => _removing.add(food.id!));
    _showDeletedToast(food);
  }

  void _showDeletedToast(Food food) {
    final overlay = Overlay.of(context, rootOverlay: true);
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _FoodToast(
        message: 'Deleted ${food.name}',
        actionLabel: 'Undo',
        onAction: () {
          entry.remove();
          _undoDelete(food);
        },
        onDismissed: entry.remove,
      ),
    );
    overlay.insert(entry);
  }

  Future<void> _finishDelete(Food food) async {
    await _database.deleteFood(food.id!);
    if (!mounted) return;
    setState(() {
      _removing.remove(food.id!);
      _items = List.of(_items)..removeWhere((f) => f.id == food.id);
    });
  }

  Future<void> _undoDelete(Food food) async {
    setState(() => _removing.remove(food.id!));
    await _database.addFood(food.name, description: food.description);
    if (!mounted) return;
    _loadFoods();
  }

  Widget _buildCard(Food food) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.surfaceContainerHighest,
          foregroundColor: colorScheme.primary,
          child: const Icon(Icons.fastfood),
        ),
        title: Text(
          food.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: (food.description != null && food.description!.isNotEmpty)
            ? Text(
                food.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              )
            : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Edit',
              onPressed: () => _openEditFood(food),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Delete',
              onPressed: () => _deleteFood(food),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _openAddFood,
              icon: const Icon(Icons.add),
              label: const Text('Add food'),
            ),
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _items.isEmpty
                  ? Center(
                      child: Text(
                        'No foods yet. Tap "Add food" to create your first entry.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final food = _items[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _Entrance(
                            key: ValueKey(
                              '${food.id}-${_editGen[food.id] ?? 0}',
                            ),
                            child: _RemovableCard(
                              removing: _removing.contains(food.id),
                              onDismissed: () => _finishDelete(food),
                              child: _buildCard(food),
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}

class _Entrance extends StatelessWidget {
  const _Entrance({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      child: child,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 24 * (1 - value)),
          child: child,
        ),
      ),
    );
  }
}

class _RemovableCard extends StatefulWidget {
  const _RemovableCard({
    required this.child,
    required this.removing,
    required this.onDismissed,
  });

  final Widget child;
  final bool removing;
  final VoidCallback onDismissed;

  @override
  State<_RemovableCard> createState() => _RemovableCardState();
}

class _RemovableCardState extends State<_RemovableCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );
  bool _removing = false;

  @override
  void didUpdateWidget(covariant _RemovableCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.removing && !_removing) {
      _removing = true;
      _controller.forward().whenComplete(widget.onDismissed);
    } else if (!widget.removing && _removing) {
      _removing = false;
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = Curves.easeInCubic.transform(_controller.value);
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: 1 - 0.9 * t,
            child: Opacity(
              opacity: 1 - t,
              child: Transform.scale(
                scale: 1 - 0.2 * t,
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FoodToast extends StatefulWidget {
  const _FoodToast({
    required this.message,
    required this.actionLabel,
    required this.onAction,
    required this.onDismissed,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;
  final VoidCallback onDismissed;

  @override
  State<_FoodToast> createState() => _FoodToastState();
}

class _FoodToastState extends State<_FoodToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _timer = Timer(const Duration(milliseconds: 2200), _dismiss);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() {
    _timer?.cancel();
    _controller.reverse().then((_) {
      if (mounted) widget.onDismissed();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Positioned(
      left: 16,
      right: 16,
      bottom: 112,
      child: IgnorePointer(
        ignoring: _controller.status == AnimationStatus.reverse,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = Curves.easeOutCubic.transform(_controller.value);
            return Opacity(
              opacity: t,
              child: Transform.translate(
                offset: Offset(0, 24 * (1 - t)),
                child: child,
              ),
            );
          },
          child: Material(
            color: colorScheme.inverseSurface,
            elevation: 6,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.only(left: 16, right: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.message,
                      style: TextStyle(
                        color: colorScheme.onInverseSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: widget.onAction,
                    child: Text(widget.actionLabel),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}