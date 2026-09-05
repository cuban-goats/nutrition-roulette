import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nutrition_roulette/data/database.dart';
import 'package:nutrition_roulette/models/food.dart';
import 'package:nutrition_roulette/screens/main_shell.dart';
import 'package:nutrition_roulette/settings/settings_controller.dart';

class FakeFoodDatabase extends FoodDatabase {
  final List<Food> foods = [
    const Food(id: 1, name: 'Pizza'),
    const Food(id: 2, name: 'Sushi'),
  ];

  @override
  Future<List<Food>> getFoods() async => List.of(foods);

  @override
  Future<int> addFood(String name, {String? description}) async {
    foods.add(Food(id: foods.length + 1, name: name, description: description));
    return foods.length;
  }

  @override
  Future<int> updateFood(Food food) async {
    final index = foods.indexWhere((f) => f.id == food.id);
    if (index >= 0) foods[index] = food;
    return 1;
  }

  @override
  Future<int> deleteFood(int id) async {
    foods.removeWhere((f) => f.id == id);
    return 1;
  }
}

Future<void> goToTab(WidgetTester tester, String label) async {
  await tester.tap(find.descendant(
    of: find.byType(NavigationBar),
    matching: find.text(label),
  ));
  await tester.pumpAndSettle();
}

void main() {
  Future<String?> pick(WidgetTester tester, List<String> names) async {
    await tester.tap(find.text('Pick a food!'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    for (final name in names) {
      if (tester.any(find.text(name))) {
        return name;
      }
    }
    return null;
  }

  testWidgets('real app flow: pick, switch tabs, add, pick again, delete',
      (WidgetTester tester) async {
    final db = FakeFoodDatabase();

    await tester.pumpWidget(
      MaterialApp(home: MainShell(database: db, settings: SettingsController())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pick a food!'), findsOneWidget);

    String? result = await pick(tester, ['Pizza', 'Sushi']);
    expect(result, isNotNull, reason: 'pressing the button should show a food');

    await goToTab(tester, 'Manage');
    expect(find.widgetWithText(FilledButton, 'Add food'), findsOneWidget,
        reason: 'manage tab should show the add food button');

    await tester.tap(find.widgetWithText(FilledButton, 'Add food'));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsNWidgets(2),
        reason: 'add food page should have name and description fields');

    await tester.enterText(find.byType(TextField).at(0), 'Tacos');
    await tester.enterText(find.byType(TextField).at(1), 'Tasty tacos');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    expect(find.text('Tacos'), findsOneWidget,
        reason: 'Tacos should appear in the list after Save');
    expect(find.text('Tasty tacos'), findsOneWidget,
        reason: 'description should appear in the list after Save');

    final tacosTile = find.ancestor(
      of: find.text('Tacos'),
      matching: find.byType(ListTile),
    );
    await tester.tap(find.descendant(
      of: tacosTile,
      matching: find.byIcon(Icons.edit),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Edit Food'), findsOneWidget,
        reason: 'edit page should be shown');
    expect(find.text('Tacos'), findsOneWidget,
        reason: 'name should be prefilled');

    await tester.enterText(find.byType(TextField).at(1), 'Crunchy tacos');
    await tester.tap(find.widgetWithText(FilledButton, 'Save'));
    await tester.pumpAndSettle();
    expect(find.text('Crunchy tacos'), findsOneWidget,
        reason: 'updated description should appear in the list');
    expect(find.text('Tasty tacos'), findsNothing,
        reason: 'old description should be gone');
    expect(
      db.foods.any(
        (f) => f.name == 'Tacos' && f.description == 'Crunchy tacos',
      ),
      isTrue,
      reason: 'database should reflect the update',
    );

    await goToTab(tester, 'Home');
    result = await pick(tester, ['Pizza', 'Sushi', 'Tacos']);
    expect(result, isNotNull,
        reason: 'picking again after add should show a food');

    final beforeDelete = db.foods.length;
    await goToTab(tester, 'Manage');
    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();
    expect(find.text('Deleted Pizza'), findsOneWidget,
        reason: 'delete snackbar should confirm the removal');
    expect(db.foods.length, beforeDelete - 1);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(db.foods.length, beforeDelete,
        reason: 'undo should restore the deleted food');

    await goToTab(tester, 'Home');
    result = await pick(tester, db.foods.map((f) => f.name).toList());
    expect(result, isNotNull,
        reason: 'picking again after delete should show a food');
  });
}
