import 'package:bloc_test/bloc_test.dart';
import 'package:draggable_calendar/draggable_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EventBloc', () {
    late EventModel testEvent;

    setUp(() {
      testEvent = EventModel(
        id: '123',
        title: 'Test Event',
        description: 'Test Description',
        start: DateTime(2025, 4, 20, 10, 0),
        end: DateTime(2025, 4, 20, 11, 0),
        color: Colors.blue,
      );
    });

    blocTest<EventBloc, EventState>(
      'emits updated state when EventAdd is added',
      build: () => EventBloc(),
      act: (bloc) => bloc.add(EventAdd(testEvent)),
      expect: () => [
        isA<EventState>().having(
          (state) => state.events,
          'events',
          contains(testEvent),
        ),
      ],
    );

    blocTest<EventBloc, EventState>(
      'emits updated state when EventUpdate is added',
      build: () => EventBloc(initialEvents: [testEvent]),
      act: (bloc) {
        final updatedEvent = testEvent.copyWith(title: 'Updated Title');
        bloc.add(EventUpdate(updatedEvent));
      },
      expect: () => [
        isA<EventState>().having(
          (state) => state.events.first.title,
          'updated event title',
          'Updated Title',
        ),
      ],
    );

    blocTest<EventBloc, EventState>(
      'emits updated state when EventDelete is added',
      build: () => EventBloc(initialEvents: [testEvent]),
      act: (bloc) => bloc.add(EventDelete(testEvent.id)),
      expect: () => [
        isA<EventState>().having(
          (state) => state.events,
          'empty events',
          isEmpty,
        ),
      ],
    );

    blocTest<EventBloc, EventState>(
      'emits updated state when EventChangeView is added',
      build: () => EventBloc(),
      act: (bloc) => bloc.add(const EventChangeView(CalendarViewType.month)),
      expect: () => [
        isA<EventState>().having(
          (state) => state.calendarView,
          'calendar view',
          CalendarViewType.month,
        ),
      ],
    );

    blocTest<EventBloc, EventState>(
      'emits updated state when EventDuplicate is added',
      build: () => EventBloc(initialEvents: [testEvent]),
      act: (bloc) => bloc.add(EventDuplicate(testEvent.id)),
      expect: () => [
        isA<EventState>().having(
          (state) => state.events.length,
          'events count',
          2,
        ),
      ],
      verify: (bloc) {
        // Verify the duplicated event has a different ID but same content
        final events = bloc.state.events;
        expect(events.length, 2);
        expect(events[0].id != events[1].id, true);
        expect(events[1].title, testEvent.title);
        expect(events[1].description, testEvent.description);
      },
    );
  });
}
