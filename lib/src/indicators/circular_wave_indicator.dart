import 'package:flutter/painting.dart';

import 'slide_indicator.dart';
import 'slide_indicator_geometry.dart';

/// A row of dots where the active one shrinks as it travels and grows back
/// on arrival. Renamed from 3.x's `CircularWaveSlideIndicator`.
class CircularWaveIndicator extends SlideIndicator {
  /// Creates the indicator.
  const CircularWaveIndicator({super.style});

  @override
  void paint(Canvas canvas, Size size, SlideIndicatorGeometry g) {
    if (g.itemCount == 0) return;
    paintTrack(canvas, g);
    final active = Paint()..color = style.activeColor;
    final t = g.progress;
    // 3.x's curve: full size at either end, 30% midway.
    final radius = style.radius * ((1.4 * t - 0.7).abs() + 0.3);
    final from = dotCenter(g.from, g);
    final to = g.to;
    if (to == null || t == 0) {
      canvas.drawCircle(from, style.radius, active);
    } else if (to > g.from) {
      canvas.drawCircle(
        Offset.lerp(from, dotCenter(to, g), t)!,
        radius,
        active,
      );
    } else {
      final pitch = step(g);
      canvas
        ..save()
        ..clipRect(Offset.zero & size)
        ..drawCircle(from + pitch * t, radius, active)
        ..drawCircle(dotCenter(0, g) - pitch * (1 - t), radius, active)
        ..restore();
    }
    paintRings(canvas, g);
  }

  @override
  bool operator ==(Object other) =>
      other is CircularWaveIndicator && other.style == style;

  @override
  int get hashCode => Object.hash(CircularWaveIndicator, style);
}
