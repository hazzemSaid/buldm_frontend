// features/home/persentation/view/widgets/buildAppBar.dart
import 'package:buldm/features/chat/presentation/view/screens/Listofchats.dart';
import 'package:buldm/features/home/persentation/bloc/user/user_bloc.dart';
import 'package:buldm/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:buldm/routes/routes.dart';

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
          onPressed: () {},
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
