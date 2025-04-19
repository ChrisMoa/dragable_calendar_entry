import 'package:flutter/material.dart';

import 'screens/calendar_screen.dart';

class DraggableCalendarApp extends StatelessWidget {
  const DraggableCalendarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Draggable Calendar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const CalendarScreen(),
    );
  }
}
