import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';

class LanguageSwitcher extends StatelessWidget {
  final Function(Locale) onLocaleChanged;
  const LanguageSwitcher({required this.onLocaleChanged, super.key});

  @override
  Widget build(BuildContext context) {
    return DropdownButton<Locale>(
      value: Localizations.localeOf(context),
      onChanged: (Locale? locale) {
        if (locale != null) {
          onLocaleChanged(locale);
        }
      },
      items:
          FlutterLocalization.instance.supportedLocales.map((locale) {
            return DropdownMenuItem<Locale>(
              value: locale,
              child: Text(locale.languageCode.toUpperCase()),
            );
          }).toList(),
    );
  }
}
