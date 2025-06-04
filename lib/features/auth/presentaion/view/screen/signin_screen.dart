import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SigninScreen extends StatelessWidget {
  const SigninScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign in')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Sign in Screen'),
            ElevatedButton(
              onPressed: () {
                // Handle sign up logic here
                GoRouter.of(
                  context,
                ).push('/signup'); // Navigate to the sign up screen
              },
              child: const Text('Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}
