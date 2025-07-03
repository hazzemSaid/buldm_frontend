import 'package:flutter/material.dart';

class BuildCategorySelector extends StatefulWidget {
  final TextEditingController _categoryController;
  final List<String> _categories;
  final List<IconData> _categoryIcons;

  BuildCategorySelector({
    super.key,
    required TextEditingController categoryController,
    required List<String> categories,
    required List<IconData> categoryIcons,
  })  : _categoryController = categoryController,
        _categories = categories,
        _categoryIcons = categoryIcons;

  @override
  State<BuildCategorySelector> createState() => _BuildCategorySelectorState();
}

class _BuildCategorySelectorState extends State<BuildCategorySelector> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Category',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget._categories.asMap().entries.map((entry) {
            final index = entry.key;
            final category = entry.value;
            final isSelected = widget._categoryController.text == category;

            return GestureDetector(
              onTap: () {
                setState(() {
                  widget._categoryController.text = category;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.outline,
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget._categoryIcons[index],
                      size: 16,
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category,
                      style: TextStyle(
                        color: isSelected
                            ? Theme.of(context).colorScheme.onPrimary
                            : Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
