import 'package:draggable_calendar/draggable_calendar.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TimeUtils', () {
    test('snapToInterval with 15 minute interval rounds down correctly', () {
      final time = DateTime(2025, 4, 20, 10, 7);
      final snapped = TimeUtils.snapToInterval(time, 15);

      expect(snapped.minute, 0);
      expect(snapped.hour, 10);
    });

    test('snapToInterval with 15 minute interval rounds up correctly', () {
      final time = DateTime(2025, 4, 20, 10, 8);
      final snapped = TimeUtils.snapToInterval(time, 15);

      expect(snapped.minute, 15);
      expect(snapped.hour, 10);
    });

    test('snapToInterval with 30 minute interval rounds correctly', () {
      final time = DateTime(2025, 4, 20, 10, 20);
      final snapped = TimeUtils.snapToInterval(time, 30);

      expect(snapped.minute, 30);
      expect(snapped.hour, 10);
    });

    test('snapToInterval with 60 minute interval rounds correctly', () {
      final time = DateTime(2025, 4, 20, 10, 40);
      final snapped = TimeUtils.snapToInterval(time, 60);

      expect(snapped.minute, 0);
      expect(snapped.hour, 11);
    });

    test('snapToInterval when already on interval returns same time', () {
      final time = DateTime(2025, 4, 20, 10, 30);
      final snapped = TimeUtils.snapToInterval(time, 30);

      expect(snapped.minute, 30);
      expect(snapped.hour, 10);
      expect(snapped, time);
    });

    test('snapToInterval handles hour rollover', () {
      final time = DateTime(2025, 4, 20, 10, 55);
      final snapped = TimeUtils.snapToInterval(time, 30);

      expect(snapped.minute, 0);
      expect(snapped.hour, 11);
    });
  });
}
