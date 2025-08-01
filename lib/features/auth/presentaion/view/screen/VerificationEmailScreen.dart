import 'package:buldm/features/auth/presentaion/view/bloc/auth_cubit.dart';
import 'package:buldm/features/auth/presentaion/view/bloc/auth_state.dart';
import 'package:buldm/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class VerificationEmailScreen extends StatefulWidget {
  final String email;
  const VerificationEmailScreen({super.key, required this.email});

  @override
  State<VerificationEmailScreen> createState() =>
      _VerificationEmailScreenState();
}

class _VerificationEmailScreenState extends State<VerificationEmailScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  String get verificationCode =>
      _controllers.map((controller) => controller.text).join();

  void _onCodeChanged(String value, int index) {
    if (value.isNotEmpty) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isSmallScreen = width < 400;
    final localization = AppLocalizations.of(context)!;
    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(localization.emailVerifiedSuccessfully),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is resendVerificationCode) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.blue,
              ),
            );
          }
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: false,
              centerTitle: true,
              title: Text(localization.emailVerification),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 40),
                      Icon(
                        Icons.email_outlined,
                        size: isSmallScreen ? 48 : 64,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        localization.verifyYourCode,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        localization.checkYourEmail,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.email,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(
                          6,
                          (index) => SizedBox(
                            width: isSmallScreen ? 40 : 50,
                            height: isSmallScreen ? 50 : 60,
                            child: TextField(
                              controller: _controllers[index],
                              focusNode: _focusNodes[index],
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              maxLength: 1,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                counterText: '',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).dividerColor,
                                    width: 2,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(
                                    color: Theme.of(context).primaryColor,
                                    width: 2,
                                  ),
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                filled: true,
                                fillColor: Theme.of(context).canvasColor,
                              ),
                              style: TextStyle(
                                fontSize: isSmallScreen ? 18 : 24,
                                fontWeight: FontWeight.bold,
                              ),
                              onChanged: (value) =>
                                  _onCodeChanged(value, index),
                              onTap: () {
                                _controllers[index].clear();
                              },
                              onSubmitted: (value) {
                                if (index == 5 &&
                                    verificationCode.length == 6) {
                                  context.read<AuthCubit>().verifyEmail(
                                        code: verificationCode,
                                        email: widget.email,
                                      );
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: BlocBuilder<AuthCubit, AuthState>(
                          builder: (context, state) {
                            final isLoading = state is Loading;
                            final isCodeComplete = verificationCode.length == 6;

                            return ElevatedButton(
                              onPressed: isLoading || !isCodeComplete
                                  ? null
                                  : () {
                                      context.read<AuthCubit>().verifyEmail(
                                            code: verificationCode,
                                            email: widget.email,
                                          );
                                    },
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: isLoading
                                  ? SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    )
                                  : Text(
                                      localization.verify,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            localization.didNotReceiveCode,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          TextButton(
                            onPressed: () {
                              context
                                  .read<AuthCubit>()
                                  .sendVerificationEmailAgain(
                                    email: widget.email,
                                  );
                            },
                            child: Text(localization.resend),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
