import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:uuid/uuid.dart';

import '../blocs/event/event_bloc.dart';
import '../blocs/event/event_event.dart';
import '../models/event_model.dart';
import '../utils/time_utils.dart';
import 'event_brief_info.dart';
import 'event_edit_dialog.dart';

class DraggableCalendar extends StatefulWidget {
  final CalendarViewType calendarViewType;
  final List<EventModel> events;
  final int timeSnapInterval; // In minutes

  const DraggableCalendar({
    super.key,
    required this.calendarViewType,
    required this.events,
    this.timeSnapInterval = 15, // Default to 15 minutes
  });

  @override
  State<DraggableCalendar> createState() => _DraggableCalendarState();
}

class _DraggableCalendarState extends State<DraggableCalendar> {
  late CalendarController _calendarController;
  final _uuid = const Uuid();
  DateTime? _lastTapTime;
  EventModel? _selectedEvent;
  final Offset _tapPosition = Offset.zero;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _calendarController = CalendarController();
  }

  @override
  void dispose() {
    _removeOverlay();
    _calendarController.dispose();
    super.dispose();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showEventBriefInfo(EventModel event) {
    // Remove any existing overlay first
    _removeOverlay();

    // Position the popup in the center of the screen with a slight offset
    final screenSize = MediaQuery.of(context).size;
    final position = Offset(screenSize.width * 0.2, screenSize.height * 0.3);

    // Create the overlay entry
    _overlayEntry = OverlayEntry(
      builder: (context) => EventBriefInfo(
        event: event,
        position: position,
        onClose: _removeOverlay,
      ),
    );

    // Insert the overlay
    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    return SfCalendar(
      controller: _calendarController,
      view: _getCalendarView(),
      dataSource: _getCalendarDataSource(),
      allowDragAndDrop: true,
      allowAppointmentResize: true,
      timeSlotViewSettings: TimeSlotViewSettings(
        timeInterval: Duration(minutes: widget.timeSnapInterval),
        timeIntervalHeight: 50,
        timeFormat: 'HH:mm',
        startHour: 7,
        endHour: 20,
      ),
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

  DateTime _snapTimeToInterval(DateTime time) {
    return TimeUtils.snapToInterval(time, widget.timeSnapInterval);
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
        // This is a double tap - show options dialog
        _removeOverlay(); // Make sure to remove any existing brief info
        _showEventOptionsDialog(appointment);
        _lastTapTime = null;
      } else {
        // This is a single tap - show brief info
        _lastTapTime = now;

        try {
          final eventId = appointment.id.toString();
          final event = widget.events.firstWhere((e) => e.id == eventId);

          // We need to use post-frame callback to ensure the overlay is created
          // after the current frame is finished building
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showEventBriefInfo(event);
          });
        } catch (e) {
          debugPrint('Error showing brief info: $e');
        }
      }
    } else if (details.targetElement == CalendarElement.calendarCell &&
        details.date != null) {
      // Remove any existing brief info when tapping on empty cell
      _removeOverlay();

      // Create new event when clicking on empty cell
      final snappedTime = _snapTimeToInterval(details.date!);
      final endTime =
          snappedTime.add(Duration(minutes: widget.timeSnapInterval));

      _showAddEventDialog(snappedTime, endTime);
    }
  }

  void _handleDragEnd(AppointmentDragEndDetails details) {
    // Remove any existing brief info when dragging
    _removeOverlay();

    try {
      final Appointment appointment = details.appointment as Appointment;
      String appointmentId = appointment.id.toString();

      // Ensure we have valid times by using the appointment's times if needed
      final DateTime startTime = appointment.startTime;
      final DateTime endTime = appointment.endTime;

      // Get the times from the appointment and snap them to intervals
      final DateTime newStartTime = _snapTimeToInterval(startTime);

      // Calculate the duration to preserve it
      final Duration eventDuration = endTime.difference(startTime);
      final DateTime newEndTime = newStartTime.add(eventDuration);

      if (widget.events.any((event) => event.id == appointmentId)) {
        final EventModel originalEvent = widget.events.firstWhere(
          (event) => event.id == appointmentId,
        );

        // Always move the event (no dialog)
        final updatedEvent = originalEvent.copyWith(
          start: newStartTime,
          end: newEndTime,
        );

        context.read<EventBloc>().add(
              EventUpdate(updatedEvent),
            );
      } else {
        debugPrint('Event with ID $appointmentId not found');
      }
    } catch (e) {
      debugPrint('Error in drag end: $e');
    }
  }

  void _showEventOptionsDialog(Appointment appointment) {
    try {
      final originalEvent = widget.events.firstWhere(
        (event) => event.id == appointment.id.toString(),
      );

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(originalEvent.title),
          content: const Text('What would you like to do with this event?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();

                // Show dialog to edit the event
                _showEditEventDialog(originalEvent);
              },
              child: const Text('Edit'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();

                // Show dialog to duplicate the event
                _showDuplicateDialog(appointment);
              },
              child: const Text('Duplicate'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();

                // Show confirmation dialog for deletion
                _showDeleteConfirmationDialog(originalEvent);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
    } catch (e) {
      debugPrint('Error showing event options dialog: $e');
    }
  }

  void _showEditEventDialog(EventModel event) {
    showDialog(
      context: context,
      builder: (context) => EventEditDialog(
        title: event.title,
        description: event.description,
        startTime: event.start,
        endTime: event.end,
        color: event.color,
        onSave: (title, description, start, end, color) {
          // Snap the times to intervals when editing
          final snappedStart = _snapTimeToInterval(start);
          final snappedEnd = _snapTimeToInterval(end);

          final updatedEvent = event.copyWith(
            title: title,
            description: description,
            start: snappedStart,
            end: snappedEnd,
            color: color,
          );

          context.read<EventBloc>().add(EventUpdate(updatedEvent));
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(EventModel event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<EventBloc>().add(EventDelete(event.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _handleCalendarLongPress(CalendarLongPressDetails details) {
    // Remove any existing brief info on long press
    _removeOverlay();

    if (details.targetElement == CalendarElement.appointment) {
      // Long press behavior is handled by the built-in drag & drop
    } else if (details.targetElement == CalendarElement.calendarCell) {
      // Create a new appointment on long press on an empty cell
      final DateTime date = details.date!;

      // Snap the time to the nearest interval
      final DateTime snappedTime = _snapTimeToInterval(date);
      final DateTime endTime =
          snappedTime.add(Duration(minutes: widget.timeSnapInterval));

      _showAddEventDialog(snappedTime, endTime);
    }
  }

  void _handleAppointmentResizeStart(AppointmentResizeStartDetails details) {
    // Remove any existing brief info when resizing
    _removeOverlay();
  }

  void _handleAppointmentResizeUpdate(AppointmentResizeUpdateDetails details) {
    // Optional: Visual feedback during resize
  }

  void _handleAppointmentResizeEnd(AppointmentResizeEndDetails details) {
    try {
      final Appointment appointment = details.appointment as Appointment;
      String appointmentId = appointment.id.toString();

      // Use appointment's times as fallback if details.startTime or details.endTime are null
      final DateTime startTime = details.startTime ?? appointment.startTime;
      final DateTime endTime = details.endTime ?? appointment.endTime;

      // Snap both start and end times to intervals
      final DateTime snappedStartTime = _snapTimeToInterval(startTime);
      final DateTime snappedEndTime = _snapTimeToInterval(endTime);

      if (widget.events.any((event) => event.id == appointmentId)) {
        final EventModel originalEvent = widget.events.firstWhere(
          (event) => event.id == appointmentId,
        );

        final EventModel updatedEvent = originalEvent.copyWith(
          start: snappedStartTime,
          end: snappedEndTime,
        );

        context.read<EventBloc>().add(
              EventUpdate(updatedEvent),
            );
      }
    } catch (e) {
      debugPrint('Error in resize end: $e');
    }
  }

  void _handleDragStart(AppointmentDragStartDetails details) {
    // Remove any existing brief info when starting to drag
    _removeOverlay();
  }

  void _handleDragUpdate(AppointmentDragUpdateDetails details) {
    // Optional: Visual feedback during drag
  }

  void _showAddEventDialog(DateTime startTime, DateTime endTime) {
    showDialog(
      context: context,
      builder: (context) => EventEditDialog(
        startTime: startTime,
        endTime: endTime,
        onSave: (title, description, start, end, color) {
          // Snap the times to intervals when saving a new event
          final snappedStart = _snapTimeToInterval(start);
          final snappedEnd = _snapTimeToInterval(end);

          final newEvent = EventModel(
            id: _uuid.v4(),
            title: title,
            description: description,
            start: snappedStart,
            end: snappedEnd,
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
              start: start, // Use the dates directly from the dialog
              end: end, // without additional snapping (already done in dialog)
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
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
