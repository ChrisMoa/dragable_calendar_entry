import 'package:draggable_calendar/draggable_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DraggableCalendar', () {
    testWidgets('renders correctly with empty events',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DraggableCalendar(
              calendarViewType: CalendarViewType.day,
              events: [],
            ),
          ),
        ),
      );

      expect(find.byType(DraggableCalendar), findsOneWidget);
    });

    // More tests would go here
  });

  group('TimeUtils', () {
    test('snapToInterval rounds correctly', () {
      final time = DateTime(2025, 4, 20, 10, 22);

      expect(TimeUtils.snapToInterval(time, 15).minute, equals(15));

      expect(TimeUtils.snapToInterval(time, 30).minute, equals(30));
    });
  });
}
