# Draggable Calendar

This package is based on Syncfusion Flutter Calendar, providing enhanced draggable functionality.

> **Note**: This project utilizes Syncfusion Flutter Calendar as its foundation. Users of this package must comply with both GPL-3.0 and Syncfusion's licensing requirements.

[![pub package](https://img.shields.io/pub/v/draggable_calendar.svg)](https://pub.dev/packages/draggable_calendar)

## Features

- **Multiple Calendar Views**: Day, Week, Month, and Schedule views
- **Draggable Events**: Move events by drag and drop
- **Resizable Events**: Adjust event duration by resizing
- **Time Snapping**: Snap event times to intervals (e.g., 15, 30, 60 minutes)
- **Event Management**: Create, edit, duplicate, and delete events
- **Customizable Colors**: Set colors for individual events
- **Flexible API**: Works with both BLoC pattern and callback-based approaches
- **Responsive Design**: Adapts to different screen sizes and orientations

## Installation

Add `draggable_calendar` to your `pubspec.yaml`:

```yaml
dependencies:
  draggable_calendar: ^0.1.0
```

Run:

```
flutter pub get
```

## Basic Usage

```dart
import 'package:flutter/material.dart';
import 'package:draggable_calendar/draggable_calendar.dart';
import 'package:uuid/uuid.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Draggable Calendar Example',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: CalendarPage(),
    );
  }
}

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  List<EventModel> _events = [];
  CalendarViewType _viewType = CalendarViewType.week;
  
  @override
  void initState() {
    super.initState();
    // Add some sample events
    _events = _createSampleEvents();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calendar'),
        actions: [
          // View type selector
          PopupMenuButton<CalendarViewType>(
            icon: Icon(Icons.calendar_view_day),
            onSelected: (CalendarViewType value) {
              setState(() {
                _viewType = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: CalendarViewType.day,
                child: Text('Day View'),
              ),
              PopupMenuItem(
                value: CalendarViewType.week,
                child: Text('Week View'),
              ),
              PopupMenuItem(
                value: CalendarViewType.month,
                child: Text('Month View'),
              ),
            ],
          ),
        ],
      ),
      body: DraggableCalendar(
        calendarViewType: _viewType,
        events: _events,
        timeSnapInterval: 15,
        onEventAdd: _handleEventAdd,
        onEventUpdate: _handleEventUpdate,
        onEventDelete: _handleEventDelete,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewEvent,
        child: Icon(Icons.add),
      ),
    );
  }
  
  void _handleEventAdd(EventModel event) {
    setState(() {
      _events.add(event);
    });
  }
  
  void _handleEventUpdate(EventModel event) {
    setState(() {
      final index = _events.indexWhere((e) => e.id == event.id);
      if (index >= 0) {
        _events[index] = event;
      }
    });
  }
  
  void _handleEventDelete(String eventId) {
    setState(() {
      _events.removeWhere((e) => e.id == eventId);
    });
  }
  
  void _addNewEvent() {
    // Show dialog to create a new event
    final now = DateTime.now();
    final startTime = DateTime(now.year, now.month, now.day, now.hour);
    final endTime = startTime.add(Duration(hours: 1));
    
    // Rest of implementation...
  }
  
  List<EventModel> _createSampleEvents() {
    final now = DateTime.now();
    final uuid = Uuid();
    
    return [
      EventModel(
        id: uuid.v4(),
        title: 'Meeting',
        description: 'Team standup',
        start: DateTime(now.year, now.month, now.day, 10),
        end: DateTime(now.year, now.month, now.day, 11),
        color: Colors.blue,
      ),
      EventModel(
        id: uuid.v4(),
        title: 'Lunch',
        description: 'With client',
        start: DateTime(now.year, now.month, now.day, 12, 30),
        end: DateTime(now.year, now.month, now.day, 13, 30),
        color: Colors.green,
      ),
    ];
  }
}
```

## Advanced Usage with BLoC

For projects using BLoC pattern:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:draggable_calendar/draggable_calendar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar with BLoC',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BlocProvider(
        create: (context) => EventBloc(),
        child: CalendarPage(),
      ),
    );
  }
}

class CalendarPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Calendar')),
      body: BlocBuilder<EventBloc, EventState>(
        builder: (context, state) {
          return DraggableCalendar(
            calendarViewType: state.calendarView,
            events: state.events,
            eventBloc: context.read<EventBloc>(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new event logic
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
```

## Customization Options

### Time Interval

Set the time snapping interval in minutes:

```dart
DraggableCalendar(
  // ...
  timeSnapInterval: 30, // 30-minute intervals
  // ...
)
```

### Time Range

Control the visible hours in the day view:

```dart
DraggableCalendar(
  // ...
  startHour: 8, // Start at 8:00 AM
  endHour: 18, // End at 6:00 PM
  // ...
)
```

### Time Slot Height

Adjust the height of each time slot:

```dart
DraggableCalendar(
  // ...
  timeIntervalHeight: 60, // Taller time slots
  // ...
)
```

## API Reference

### Main Components

- `DraggableCalendar` - The main calendar widget
- `EventModel` - Model class for calendar events
- `EventBloc`, `EventState`, `EventBlocEvent` - Optional BLoC components

### DraggableCalendar Properties

| Property           | Type                      | Description                                   |
|--------------------|---------------------------|-----------------------------------------------|
| calendarViewType   | CalendarViewType          | The current view type (day, week, month)      |
| events             | List<EventModel>          | List of events to display                     |
| timeSnapInterval   | int                       | Interval in minutes for time snapping         |
| onEventAdd         | Function(EventModel)?     | Callback when an event is added              |
| onEventUpdate      | Function(EventModel)?     | Callback when an event is updated            |
| onEventDelete      | Function(String)?         | Callback when an event is deleted            |
| onEventDuplicate   | Function(EventModel)?     | Callback when an event is duplicated         |
| onViewChanged      | Function(CalendarViewType)? | Callback when view type changes             |
| eventBloc          | EventBloc?                | Optional BLoC for state management           |
| startHour          | double                    | Start hour of the day view (default: 7)      |
| endHour            | double                    | End hour of the day view (default: 20)       |
| timeIntervalHeight | double                    | Height of each time slot (default: 50)       |

### EventModel Properties

| Property      | Type        | Description                          |
|---------------|-------------|--------------------------------------|
| id            | String      | Unique identifier for the event      |
| title         | String      | Event title                          |
| description   | String      | Event description                    |
| start         | DateTime    | Start date and time                  |
| end           | DateTime    | End date and time                    |
| color         | Color       | Event color (default: Colors.blue)   |

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the GNU GENERAL PUBLIC LICENSE License - see the LICENSE file for details.