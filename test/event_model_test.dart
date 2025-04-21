import 'package:draggable_calendar/draggable_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EventModel', () {
    test('creates instance with required parameters', () {
      final event = EventModel(
        id: '123',
        title: 'Test Event',
        description: 'Test Description',
        start: DateTime(2025, 4, 20, 10, 0),
        end: DateTime(2025, 4, 20, 11, 0),
      );

      expect(event.id, '123');
      expect(event.title, 'Test Event');
      expect(event.description, 'Test Description');
      expect(event.start, DateTime(2025, 4, 20, 10, 0));
      expect(event.end, DateTime(2025, 4, 20, 11, 0));
      expect(event.color, Colors.blue); // Default color
    });

    test('creates instance with all parameters', () {
      final event = EventModel(
        id: '123',
        title: 'Test Event',
        description: 'Test Description',
        start: DateTime(2025, 4, 20, 10, 0),
        end: DateTime(2025, 4, 20, 11, 0),
        color: Colors.red,
      );

      expect(event.color, Colors.red);
    });

    test('copyWith returns new instance with updated values', () {
      final original = EventModel(
        id: '123',
        title: 'Test Event',
        description: 'Test Description',
        start: DateTime(2025, 4, 20, 10, 0),
        end: DateTime(2025, 4, 20, 11, 0),
      );

      final updated = original.copyWith(
        title: 'Updated Title',
        color: Colors.green,
      );

      // Check updated values
      expect(updated.title, 'Updated Title');
      expect(updated.color, Colors.green);

      // Check values that should remain the same
      expect(updated.id, original.id);
      expect(updated.description, original.description);
      expect(updated.start, original.start);
      expect(updated.end, original.end);

      // Ensure original is not modified
      expect(original.title, 'Test Event');
      expect(original.color, Colors.blue);
    });

    test('equals and hashCode work correctly', () {
      final event1 = EventModel(
        id: '123',
        title: 'Test Event',
        description: 'Test Description',
        start: DateTime(2025, 4, 20, 10, 0),
        end: DateTime(2025, 4, 20, 11, 0),
      );

      final event2 = EventModel(
        id: '123',
        title: 'Test Event',
        description: 'Test Description',
        start: DateTime(2025, 4, 20, 10, 0),
        end: DateTime(2025, 4, 20, 11, 0),
      );

      final event3 = EventModel(
        id: '456', // Different ID
        title: 'Test Event',
        description: 'Test Description',
        start: DateTime(2025, 4, 20, 10, 0),
        end: DateTime(2025, 4, 20, 11, 0),
      );

      expect(event1, event2);
      expect(event1.hashCode, event2.hashCode);
      expect(event1 == event3, false);
    });
  });
}
