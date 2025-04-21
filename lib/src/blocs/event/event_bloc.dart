import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../models/event_model.dart';
import 'event_event.dart';
import 'event_state.dart';

class EventBloc extends Bloc<EventBlocEvent, EventState> {
  final _uuid = const Uuid();

  EventBloc({List<EventModel>? initialEvents})
      : super(EventState(events: initialEvents ?? [])) {
    on<EventAdd>(_onAddEvent);
    on<EventUpdate>(_onUpdateEvent);
    on<EventDelete>(_onDeleteEvent);
    on<EventDuplicate>(_onDuplicateEvent);
    on<EventChangeView>(_onChangeView);
  }

  void _onAddEvent(EventAdd event, Emitter<EventState> emit) {
    final newEvent = event.event;
    emit(state.copyWith(
      events: [...state.events, newEvent],
    ));
  }

  void _onUpdateEvent(EventUpdate event, Emitter<EventState> emit) {
    final updatedEvents = state.events.map((e) {
      return e.id == event.event.id ? event.event : e;
    }).toList();

    emit(state.copyWith(events: updatedEvents));
  }

  void _onDeleteEvent(EventDelete event, Emitter<EventState> emit) {
    final filteredEvents =
        state.events.where((element) => element.id != event.eventId).toList();

    emit(state.copyWith(events: filteredEvents));
  }

  void _onDuplicateEvent(EventDuplicate event, Emitter<EventState> emit) {
    final originalEvent =
        state.events.firstWhere((element) => element.id == event.eventId);

    final duplicatedEvent = originalEvent.copyWith(
      id: _uuid.v4(),
      start: event.newStart ?? originalEvent.start,
      end: event.newEnd ?? originalEvent.end,
    );

    emit(state.copyWith(
      events: [...state.events, duplicatedEvent],
    ));
  }

  void _onChangeView(EventChangeView event, Emitter<EventState> emit) {
    emit(state.copyWith(
      calendarView: event.view,
    ));
  }

  static List<EventModel> generateSampleEvents([int samples = 5]) {
    final List<EventModel> events = [];
    final now = DateTime.now();
    final uuid = Uuid();
    final random = Random();

    // Sample event templates
    final eventTemplates = [
      {
        'title': 'Morning Meeting',
        'description': 'Daily team standup',
        'color': Colors.blue,
      },
      {
        'title': 'Lunch with Client',
        'description': 'Discuss new project requirements',
        'color': Colors.green,
      },
      {
        'title': 'Project Review',
        'description': 'End of sprint review',
        'color': Colors.orange,
      },
      {
        'title': 'Team Building',
        'description': 'Office games and activities',
        'color': Colors.purple,
      },
      {
        'title': 'Conference Call',
        'description': 'International partners sync',
        'color': Colors.red,
      },
    ];

    // Generate random events
    for (int i = 0; i < samples; i++) {
      // Pick a random template
      final templateIndex = random.nextInt(eventTemplates.length);
      final template = eventTemplates[templateIndex];

      // Generate random date (-7 to +14 days from now)
      final daysOffset = random.nextInt(21) - 7;
      final eventDate = now.add(Duration(days: daysOffset));

      // Generate random start time (7am to 6pm)
      final startHour = 7 + random.nextInt(11);
      final startMinute =
          [0, 15, 30, 45][random.nextInt(4)]; // Quarter-hour intervals

      // Generate random duration (30min to 2.5 hours)
      final durationMinutes = 30 + random.nextInt(5) * 30; // 30min increments

      final startTime = DateTime(eventDate.year, eventDate.month, eventDate.day,
          startHour.toInt(), startMinute);
      final endTime = startTime.add(Duration(minutes: durationMinutes.toInt()));

      events.add(
        EventModel(
          id: uuid.v4(),
          title: template['title'] as String,
          description: template['description'] as String,
          start: startTime,
          end: endTime,
          color: template['color'] as Color,
        ),
      );
    }

    return events;
  }
}
