import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../../models/event_model.dart';
import 'event_event.dart';
import 'event_state.dart';

class EventBloc extends Bloc<EventBlocEvent, EventState> {
  final _uuid = const Uuid();

  EventBloc() : super(EventState(events: _generateInitialEvents())) {
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

  // Generate a set of initial events based on the current date
  static List<EventModel> _generateInitialEvents() {
    final List<EventModel> events = [];
    final now = DateTime.now();
    final uuid = Uuid();

    // Today's events
    events.add(
      EventModel(
        id: uuid.v4(),
        title: 'Morning Meeting',
        description: 'Daily team standup',
        start: DateTime(now.year, now.month, now.day, 9, 0),
        end: DateTime(now.year, now.month, now.day, 10, 0),
        color: Colors.blue,
      ),
    );

    events.add(
      EventModel(
        id: uuid.v4(),
        title: 'Lunch with Client',
        description: 'Discuss new project requirements',
        start: DateTime(now.year, now.month, now.day, 12, 0),
        end: DateTime(now.year, now.month, now.day, 13, 30),
        color: Colors.green,
      ),
    );

    events.add(
      EventModel(
        id: uuid.v4(),
        title: 'Project Review',
        description: 'End of sprint review with stakeholders',
        start: DateTime(now.year, now.month, now.day, 15, 0),
        end: DateTime(now.year, now.month, now.day, 16, 0),
        color: Colors.orange,
      ),
    );

    // Tomorrow's events
    final tomorrow = now.add(const Duration(days: 1));
    events.add(
      EventModel(
        id: uuid.v4(),
        title: 'Design Workshop',
        description: 'UI/UX brainstorming session',
        start: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 10, 0),
        end: DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 12, 0),
        color: Colors.purple,
      ),
    );

    // Events for yesterday
    final yesterday = now.subtract(const Duration(days: 1));
    events.add(
      EventModel(
        id: uuid.v4(),
        title: 'Code Review',
        description: 'PR review for new feature',
        start: DateTime(yesterday.year, yesterday.month, yesterday.day, 14, 0),
        end: DateTime(yesterday.year, yesterday.month, yesterday.day, 15, 30),
        color: Colors.red,
      ),
    );

    // Events for next week
    final nextWeek = now.add(const Duration(days: 7));
    events.add(
      EventModel(
        id: uuid.v4(),
        title: 'Quarterly Planning',
        description: 'Planning session for next quarter',
        start: DateTime(nextWeek.year, nextWeek.month, nextWeek.day, 9, 0),
        end: DateTime(nextWeek.year, nextWeek.month, nextWeek.day, 16, 0),
        color: Colors.teal,
      ),
    );

    // All day event
    final dayAfterTomorrow = now.add(const Duration(days: 2));
    events.add(
      EventModel(
        id: uuid.v4(),
        title: 'Company Holiday',
        description: 'Annual company holiday',
        start: DateTime(dayAfterTomorrow.year, dayAfterTomorrow.month,
            dayAfterTomorrow.day, 0, 0),
        end: DateTime(dayAfterTomorrow.year, dayAfterTomorrow.month,
            dayAfterTomorrow.day, 23, 59),
        color: Colors.blueGrey,
      ),
    );

    // Multi-day event
    final startMultiDay = now.add(const Duration(days: 3));
    final endMultiDay = now.add(const Duration(days: 5));
    events.add(
      EventModel(
        id: uuid.v4(),
        title: 'Conference',
        description: 'Annual industry conference',
        start: DateTime(
            startMultiDay.year, startMultiDay.month, startMultiDay.day, 9, 0),
        end: DateTime(
            endMultiDay.year, endMultiDay.month, endMultiDay.day, 17, 0),
        color: Colors.indigo,
      ),
    );

    return events;
  }
}
