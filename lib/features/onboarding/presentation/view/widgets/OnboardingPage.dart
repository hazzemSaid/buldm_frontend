import 'package:buldm/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  final int index;

  const OnboardingPage({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final titles = [
      localizations.onboarding_1_title,
      localizations.onboarding_2_title,
      localizations.onboarding_3_title,
    ];
    final subtitles = [
      localizations.onboarding_1_subtitle,
      localizations.onboarding_2_subtitle,
      localizations.onboarding_3_subtitle,
    ];

    return Stack(
      children: [
        // Background image
        Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/lightbuldm.png'),
              fit: BoxFit.fitWidth,
            ),
          ),
        ),

        // Text content
        Positioned(
          bottom: 100,
          left: 24,
          right: 24,
          child: Wrap(
            alignment: WrapAlignment.center,
            runSpacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                titles[index],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                subtitles[index],
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
