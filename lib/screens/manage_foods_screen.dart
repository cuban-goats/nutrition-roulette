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
  List<Food>? _foods;

  @override
  void initState() {
    super.initState();
    _loadFoods();
  }

  Future<void> _loadFoods() async {
    final foods = await _database.getFoods();
    setState(() => _foods = foods);
  }

  Future<void> _openAddFood() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddFoodScreen(database: _database),
      ),
    );
    _loadFoods();
  }

  Future<void> _openEditFood(Food food) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddFoodScreen(database: _database, food: food),
      ),
    );
    _loadFoods();
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
          child: foods == null
              ? const Center(child: CircularProgressIndicator())
              : foods.isEmpty
                  ? Center(
                      child: Text(
                        'No foods yet. Tap "Add food" to create your first entry.',
                        textAlign: TextAlign.center,
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
                            subtitle: (food.description != null &&
                                    food.description!.isNotEmpty)
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
                      },
                    ),
        ),
      ],
    );
  }
}