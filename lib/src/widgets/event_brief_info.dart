// lib/src/widgets/event_brief_info.dart
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../blocs/event/event_bloc.dart';
import '../blocs/event/event_event.dart';
import '../models/event_model.dart';
import '../utils/date_utils.dart';

class EventBriefInfo extends StatefulWidget {
  final EventModel event;
  final VoidCallback onClose;
  final Offset position;

  // Callback-based approach (primary)
  final Function(EventModel) onEdit;
  final Function(EventModel) onDuplicate;
  final Function(EventModel) onDelete;

  // Duration change callbacks
  final Function(EventModel)? onDurationChange;

  // Optional BLoC
  final EventBloc? eventBloc;

  const EventBriefInfo({
    super.key,
    required this.event,
    required this.onClose,
    required this.position,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
    this.onDurationChange,
    this.eventBloc,
  });

  @override
  State<EventBriefInfo> createState() => _EventBriefInfoState();
}

class _EventBriefInfoState extends State<EventBriefInfo>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  int _durationMinutes = 0;
  late EventModel _eventCopy;

  @override
  void initState() {
    super.initState();

    // Initialize the local event copy and duration
    _eventCopy = widget.event;
    _durationMinutes = _eventCopy.end.difference(_eventCopy.start).inMinutes;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 333),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    // Start animation
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // This transparent container covers the whole screen to detect taps outside
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.onClose,
            behavior: HitTestBehavior.opaque,
            child: Container(
              color: Colors.transparent,
            ),
          ),
        ),
        // The actual info card with animation
        Positioned(
          left: widget.position.dx,
          top: widget.position.dy,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                ),
              );
            },
            child: GestureDetector(
              onTap: () {}, // Prevent taps from reaching the background
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: _eventCopy.color.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: _eventCopy.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _eventCopy.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.close, size: 16),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: widget.onClose,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DateTimeUtils.formatDateRange(
                              _eventCopy.start, _eventCopy.end),
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                        if (_eventCopy.description.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            _eventCopy.description,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],

                        // Add the duration controls
                        _buildDurationControls(),

                        const SizedBox(height: 16),
                        // Action buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              onPressed: _showEditDialog,
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('Edit'),
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _showDuplicateDialog,
                              icon: const Icon(Icons.copy, size: 18),
                              label: const Text('Duplicate'),
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: _showDeleteConfirmation,
                              icon: const Icon(Icons.delete, size: 18),
                              label: const Text('Delete'),
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                foregroundColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showEditDialog() {
    widget.onClose(); // Close the popup first
    widget.onEdit(_eventCopy);
  }

  void _showDuplicateDialog() {
    widget.onClose(); // Close the popup first
    widget.onDuplicate(_eventCopy);
  }

  void _showDeleteConfirmation() {
    widget.onClose(); // Close the popup first

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${_eventCopy.title}"?'),
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
              widget.onDelete(_eventCopy);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationControls() {
    // Only show on mobile
    final bool isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);
    if (!isMobile) return const SizedBox.shrink();

    // Use 15 minutes as default interval
    const int timeInterval = 15;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 24),
        const Text('Adjust Duration:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8),
              onPressed: _durationMinutes <= timeInterval
                  ? null
                  : () {
                      // Decrease duration by one interval
                      setState(() {
                        _durationMinutes -= timeInterval;
                        final newEnd = _eventCopy.start
                            .add(Duration(minutes: _durationMinutes));
                        _eventCopy = _eventCopy.copyWith(end: newEnd);
                      });

                      // Update the event using callback or bloc
                      if (widget.onDurationChange != null) {
                        widget.onDurationChange!(_eventCopy);
                      } else if (widget.eventBloc != null) {
                        widget.eventBloc!.add(EventUpdate(_eventCopy));
                      }
                    },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '${_durationMinutes ~/ 60}h ${_durationMinutes % 60}m',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              constraints: const BoxConstraints(),
              padding: const EdgeInsets.all(8),
              onPressed: () {
                // Increase duration by one interval
                setState(() {
                  _durationMinutes += timeInterval;
                  final newEnd =
                      _eventCopy.start.add(Duration(minutes: _durationMinutes));
                  _eventCopy = _eventCopy.copyWith(end: newEnd);
                });

                // Update the event using callback or bloc
                if (widget.onDurationChange != null) {
                  widget.onDurationChange!(_eventCopy);
                } else if (widget.eventBloc != null) {
                  widget.eventBloc!.add(EventUpdate(_eventCopy));
                }
              },
            ),
          ],
        ),
      ],
    );
  }
}
