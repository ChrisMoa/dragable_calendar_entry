import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../utils/time_utils.dart';

class EventEditDialog extends StatefulWidget {
  final String? title;
  final String? description;
  final DateTime startTime;
  final DateTime endTime;
  final Color? color;
  final Function(String title, String description, DateTime start, DateTime end,
      Color color) onSave;

  const EventEditDialog({
    super.key,
    this.title,
    this.description,
    required this.startTime,
    required this.endTime,
    this.color,
    required this.onSave,
  });

  @override
  State<EventEditDialog> createState() => _EventEditDialogState();
}

class _EventEditDialogState extends State<EventEditDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _startTime;
  late DateTime _endTime;
  late Color _color;
  final int _timeSnapInterval = 15; // Default to 15 minutes

  final List<Color> _availableColors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.teal,
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.description ?? '');
    _startTime = widget.startTime;
    _endTime = widget.endTime;
    _color = widget.color ?? Colors.blue;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title != null && widget.title != ''
          ? 'Edit Event'
          : 'New Event'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            _buildDateTimePickers(
              label: 'Start',
              dateTime: _startTime,
              onChanged: (dateTime) {
                setState(() {
                  _startTime = dateTime;

                  // Ensure end time is after start time
                  if (_endTime.isBefore(_startTime)) {
                    // Keep the duration the same
                    Duration duration =
                        widget.endTime.difference(widget.startTime);
                    _endTime = _startTime.add(duration);
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            _buildDateTimePickers(
              label: 'End',
              dateTime: _endTime,
              onChanged: (dateTime) {
                setState(() {
                  _endTime = dateTime;

                  // Ensure start time is before end time
                  if (_startTime.isAfter(_endTime)) {
                    // Keep the duration the same
                    Duration duration =
                        widget.endTime.difference(widget.startTime);
                    _startTime = _endTime.subtract(duration);
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            _buildColorPicker(),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_titleController.text.trim().isNotEmpty) {
              widget.onSave(
                _titleController.text,
                _descriptionController.text,
                _startTime,
                _endTime,
                _color,
              );
              Navigator.of(context).pop();
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildDateTimePickers({
    required String label,
    required DateTime dateTime,
    required Function(DateTime) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label Time:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        // Date picker
        InkWell(
          onTap: () async {
            final pickedDate = await showDatePicker(
              context: context,
              initialDate: dateTime,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );

            if (pickedDate != null) {
              final newDateTime = DateTime(
                pickedDate.year,
                pickedDate.month,
                pickedDate.day,
                dateTime.hour,
                dateTime.minute,
              );
              onChanged(newDateTime);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 18),
                const SizedBox(width: 8),
                Text(
                  DateFormat('EEE, MMM d, yyyy').format(dateTime),
                ),
                const Spacer(),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        // Time picker
        InkWell(
          onTap: () async {
            final pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.fromDateTime(dateTime),
              builder: (BuildContext context, Widget? child) {
                return MediaQuery(
                  data: MediaQuery.of(context).copyWith(
                    alwaysUse24HourFormat: false,
                  ),
                  child: child!,
                );
              },
            );

            if (pickedTime != null) {
              DateTime newDateTime = DateTime(
                dateTime.year,
                dateTime.month,
                dateTime.day,
                pickedTime.hour,
                pickedTime.minute,
              );

              // Snap the time to the nearest interval (15 minutes)
              newDateTime =
                  TimeUtils.snapToInterval(newDateTime, _timeSnapInterval);
              onChanged(newDateTime);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, size: 18),
                const SizedBox(width: 8),
                Text(
                  DateFormat('h:mm a').format(dateTime),
                ),
                const Spacer(),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildColorPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Event Color',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _availableColors.map((color) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _color = color;
                });
              },
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _color == color ? Colors.black : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
