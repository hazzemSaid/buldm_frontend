import 'package:buldm/l10n/app_localizations.dart';
import 'package:buldm/provider/localization/localization_cubit.dart';
import 'package:buldm/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lottie/lottie.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  @override
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  void _handleGoogleSignIn(BuildContext context) async {
    try {
      final account = await _googleSignIn.signIn();
      if (account != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signed in as ${account.displayName}')),
        );
        Navigator.pop(context); // Close the bottom sheet
      }
    } catch (error) {
      print('Google Sign-In error: $error');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sign-in failed')));
    }
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Sign in with Google', style: TextStyle(fontSize: 18)),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () => _handleGoogleSignIn(context),
                icon: Icon(Icons.login),
                label: Text('Continue with Google'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showBottomSheet(context);
    });
    // You can add any additional initialization logic here if needed
  }

  @override
  // You can add any additional initialization logic here if needed
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Auth',
          style: AppTextStyles.headlineMedium(
            color: AppTheme.primaryColor,
            text: 'Authentication',
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              //for localization
              BlocProvider.of<LocalizationCubit>(context).switchLanguage();
            },
            icon: Icon(Icons.language, color: AppTheme.primaryColor),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Flexible(
              child: Container(
                child: Lottie.asset("assets/animations/searchanimation.json"),
              ),
            ),
            Wrap(
              children: [
                ElevatedButton(
                  onPressed: () => _handleGoogleSignIn(context),
                  child: Text(
                    "  ${localizations.signIn} ", // should match your ARB key

                    style: AppTextStyles.button(
                      color: Colors.white,
                      text: localizations.signIn,
                    ),
                  ),
                ),
                SizedBox(height: 20, width: 20),
                ElevatedButton(
                  onPressed: () => _handleGoogleSignIn(context),
                  child: Text(
                    "  ${localizations.signUp} ", // should match your ARB key
                    style: AppTextStyles.button(
                      color: Colors.white,
                      text: localizations.signUp,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
