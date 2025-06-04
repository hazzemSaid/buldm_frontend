import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SingupScreen extends StatelessWidget {
  const SingupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Sign Up Screen'),
            ElevatedButton(
              onPressed: () {
                // Navigate to the sign in screen
                GoRouter.of(context).push('/home');
              },
              child: const Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }
}
