import 'package:buldm/features/home/persentation/view/screens/home_screen.dart';
import 'package:buldm/features/profile/presentation/view/screens/profile_screen.dart';
import 'package:buldm/features/setting/presentation/view/screens/setting_screen.dart';
import 'package:buldm/utils/widgets/custom_nav_bar.dart';
import 'package:flutter/material.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final _homeScrollController = ScrollController();
  final _profileScrollController = ScrollController();
  final _settingScrollController = ScrollController();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomeScreen(scrollController: _homeScrollController),
      ProfileScreen(),
      SettingScreen(),
    ];
  }

  void _onTap(int index) {
    if (_currentIndex == index) {
      // نفس الصفحة، نرفعها لفوق
      switch (index) {
        case 0:
          _homeScrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          break;
      }
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: CustomNavBar(
        currentIndex: _currentIndex,
        onTap: _onTap,
      ),
    );
  }
}
