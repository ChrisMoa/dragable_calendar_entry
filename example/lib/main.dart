import 'package:draggable_calendar/draggable_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Draggable Calendar Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatefulWidget {
  const ExampleHomePage({super.key});

  @override
  State<ExampleHomePage> createState() => _ExampleHomePageState();
}

class _ExampleHomePageState extends State<ExampleHomePage> {
  late EventBloc _eventBloc;
  final int _timeSnapInterval = 15;

  @override
  void initState() {
    super.initState();
    _eventBloc = EventBloc(initialEvents: EventBloc.generateSampleEvents());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Draggable Calendar Example'),
        actions: const [
          // View selector
          // Time interval selector
        ],
      ),
      body: BlocBuilder<EventBloc, EventState>(
        bloc: _eventBloc,
        builder: (context, state) {
          return DraggableCalendar(
            calendarViewType: state.calendarView,
            events: state.events,
            timeSnapInterval: _timeSnapInterval,
            eventBloc: _eventBloc,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewEvent,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _addNewEvent() {
    // Get the current date/time
    final now = DateTime.now();

    // Create a snapped start time at the current hour
    final startTime = DateTime(now.year, now.month, now.day, now.hour);
    final snappedStartTime =
        TimeUtils.snapToInterval(startTime, _timeSnapInterval);

    // Set end time to be timeSnapInterval minutes after start
    final endTime = snappedStartTime.add(Duration(minutes: _timeSnapInterval));

    // Show dialog to add a new event
    showDialog(
      context: context,
      builder: (context) => EventEditDialog(
        startTime: snappedStartTime,
        endTime: endTime,
        onSave: (title, description, start, end, color) {
          // Create a new event
          final newEvent = EventModel(
            id: const Uuid().v4(),
            title: title,
            description: description,
            start: start,
            end: end,
            color: color,
          );

          // Add the event to the bloc
          _eventBloc.add(EventAdd(newEvent));
        },
      ),
    );
  }

  // Add new event implementation
}
