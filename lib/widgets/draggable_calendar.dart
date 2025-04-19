import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:uuid/uuid.dart';

import '../blocs/event/event_bloc.dart';
import '../blocs/event/event_event.dart';
import '../models/event_model.dart';
import 'event_edit_dialog.dart';

class DraggableCalendar extends StatefulWidget {
  final CalendarViewType calendarViewType;
  final List<EventModel> events;

  const DraggableCalendar({
    super.key,
    required this.calendarViewType,
    required this.events,
  });

  @override
  State<DraggableCalendar> createState() => _DraggableCalendarState();
}

class _DraggableCalendarState extends State<DraggableCalendar> {
  late CalendarController _calendarController;
  final _uuid = const Uuid();
  DateTime? _lastTapTime;

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
  }

  @override
  void dispose() {
    _calendarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SfCalendar(
      controller: _calendarController,
      view: _getCalendarView(),
      dataSource: _getCalendarDataSource(),
      allowDragAndDrop: true,
      allowAppointmentResize: true,
      monthViewSettings: const MonthViewSettings(
        appointmentDisplayMode: MonthAppointmentDisplayMode.appointment,
      ),
      onTap: _handleCalendarTap,
      onLongPress: _handleCalendarLongPress,
      onAppointmentResizeStart: _handleAppointmentResizeStart,
      onAppointmentResizeUpdate: _handleAppointmentResizeUpdate,
      onAppointmentResizeEnd: _handleAppointmentResizeEnd,
      onDragStart: _handleDragStart,
      onDragUpdate: _handleDragUpdate,
      onDragEnd: _handleDragEnd,
    );
  }

  CalendarView _getCalendarView() {
    switch (widget.calendarViewType) {
      case CalendarViewType.day:
        return CalendarView.day;
      case CalendarViewType.week:
        return CalendarView.week;
      case CalendarViewType.month:
        return CalendarView.month;
      case CalendarViewType.schedule:
        return CalendarView.schedule;
    }
  }

  _AppointmentDataSource _getCalendarDataSource() {
    List<Appointment> appointments = widget.events.map((event) {
      return Appointment(
        id: event.id,
        subject: event.title,
        notes: event.description,
        startTime: event.start,
        endTime: event.end,
        color: event.color,
      );
    }).toList();

    return _AppointmentDataSource(appointments);
  }

  void _handleCalendarTap(CalendarTapDetails details) {
    if (details.targetElement == CalendarElement.appointment &&
        details.appointments != null &&
        details.appointments!.isNotEmpty) {
      final Appointment appointment = details.appointments![0];

      // Detect double tap by measuring time between taps
      final now = DateTime.now();
      if (_lastTapTime != null &&
          now.difference(_lastTapTime!).inMilliseconds < 500) {
        // This is a double tap
        _showDuplicateDialog(appointment);
        _lastTapTime = null;
      } else {
        _lastTapTime = now;
      }
    }
  }

  void _handleCalendarLongPress(CalendarLongPressDetails details) {
    if (details.targetElement == CalendarElement.appointment) {
      // Long press behavior is handled by the built-in drag & drop
    } else if (details.targetElement == CalendarElement.calendarCell) {
      // Create a new appointment on long press on an empty cell
      final DateTime date = details.date!;

      // Creating a 1-hour appointment at the tapped time
      final DateTime startTime = date;
      final DateTime endTime = startTime.add(const Duration(hours: 1));

      _showAddEventDialog(startTime, endTime);
    }
  }

  void _handleAppointmentResizeStart(AppointmentResizeStartDetails details) {
    // Optional: Add any special behavior when resize starts
  }

  void _handleAppointmentResizeUpdate(AppointmentResizeUpdateDetails details) {
    // Optional: Add any special behavior during resize
  }

  void _handleAppointmentResizeEnd(AppointmentResizeEndDetails details) {
    final Appointment appointment = details.appointment as Appointment;

    try {
      final EventModel originalEvent = widget.events.firstWhere(
        (event) => event.id == appointment.id.toString(),
      );

      final EventModel updatedEvent = originalEvent.copyWith(
        start: details.startTime,
        end: details.endTime,
      );

      context.read<EventBloc>().add(
            EventUpdate(updatedEvent),
          );
    } catch (e) {
      debugPrint('Error finding event: $e');
    }
  }

  void _handleDragStart(AppointmentDragStartDetails details) {
    // Optional: Add any special behavior when drag starts
  }

  void _handleDragUpdate(AppointmentDragUpdateDetails details) {
    // Optional: Add any special behavior during drag
  }

  void _handleDragEnd(AppointmentDragEndDetails details) {
    try {
      final Appointment appointment = details.appointment as Appointment;
      String appointmentId = appointment.id.toString();

      // Get the new times from the appointment itself, which has been updated
      // by the drag operation
      final DateTime newStartTime = appointment.startTime;
      final DateTime newEndTime = appointment.endTime;

      if (widget.events.any((event) => event.id == appointmentId)) {
        final EventModel originalEvent = widget.events.firstWhere(
          (event) => event.id == appointmentId,
        );

        // Show dialog asking whether to move or copy
        _showMoveOrCopyDialog(
          originalEvent,
          newStartTime,
          newEndTime,
        );
      } else {
        debugPrint('Event with ID $appointmentId not found');
      }
    } catch (e) {
      debugPrint('Error in drag end: $e');
    }
  }

  void _showAddEventDialog(DateTime startTime, DateTime endTime) {
    showDialog(
      context: context,
      builder: (context) => EventEditDialog(
        startTime: startTime,
        endTime: endTime,
        onSave: (title, description, start, end, color) {
          final newEvent = EventModel(
            id: _uuid.v4(),
            title: title,
            description: description,
            start: start,
            end: end,
            color: color,
          );

          context.read<EventBloc>().add(EventAdd(newEvent));
        },
      ),
    );
  }

  void _showDuplicateDialog(Appointment appointment) {
    try {
      final originalEvent = widget.events.firstWhere(
        (event) => event.id == appointment.id.toString(),
      );

      showDialog(
        context: context,
        builder: (context) => EventEditDialog(
          title: 'Copy - ${originalEvent.title}',
          description: originalEvent.description,
          startTime: originalEvent.start,
          endTime: originalEvent.end,
          color: originalEvent.color,
          onSave: (title, description, start, end, color) {
            final newEvent = EventModel(
              id: _uuid.v4(),
              title: title,
              description: description,
              start: start,
              end: end,
              color: color,
            );

            context.read<EventBloc>().add(EventAdd(newEvent));
          },
        ),
      );
    } catch (e) {
      debugPrint('Error showing duplicate dialog: $e');
    }
  }

  void _showMoveOrCopyDialog(
    EventModel event,
    DateTime newStart,
    DateTime newEnd,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Move or Copy?'),
        content: const Text(
          'Do you want to move this event or create a copy at the new location?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();

              // Move the event
              final updatedEvent = event.copyWith(
                start: newStart,
                end: newEnd,
              );

              context.read<EventBloc>().add(
                    EventUpdate(updatedEvent),
                  );
            },
            child: const Text('Move'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();

              // Duplicate the event at the new time
              context.read<EventBloc>().add(
                    EventDuplicate(
                      event.id,
                      newStart: newStart,
                      newEnd: newEnd,
                    ),
                  );
            },
            child: const Text('Copy'),
          ),
        ],
      ),
    );
  }
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
