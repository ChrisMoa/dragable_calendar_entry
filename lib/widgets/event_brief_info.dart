import 'package:flutter/material.dart';

import '../models/event_model.dart';
import '../utils/date_utils.dart';

class EventBriefInfo extends StatefulWidget {
  final EventModel event;
  final VoidCallback onClose;
  final Offset position;

  const EventBriefInfo({
    super.key,
    required this.event,
    required this.onClose,
    required this.position,
  });

  @override
  State<EventBriefInfo> createState() => _EventBriefInfoState();
}

class _EventBriefInfoState extends State<EventBriefInfo>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
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
                    color: widget.event.color.withOpacity(0.5),
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
                                color: widget.event.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                widget.event.title,
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
                              widget.event.start, widget.event.end),
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                        if (widget.event.description.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            widget.event.description,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
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
}
