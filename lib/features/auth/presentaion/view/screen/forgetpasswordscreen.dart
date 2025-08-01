import 'package:buldm/features/auth/presentaion/view/bloc/auth_cubit.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_state.dart';
import 'package:buldm/features/auth/presentaion/view/screen/verfiycodescreen.dart';
import 'package:buldm/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class Forgetpasswordscreen extends StatelessWidget {
  const Forgetpasswordscreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    var _formKey = GlobalKey<FormState>();
    var emailController = TextEditingController();
    final localization = AppLocalizations.of(context)!;
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is Loading) {
          // Show loading indicator
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(
                child:
                    CircularProgressIndicator()), // Replace with your loading widget
          );
        }
        Navigator.of(context).pop(); // Close the loading dialog
        if (state is ForgotPasswordError) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
        if (state is ForgotPasswordSuccess) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                localization.resetLinkSent,
              ),
            ),
          );
        }
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VerifyCodeScreen(
                email: emailController.text.trim(),
              ),
            ));
      },
      child: Scaffold(
        body: SafeArea(
            child: CustomScrollView(
          slivers: [
            SliverPadding(
                padding: const EdgeInsets.all(24.0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 32.0),
                    Text(
                      localization.forgetPasswordTitle,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      localization.forgetPasswordSubtitle,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ]),
                )),
            SliverFillRemaining(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 24.0),
                  Center(
                    child: Form(
                      key: _formKey,
                      child: SizedBox(
                        width:
                            350, // or MediaQuery.of(context).size.width * 0.8
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: localization.email,
                                prefixIcon: const Icon(Icons.email_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return localization.emailRequired;
                                }
                                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(value)) {
                                  return localization.invalidEmail;
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: Center(
                      child: SizedBox(
                        width: 350, // Match the width of the form
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState?.validate() ?? false) {
                              // Handle password reset logic here
                              context.read<AuthCubit>().forgotPassword(
                                    email: emailController.text.trim(),
                                  );
                            }
                          },
                          child:  Text(localization.resetLinkSent),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        )),
      ),
    );
  }
}
