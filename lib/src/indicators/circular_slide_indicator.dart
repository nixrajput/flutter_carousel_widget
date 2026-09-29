import 'package:flutter/painting.dart';

import 'slide_indicator.dart';
import 'slide_indicator_geometry.dart';

/// A row of dots with the active one sliding between them as the carousel
/// moves; the default indicator.
class CircularSlideIndicator extends SlideIndicator {
  /// Creates the indicator.
  const CircularSlideIndicator({super.style});

  @override
  void paint(Canvas canvas, Size size, SlideIndicatorGeometry g) {
    if (g.itemCount == 0) return;
    paintTrack(canvas, g);
    final active = Paint()..color = style.activeColor;
    final from = dotCenter(g.from, g);
    final to = g.to;
    if (to == null || g.progress == 0) {
      canvas.drawCircle(from, style.radius, active);
    } else if (to > g.from) {
      canvas.drawCircle(
        Offset.lerp(from, dotCenter(to, g), g.progress)!,
        style.radius,
        active,
      );
    } else {
      // Wrapping: the dot slides out past the last one and in before the
      // first, clipped to the track.
      final pitch = step(g);
      canvas
        ..save()
        ..clipRect(Offset.zero & size)
        ..drawCircle(from + pitch * g.progress, style.radius, active)
        ..drawCircle(
          dotCenter(0, g) - pitch * (1 - g.progress),
          style.radius,
          active,
        )
        ..restore();
    }
    paintRings(canvas, g);
  }

  @override
  bool operator ==(Object other) =>
      other is CircularSlideIndicator && other.style == style;

  @override
  int get hashCode => Object.hash(CircularSlideIndicator, style);
}
