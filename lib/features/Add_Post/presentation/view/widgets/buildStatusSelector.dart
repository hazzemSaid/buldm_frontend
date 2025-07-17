import 'package:flutter/material.dart';

class BuildStatusSelector extends StatelessWidget {
  final String status;
  void Function()? onStatusChanged;
  BuildStatusSelector(
      {super.key, required this.status, required this.onStatusChanged});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onStatusChanged,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: status == 'LOST' ? Colors.red.shade50 : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: status == 'LOST' ? Colors.red : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.search_off,
                    color: status == 'LOST' ? Colors.red : Colors.grey[600],
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'LOST',
                    style: TextStyle(
                      color: status == 'LOST' ? Colors.red : Colors.grey[700],
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
            onTap: onStatusChanged,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color:
                    status == 'FOUND' ? Colors.green.shade50 : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: status == 'FOUND' ? Colors.green : Colors.grey[300]!,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: status == 'FOUND' ? Colors.green : Colors.grey[600],
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'FOUND',
                    style: TextStyle(
                      color:
                          status == 'FOUND' ? Colors.green : Colors.grey[700],
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
