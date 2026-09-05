import 'package:flutter/material.dart';

import '../data/database.dart';
import '../widgets/gradient_background.dart';
import 'home_screen.dart';
import 'manage_foods_screen.dart';
import 'more_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key, this.database});

  final FoodDatabase? database;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late final FoodDatabase _database = widget.database ?? FoodDatabase();
  late final PageController _pageController = PageController();
  final GlobalKey<HomeScreenState> _homeKey = GlobalKey();
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onPageChanged);
  }

  void _onPageChanged() {
    if (!mounted) return;
    final page = _pageController.page ?? _index.toDouble();
    final rounded = page.round().clamp(0, 2);
    if (rounded != _index) {
      setState(() => _index = rounded);
      if (rounded == 0) {
        _homeKey.currentState?.reload();
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _select(int i) {
    _pageController.animateToPage(
      i,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(_tabs[_index].title),
        ),
        body: PageView(
          controller: _pageController,
          children: [
            HomeScreen(key: _homeKey, database: _database),
            ManageFoodsScreen(database: _database),
            const MoreScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: _select,
          destinations: [
            for (final tab in _tabs)
              NavigationDestination(icon: Icon(tab.icon), label: tab.label),
          ],
        ),
      ),
    );
  }
}

class _TabData {
  const _TabData({
    required this.title,
    required this.label,
    required this.icon,
  });

  final String title;
  final String label;
  final IconData icon;
}

const _tabs = <_TabData>[
  _TabData(
    title: 'Food Picker',
    label: 'Home',
    icon: Icons.restaurant,
  ),
  _TabData(
    title: 'Manage Foods',
    label: 'Manage',
    icon: Icons.edit,
  ),
  _TabData(
    title: 'More',
    label: 'More',
    icon: Icons.more_horiz,
  ),
];
