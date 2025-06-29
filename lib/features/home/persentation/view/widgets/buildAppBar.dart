import 'package:buldm/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class buildAppBar extends StatelessWidget {
  const buildAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: Theme.of(context).colorScheme.background,
      elevation: 0,
      title: Text(
        "Buldm",
        style: AppTextStyles.headlineLarge(context).copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: Icon(FontAwesomeIcons.heart,
              color: Theme.of(context).colorScheme.secondary),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(FontAwesomeIcons.telegram,
              color: Theme.of(context).colorScheme.secondary),
          onPressed: () {},
        ),
      ],
    );
  }
}
