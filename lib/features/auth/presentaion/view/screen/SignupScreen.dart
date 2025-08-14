import 'package:buldm/features/auth/presentaion/view/bloc/auth_cubit.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_state.dart';
import 'package:buldm/l10n/app_localizations.dart';
import 'package:buldm/routes/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  @override
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  bool _rememberMe = false;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final localization = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 32.0),
              Text(
                localization.createAccount,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              Text(
                localization.signUpToYourAccount,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 32.0),

              // Google Sign-In Button
              BlocListener<AuthCubit, AuthState>(
                listener: (context, state) {
                  // for loading state
                  if (state is GoogleLoading) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: Row(
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(width: 16.0),
                              Text(localization.signingInWithGoogle),
                            ],
                          ),
                        );
                      },
                    );
                  }
                  // for error state
                  if (state is AuthError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<AuthCubit>().authWithGoogle();
                  },
                  icon: Image.asset(
                    'assets/images/google.png',
                    height: 24.0,
                    width: 24.0,
                    fit: BoxFit.cover,
                  ),
                  label: Text(localization.continueWithGoogle),
                  style: ElevatedButton.styleFrom(
                    //using theme.primaryColor for Google button
                    backgroundColor: theme.primaryColor,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
              const SizedBox(height: 24.0),

              // Divider with text
              Row(
                children: [
                  const Expanded(child: Divider(thickness: 1.2)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      localization.orUseYourEmail,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: Colors.grey[600]),
                    ),
                  ),
                  const Expanded(child: Divider(thickness: 1.2)),
                ],
              ),
              const SizedBox(height: 24.0),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: localization.name,
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return localization.nameRequired;
                        }
                        if (value.length < 2) {
                          return localization.nameTooShort;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    TextFormField(
                      controller: _emailController,
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
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: localization.password,
                        prefixIcon: const Icon(Icons.lock_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return localization.passwordRequired;
                        }
                        if (value.length < 6) {
                          return localization.passwordTooShort;
                        }
                        return null;
                      },
                    ),
                    Text(
                      localization.passwordHint,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 16.0),
                    // Forgot Password

                    // Remember Me
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) {
                            setState(() => _rememberMe = value ?? false);
                          },
                        ),
                        Text(localization.rememberMe,
                            style: theme.textTheme.bodyMedium),
                      ],
                    ),

                    const SizedBox(height: 16.0),

                    // Sign In Button
                    BlocConsumer<AuthCubit, AuthState>(
                      listener: (context, state) {
                        // for loading state
                        if (state is Loading) {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) {
                              return AlertDialog(
                                content: Row(
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(width: 16.0),
                                    Text(localization.signingUp),
                                  ],
                                ),
                              );
                            },
                          );
                        }
                        if (state is AuthError) {
                          final nav =
                              Navigator.of(context, rootNavigator: true);
                          if (nav.canPop()) nav.pop();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.message),
                              backgroundColor: Colors.red,
                              duration: const Duration(microseconds: 6000),
                            ),
                          );
                        }
                        if (state is SignUp) {
                          final nav =
                              Navigator.of(context, rootNavigator: true);
                          if (nav.canPop()) nav.pop();

                          // screen for verification email
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(localization.verificationEmailSent),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          context.push(
                            paths[AppRoute.verifyEmail.name]!,
                            extra: _emailController.text,
                          );
                        }
                      },
                      builder: (context, state) {
                        return ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              context.read<AuthCubit>().signUp(
                                    _emailController.text,
                                    _passwordController.text,
                                    _nameController.text,
                                  );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            backgroundColor: theme.primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(localization.signUp),
                        );
                      },
                    ),

                    const SizedBox(height: 24.0),

                    // Sign Up Prompt
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(localization.alreadyHaveAnAccount),
                        TextButton(
                          onPressed: () {
                            context.go(paths[AppRoute.signin.name]!);
                          },
                          child: Text(localization.signIn),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
