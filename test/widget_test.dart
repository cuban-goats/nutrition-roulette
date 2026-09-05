import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nutrition_roulette/data/database.dart';
import 'package:nutrition_roulette/models/food.dart';
import 'package:nutrition_roulette/screens/main_shell.dart';

class _FakeFoodDatabase extends FoodDatabase {
  final List<Food> foods = const [
    Food(id: 1, name: 'Pizza'),
    Food(id: 2, name: 'Sushi'),
  ];

  @override
  Future<List<Food>> getFoods() async => List.of(foods);
}

void main() {
  testWidgets('Food picker app builds with bottom navigation',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(home: MainShell(database: _FakeFoodDatabase())),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nutrition Roulette'), findsWidgets);
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text('More'),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Coming soon.'), findsOneWidget);

    await tester.fling(
      find.byType(PageView),
      const Offset(500, 0),
      1000,
    );
    await tester.pumpAndSettle();
    expect(find.byType(PageView), findsOneWidget);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      1,
    );
  });
}
