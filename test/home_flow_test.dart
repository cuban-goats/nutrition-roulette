import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:food_picker/data/database.dart';
import 'package:food_picker/models/food.dart';
import 'package:food_picker/screens/main_shell.dart';

class FakeFoodDatabase extends FoodDatabase {
  final List<Food> foods = [
    const Food(id: 1, name: 'Pizza'),
    const Food(id: 2, name: 'Sushi'),
  ];

  @override
  Future<List<Food>> getFoods() async => List.of(foods);

  @override
  Future<int> addFood(String name) async {
    foods.add(Food(id: foods.length + 1, name: name));
    return foods.length;
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
      MaterialApp(home: MainShell(database: db)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pick a food!'), findsOneWidget);

    String? result = await pick(tester, ['Pizza', 'Sushi']);
    expect(result, isNotNull, reason: 'pressing the button should show a food');

    await goToTab(tester, 'Manage');
    expect(find.byType(TextField), findsOneWidget,
        reason: 'manage tab should show the add field');

    await tester.enterText(find.byType(TextField), 'Tacos');
    await tester.tap(find.widgetWithText(FilledButton, 'Add'));
    await tester.pumpAndSettle();
    expect(find.text('Tacos'), findsOneWidget,
        reason: 'Tacos should appear in the list after Add');

    await goToTab(tester, 'Home');
    result = await pick(tester, ['Pizza', 'Sushi', 'Tacos']);
    expect(result, isNotNull,
        reason: 'picking again after add should show a food');

    final beforeDelete = db.foods.length;
    await goToTab(tester, 'Manage');
    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle();
    expect(db.foods.length, beforeDelete - 1);

    await goToTab(tester, 'Home');
    result = await pick(tester, db.foods.map((f) => f.name).toList());
    expect(result, isNotNull,
        reason: 'picking again after delete should show a food');
  });
}
