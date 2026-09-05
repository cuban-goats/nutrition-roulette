import 'package:flutter/material.dart';

import '../data/database.dart';
import '../models/food.dart';

class ManageFoodsScreen extends StatefulWidget {
  const ManageFoodsScreen({super.key, this.database});

  final FoodDatabase? database;

  @override
  State<ManageFoodsScreen> createState() => _ManageFoodsScreenState();
}

class _ManageFoodsScreenState extends State<ManageFoodsScreen> {
  final _controller = TextEditingController();
  late final FoodDatabase _database = widget.database ?? FoodDatabase();
  List<Food>? _foods;

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadFoods() async {
    final foods = await _database.getFoods();
    setState(() => _foods = foods);
  }

  Future<void> _addFood() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    _controller.clear();
    await _database.addFood(name);
    await _loadFoods();
  }

  Future<void> _deleteFood(Food food) async {
    await _database.deleteFood(food.id!);
    await _loadFoods();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final foods = _foods;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    labelText: 'Add a food',
                    hintText: 'e.g. Tacos',
                  ),
                  onSubmitted: (_) => _addFood(),
                ),
              ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: _addFood,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
        ),
        Expanded(
          child: foods == null
              ? const Center(child: CircularProgressIndicator())
              : foods.isEmpty
                  ? Center(
                      child: Text(
                        'No foods yet. Add some above!',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                      itemCount: foods.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final food = foods[index];
                        return Card(
                          margin: EdgeInsets.zero,
                          elevation: 0,
                          color: colorScheme.surfaceContainerHigh,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor:
                                  colorScheme.surfaceContainerHighest,
                              foregroundColor: colorScheme.primary,
                              child: const Icon(Icons.fastfood),
                            ),
                            title: Text(
                              food.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline),
                              tooltip: 'Delete',
                              onPressed: () => _deleteFood(food),
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