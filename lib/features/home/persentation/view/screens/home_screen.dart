import 'package:buldm/l10n/app_localizations.dart';
import 'package:buldm/provider/localization/localization_cubit.dart';
import 'package:buldm/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Column(
        children: [
          const Spacer(),

          IconButton(
            onPressed: () {
              BlocProvider.of<LocalizationCubit>(
                context,
                listen: false,
              ).switchLanguage();
            },
            icon: const Icon(Icons.language),
          ),

          const SizedBox(height: 16),

          Center(
            child: Text(
              localizations.hello, // should match your ARB key
              style: AppTextStyles.headlineLarge(text: localizations.hello),
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }
}
