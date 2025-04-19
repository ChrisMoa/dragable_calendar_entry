import 'package:dragable_calendar_entry/models/event_model.dart';
import 'package:equatable/equatable.dart';

import 'event_event.dart';

class EventState extends Equatable {
  final List<EventModel> events;
  final CalendarViewType calendarView;

  const EventState({
    this.events = const [],
    this.calendarView = CalendarViewType.week,
  });

  EventState copyWith({
    List<EventModel>? events,
    CalendarViewType? calendarView,
  }) {
    return EventState(
      events: events ?? this.events,
      calendarView: calendarView ?? this.calendarView,
    );
  }

  @override
  List<Object> get props => [events, calendarView];
}
