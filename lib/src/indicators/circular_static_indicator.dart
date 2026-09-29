import 'package:flutter/painting.dart';

import 'slide_indicator.dart';
import 'slide_indicator_geometry.dart';

/// A row of dots where the current one is filled. With
/// [SlideIndicatorStyle.animated], it shrinks into the next dot as the
/// carousel moves.
class CircularStaticIndicator extends SlideIndicator {
  /// Creates the indicator.
  const CircularStaticIndicator({super.style});

  @override
  void paint(Canvas canvas, Size size, SlideIndicatorGeometry g) {
    if (g.itemCount == 0) return;
    paintTrack(canvas, g);
    final active = Paint()..color = style.activeColor;
    final to = g.to;
    if (!style.animated || to == null || g.progress == 0) {
      canvas.drawCircle(dotCenter(g.nearest, g), style.radius, active);
    } else {
      canvas
        ..drawCircle(
          dotCenter(g.from, g),
          style.radius * (1 - g.progress),
          active,
        )
        ..drawCircle(dotCenter(to, g), style.radius * g.progress, active);
    }
    paintRings(canvas, g);
  }

  @override
  bool operator ==(Object other) =>
      other is CircularStaticIndicator && other.style == style;

  @override
  int get hashCode => Object.hash(CircularStaticIndicator, style);
}
