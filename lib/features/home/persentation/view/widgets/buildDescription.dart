import 'package:flutter/material.dart';

class BuildDescription extends StatelessWidget {
  final String description;
  const BuildDescription({super.key, required this.description});
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        description,
        style: textTheme.bodyMedium,
      ),
    );
  }
}
