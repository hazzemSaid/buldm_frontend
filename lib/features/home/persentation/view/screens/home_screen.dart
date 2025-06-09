import 'package:buldm/features/auth/presentaion/view/viewmodel/auth/auth_cubit.dart';
import 'package:buldm/features/auth/presentaion/view/viewmodel/auth/auth_state.dart';
import 'package:buldm/l10n/app_localizations.dart';
import 'package:buldm/provider/localization/localization_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final user = BlocProvider.of<AuthCubit>(context).getCurrentUser();

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

          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              print(state);
              return Text(
                state is Authenticated
                    ? "welcome ${(state.usermodel.name)}"
                    : localizations.welcome,
                style: Theme.of(context).textTheme.headlineLarge,
              );
            },
          ),

          const Spacer(),
        ],
      ),
    );
  }
}
