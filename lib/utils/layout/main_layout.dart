import 'package:buldm/core/Dependency_njection/service_locator.dart';
import 'package:buldm/features/Add_Post/presentation/bloc/imagespicker_cubit/imagespicker_cubit.dart';
import 'package:buldm/features/Add_Post/presentation/view/screens/add_post_screen.dart';
import 'package:buldm/features/home/persentation/bloc/post/post_bloc.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_bloc.dart';
import 'package:buldm/features/home/persentation/view/screens/home_screen.dart';
import 'package:buldm/features/map_location/presentation/view/screens/map_location_screen.dart';
import 'package:buldm/features/profile/presentation/view/screens/profile_screen.dart';
import 'package:buldm/features/search/presentation/view/screens/search_screen.dart';
import 'package:buldm/utils/widgets/custom_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    return MultiBlocProvider(
      providers: [
        BlocProvider<PostBloc>(create: (context) => sl<PostBloc>()),
        BlocProvider<UserBloc>(
          create: (context) => sl<UserBloc>(),
        ),
      ],
      child: Builder(
        builder: (context) {
          final screens = [
            HomeScreen(scrollController: _homeScrollController),
            MapLocationScreen(),
            BlocProvider(
              create: (context) => ImagespickerCubit(),
              child: PostUploadScreen(),
            ),
            SearchScreen(),
            ProfileScreen(),
          ];

          return Scaffold(
            body: IndexedStack(index: _currentIndex, children: screens),
            bottomNavigationBar: CustomNavBar(
              currentIndex: _currentIndex,
              onTap: _onTap,
            ),
          );
        },
      ),
    );
  }
}
