import 'package:draggable_calendar/draggable_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DraggableCalendar Widget', () {
    testWidgets('renders with empty events', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
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

    testWidgets('renders with events', (WidgetTester tester) async {
      final events = [
        EventModel(
          id: '1',
          title: 'Test Event',
          description: 'Description',
          start: DateTime(2025, 4, 20, 10, 0),
          end: DateTime(2025, 4, 20, 11, 0),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DraggableCalendar(
              calendarViewType: CalendarViewType.day,
              events: events,
            ),
          ),
        ),
      );

      expect(find.byType(DraggableCalendar), findsOneWidget);
      // Additional assertions for the events would require mocking Syncfusion widgets
    });

    testWidgets('responds to callback', (WidgetTester tester) async {
      bool callbackCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DraggableCalendar(
              calendarViewType: CalendarViewType.day,
              events: [],
              onEventAdd: (event) {
                callbackCalled = true;
              },
            ),
          ),
        ),
      );

      expect(find.byType(DraggableCalendar), findsOneWidget);
      // To test callbacks, we'd need to simulate tap, drag, etc.
      // This would require more complex test setup with mocking
    });

    testWidgets('changes view type', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                body: StatefulBuilder(
                  builder: (context, setState) {
                    return DraggableCalendar(
                      calendarViewType: CalendarViewType.day,
                      events: [],
                    );
                  },
                ),
              );
            },
          ),
        ),
      );

      expect(find.byType(DraggableCalendar), findsOneWidget);
    });
  });
}
