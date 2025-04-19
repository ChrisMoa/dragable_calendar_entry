import 'package:dragable_calendar_entry/blocs/event/event_bloc.dart';
import 'package:dragable_calendar_entry/blocs/event/event_event.dart';
import 'package:dragable_calendar_entry/blocs/event/event_state.dart';
import 'package:dragable_calendar_entry/models/event_model.dart';
import 'package:dragable_calendar_entry/utils/time_utils.dart';
import 'package:dragable_calendar_entry/widgets/draggable_calendar.dart';
import 'package:dragable_calendar_entry/widgets/event_edit_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  int _timeSnapInterval = 15; // Default to 15 minutes

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Draggable Calendar'),
        actions: [
          _buildViewSelector(context),
          _buildIntervalSelector(context),
        ],
      ),
      body: BlocBuilder<EventBloc, EventState>(
        builder: (context, state) {
          return DraggableCalendar(
            calendarViewType: state.calendarView,
            events: state.events,
            timeSnapInterval: _timeSnapInterval,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show dialog to add a new event
          final now = DateTime.now();
          final startTime = DateTime(now.year, now.month, now.day, now.hour);
          final snappedTime =
              TimeUtils.snapToInterval(startTime, _timeSnapInterval);
          final endTime = snappedTime.add(Duration(minutes: _timeSnapInterval));

          _showAddEventDialog(context, snappedTime, endTime);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildIntervalSelector(BuildContext context) {
    return PopupMenuButton<int>(
      icon: const Icon(Icons.timelapse),
      tooltip: 'Set time interval',
      initialValue: _timeSnapInterval,
      onSelected: (int value) {
        setState(() {
          _timeSnapInterval = value;
        });
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 5,
          child: Text('5 Minutes'),
        ),
        const PopupMenuItem(
          value: 10,
          child: Text('10 Minutes'),
        ),
        const PopupMenuItem(
          value: 15,
          child: Text('15 Minutes'),
        ),
        const PopupMenuItem(
          value: 30,
          child: Text('30 Minutes'),
        ),
        const PopupMenuItem(
          value: 60,
          child: Text('1 Hour'),
        ),
      ],
    );
  }

  Widget _buildViewSelector(BuildContext context) {
    return BlocBuilder<EventBloc, EventState>(
      builder: (context, state) {
        return PopupMenuButton<CalendarViewType>(
          icon: const Icon(Icons.calendar_view_day),
          initialValue: state.calendarView,
          onSelected: (CalendarViewType value) {
            context.read<EventBloc>().add(EventChangeView(value));
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: CalendarViewType.day,
              child: Text('Day View'),
            ),
            const PopupMenuItem(
              value: CalendarViewType.week,
              child: Text('Week View'),
            ),
            const PopupMenuItem(
              value: CalendarViewType.month,
              child: Text('Month View'),
            ),
            const PopupMenuItem(
              value: CalendarViewType.schedule,
              child: Text('Schedule View'),
            ),
          ],
        );
      },
    );
  }

  void _showAddEventDialog(
      BuildContext context, DateTime startTime, DateTime endTime) {
    showDialog(
      context: context,
      builder: (context) => EventEditDialog(
        startTime: startTime,
        endTime: endTime,
        onSave: (title, description, start, end, color) {
          final newEvent = EventModel(
            id: const Uuid().v4(),
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
}
