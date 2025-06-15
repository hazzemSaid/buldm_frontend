import 'package:flutter/material.dart';

class buildDescription extends StatelessWidget {
  const buildDescription({super.key});
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        "Found a wallet near the park. If it’s yours, please contact me.",
        style: textTheme.bodyMedium,
      ),
    );
  }
}
