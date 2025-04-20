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

  void _showEventBriefInfo(EventModel event, Appointment appointment) {
    // Remove any existing overlay first
    _removeOverlay();

    // Get the calendar widget's position and size
    final RenderBox calendarRenderBox = context.findRenderObject() as RenderBox;
    final calendarPosition = calendarRenderBox.localToGlobal(Offset.zero);
    final calendarSize = calendarRenderBox.size;

    // Calculate the event's position in the calendar
    Offset position;

    // Try to find the appointment's position based on the current view
    switch (_calendarController.view) {
      case CalendarView.day:
      case CalendarView.week:
      case CalendarView.workWeek:
        // For day/week views, calculate vertical position based on time
        final dayHeight = calendarSize.height;
        final startHour = 7.0; // From the TimeSlotViewSettings
        final endHour = 20.0; // From the TimeSlotViewSettings
        final totalHours = endHour - startHour;

        final startTimeHour =
            appointment.startTime.hour + (appointment.startTime.minute / 60.0);
        final relativePosition = (startTimeHour - startHour) / totalHours;
        final yPosition = calendarPosition.dy + (dayHeight * relativePosition);

        // Position horizontally at 25% of calendar width, but not off-screen
        final xPosition = calendarPosition.dx + (calendarSize.width * 0.25);
        position = Offset(xPosition, yPosition);
        break;

      case CalendarView.month:
      case CalendarView.schedule:
      case CalendarView.timelineDay:
      case CalendarView.timelineWeek:
      case CalendarView.timelineWorkWeek:
      case CalendarView.timelineMonth:
      default:
        // For other views, position near the center of the calendar
        position = Offset(
          calendarPosition.dx + calendarSize.width * 0.25,
          calendarPosition.dy + calendarSize.height * 0.3,
        );
        break;
    }

    // Ensure the popup won't go off-screen
    final screenSize = MediaQuery.of(context).size;
    final maxWidth = screenSize.width * 0.8;

    if (position.dx + maxWidth > screenSize.width) {
      position = Offset(screenSize.width - maxWidth - 20, position.dy);
    }

    if (position.dx < 10) {
      position = Offset(10, position.dy);
    }

    if (position.dy < 10) {
      position = Offset(position.dx, 10);
    }

    if (position.dy > screenSize.height - 200) {
      position = Offset(position.dx, screenSize.height - 200);
    }

    // Create the overlay entry
    _overlayEntry = OverlayEntry(
      builder: (context) => EventBriefInfo(
        event: event,
        position: position,
        onClose: _removeOverlay,
        onEdit: _showEditEventDialog,
        onDuplicate: (event) => _showDuplicateDialogFromEvent(event),
        onDelete: (event) =>
            context.read<EventBloc>().add(EventDelete(event.id)),
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

      try {
        final eventId = appointment.id.toString();
        final event = widget.events.firstWhere((e) => e.id == eventId);

        // Show brief info with actions
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showEventBriefInfo(event, appointment);
        });
      } catch (e) {
        debugPrint('Error showing brief info: $e');
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

  void _showDuplicateDialogFromEvent(EventModel originalEvent) {
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
  }

  @override
  void didUpdateWidget(DraggableCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update the calendar view if it changed
    if (oldWidget.calendarViewType != widget.calendarViewType) {
      _calendarController.view = _getCalendarView();
    }
  }
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
