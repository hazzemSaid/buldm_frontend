import 'package:flutter/material.dart';

class BuildStatusSelector extends StatefulWidget {
  BuildStatusSelector({super.key});

  @override
  State<BuildStatusSelector> createState() => _BuildStatusSelectorState();
}

class _BuildStatusSelectorState extends State<BuildStatusSelector> {
  String _status = 'lost';
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _status = 'lost'),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    _status == 'lost' ? Colors.red.shade50 : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _status == 'lost' ? Colors.red : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.search_off,
                    color: _status == 'lost' ? Colors.red : Colors.grey[600],
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lost',
                    style: TextStyle(
                      color: _status == 'lost' ? Colors.red : Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _status = 'found'),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _status == 'found'
                    ? Colors.green.shade50
                    : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _status == 'found' ? Colors.green : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: _status == 'found' ? Colors.green : Colors.grey[600],
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Found',
                    style: TextStyle(
                      color:
                          _status == 'found' ? Colors.green : Colors.grey[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
