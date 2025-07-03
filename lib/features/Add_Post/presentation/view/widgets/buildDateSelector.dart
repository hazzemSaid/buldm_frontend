import 'package:flutter/material.dart';

class BuildDateSelector extends StatefulWidget {
  final DateTime? initialDate;
  final Function(DateTime)? onDateSelected;

  const BuildDateSelector({super.key, this.initialDate, this.onDateSelected});

  @override
  State<BuildDateSelector> createState() => _BuildDateSelectorState();
}

class _BuildDateSelectorState extends State<BuildDateSelector> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) {
          setState(() => _selectedDate = picked);
          widget.onDateSelected?.call(picked);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _selectedDate != null ? Colors.blue.shade50 : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selectedDate != null ? Colors.blue : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: _selectedDate != null ? Colors.blue : Colors.grey[600],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _selectedDate != null ? 'Date Selected' : 'Select Date',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: _selectedDate != null
                          ? Colors.blue
                          : Colors.grey[700],
                    ),
                  ),
                  if (_selectedDate != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      _selectedDate!.toLocal().toString().split(' ')[0],
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[600],
            ),
          ],
        ),
      ),
    );
  }
}
