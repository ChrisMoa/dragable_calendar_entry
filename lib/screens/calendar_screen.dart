import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import '../blocs/event/event_bloc.dart';
import '../blocs/event/event_event.dart';
import '../blocs/event/event_state.dart';
import '../models/event_model.dart';
import '../widgets/draggable_calendar.dart';
import '../widgets/event_edit_dialog.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Draggable Calendar'),
        actions: [
          _buildViewSelector(context),
        ],
      ),
      body: BlocBuilder<EventBloc, EventState>(
        builder: (context, state) {
          return DraggableCalendar(
            calendarViewType: state.calendarView,
            events: state.events,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Show dialog to add a new event
          final now = DateTime.now();
          final startTime = DateTime(now.year, now.month, now.day, now.hour);
          final endTime = startTime.add(const Duration(hours: 1));

          _showAddEventDialog(context, startTime, endTime);
        },
        child: const Icon(Icons.add),
      ),
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
