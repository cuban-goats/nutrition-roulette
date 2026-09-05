import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nutrition_roulette/data/database.dart';
import 'package:nutrition_roulette/models/food.dart';
import 'package:nutrition_roulette/screens/main_shell.dart';
import 'package:nutrition_roulette/screens/settings_screen.dart';
import 'package:nutrition_roulette/settings/settings_controller.dart';

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
    final settings = SettingsController();
    await tester.pumpWidget(
      MaterialApp(
        home: MainShell(database: _FakeFoodDatabase(), settings: settings),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nutrition Roulette'), findsWidgets);
    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byType(NavigationBar), findsOneWidget);

    await tester.tap(find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text('Settings'),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Color theme'), findsOneWidget);

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

  testWidgets('settings changes theme mode and color', (WidgetTester tester) async {
    final settings = SettingsController();
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: SettingsScreen(settings: settings))),
    );
    await tester.pump();

    expect(settings.themeMode, ThemeMode.dark);

    await tester.tap(find.text('Light'));
    await tester.pump();
    expect(settings.themeMode, ThemeMode.light);

    await tester.tap(find.text('System'));
    await tester.pump();
    expect(settings.themeMode, ThemeMode.system);

    await tester.tap(find.byTooltip('Red'));
    await tester.pump();
    expect(settings.seedColor, const Color(0xFFE53935));
  });
}