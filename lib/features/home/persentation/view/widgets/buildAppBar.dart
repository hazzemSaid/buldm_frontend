// features/home/persentation/view/widgets/buildAppBar.dart
import 'package:buldm/core/Dependency_njection/service_locator.dart';
import 'package:buldm/features/home/persentation/bloc/post/post_bloc.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_bloc.dart';
import 'package:buldm/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:buldm/features/notifications/presentation/view/screens/notification_screen.dart';
import 'package:buldm/routes/routes.dart';
import 'package:buldm/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class buildAppBar extends StatelessWidget {
  const buildAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: theme.surface,
      elevation: 0,
      title: Text(
        "Buldm",
        style: AppTextStyles.headlineLarge(context)
            .copyWith(color: theme.primary, fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: Icon(FontAwesomeIcons.heart, color: theme.secondary),
          onPressed: () {
            final userbloc = context.read<UserBloc>();
            final postbloc = context.read<PostBloc>();
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MultiBlocProvider(
                  providers: [
                    BlocProvider<UserBloc>.value(value: userbloc),
                    BlocProvider<PostBloc>.value(value: postbloc),
                    BlocProvider<NotificationBloc>(
                        create: (context) => sl<NotificationBloc>()),
                  ],
                  child: const NotificationScreen(),
                ),
              ),
            );
          },
        ),
        IconButton(
          icon: Icon(FontAwesomeIcons.telegram, color: theme.secondary),
          onPressed: () {
            context.push(paths[AppRoute.chatsList.name]!);
          },
        ),
      ],
    );
  }
}
