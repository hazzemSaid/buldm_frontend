import 'package:buldm/features/chat/presentation/view/screens/Listofchats.dart';
import 'package:buldm/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class buildAppBar extends StatelessWidget {
  const buildAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context).colorScheme;
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: theme.background,
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
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => ListOfChats()));
          },
        ),
      ],
    );
  }
}
