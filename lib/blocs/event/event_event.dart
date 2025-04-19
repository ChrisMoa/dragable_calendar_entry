import 'package:dragable_calendar_entry/models/event_model.dart';
import 'package:equatable/equatable.dart';

enum CalendarViewType { day, week, month, schedule }

abstract class EventBlocEvent extends Equatable {
  const EventBlocEvent();

  @override
  List<Object> get props => [];
}

class EventAdd extends EventBlocEvent {
  final EventModel event;

  const EventAdd(this.event);

  @override
  List<Object> get props => [event];
}

class EventUpdate extends EventBlocEvent {
  final EventModel event;

  const EventUpdate(this.event);

  @override
  List<Object> get props => [event];
}

class EventDelete extends EventBlocEvent {
  final String eventId;

  const EventDelete(this.eventId);

  @override
  List<Object> get props => [eventId];
}

class EventDuplicate extends EventBlocEvent {
  final String eventId;
  final DateTime? newStart;
  final DateTime? newEnd;

  const EventDuplicate(this.eventId, {this.newStart, this.newEnd});

  @override
  List<Object> get props =>
      [eventId, if (newStart != null) newStart!, if (newEnd != null) newEnd!];
}

class EventChangeView extends EventBlocEvent {
  final CalendarViewType view;

  const EventChangeView(this.view);

  @override
  List<Object> get props => [view];
}
