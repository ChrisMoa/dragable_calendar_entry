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

  // Helper method to generate sample events
  static List<EventModel> generateSampleEvents() {
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

    // Add more events as needed

    return events;
  }
}
