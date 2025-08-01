import 'package:buldm/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CustomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final localization = AppLocalizations.of(context)!;
    return BottomNavigationBar(
      enableFeedback: true,
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        BottomNavigationBarItem(
            icon: Icon(Icons.home), label: localization.home),
        BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.mapLocationDot),
            label: localization.map),
        BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.add), label: localization.add),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: localization.search,
        ),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_sharp),
            label: localization.profile),
      ],
    );
  }
}
