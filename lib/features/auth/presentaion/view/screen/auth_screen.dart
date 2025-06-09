import 'package:another_flushbar/flushbar.dart';
import 'package:buldm/features/auth/presentaion/view/viewmodel/auth/auth_cubit.dart';
import 'package:buldm/features/auth/presentaion/view/viewmodel/auth/auth_state.dart';
import 'package:buldm/l10n/app_localizations.dart';
import 'package:buldm/provider/localization/localization_cubit.dart';
import 'package:buldm/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  void _showBottomSheet(
    BuildContext context,
    AppLocalizations localizations,
    bool isSignUp,
  ) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                isSignUp ? localizations.signUp : localizations.signIn,
                style: AppTextStyles.headlineMedium(
                  context,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed:
                    () => {
                      BlocProvider.of<AuthCubit>(context).authwithgoogle(),
                    },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          localizations.google,
                          style: AppTextStyles.button(
                            context,
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                        ),
                      ),
                      Icon(
                        FontAwesomeIcons.google,
                        size: 20,
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  // Handle email sign-in
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          localizations.email,
                          style: AppTextStyles.button(
                            context,
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                        ),
                      ),
                      Icon(
                        FontAwesomeIcons.envelope,
                        size: 20,
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.backgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  // Handle phone sign-in
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          localizations.apple,
                          style: AppTextStyles.button(
                            context,
                            color: Theme.of(context).scaffoldBackgroundColor,
                          ),
                        ),
                      ),
                      Icon(
                        FontAwesomeIcons.apple,
                        size: 20,
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.hello,
          style: AppTextStyles.headlineMedium(
            context,
            color: AppTheme.primaryColor,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              BlocProvider.of<LocalizationCubit>(context).switchLanguage();
            },
            icon: Icon(Icons.language, color: AppTheme.primaryColor),
          ),
        ],
      ),
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            showLoadingDialog(context);
          }
          if (state is AuthFailure) {
            print(state.error);
            Navigator.pop(context);
            Flushbar(
              title: 'فشل',
              message: 'تمت العملية ${state.error}!',
              duration: Duration(seconds: 3),
              backgroundColor: Colors.red,
              icon: Icon(Icons.check_circle, color: Colors.white),
            ).show(context);
          }
          if (state is Authenticated) {
            Navigator.pop(context); // Close the loading dialog
            Flushbar(
              title: 'نجاح',
              message: 'تم تسجيل الدخول بنجاح!',
              duration: Duration(seconds: 3),
              backgroundColor: Colors.green,
              icon: Icon(Icons.check_circle, color: Colors.white),
            ).show(context);
            GoRouter.of(
              context,
            ).go('/navbar'); // Navigate to the main app screen
          }
        },
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Flexible(
                child: Lottie.asset("assets/animations/searchanimation.json"),
              ),
              Wrap(
                children: [
                  ElevatedButton(
                    onPressed:
                        () => _showBottomSheet(context, localizations, false),
                    child: Text(
                      "  ${localizations.signIn}  ",
                      style: AppTextStyles.button(context, color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 20, width: 20),
                  ElevatedButton(
                    onPressed:
                        () => _showBottomSheet(context, localizations, true),
                    child: Text(
                      "  ${localizations.signUp}  ",
                      style: AppTextStyles.button(context, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        );
      },
    );
  }
}
