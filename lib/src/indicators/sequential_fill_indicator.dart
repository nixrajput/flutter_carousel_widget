import 'package:flutter/painting.dart';

import 'slide_indicator.dart';
import 'slide_indicator_geometry.dart';

/// Dots filled from the first up to the current one, like a progress bar.
/// With [SlideIndicatorStyle.animated], the fill follows the drag.
class SequentialFillIndicator extends SlideIndicator {
  /// Creates the indicator.
  const SequentialFillIndicator({super.style});

  @override
  void paint(Canvas canvas, Size size, SlideIndicatorGeometry g) {
    if (g.itemCount == 0) return;
    paintTrack(canvas, g);
    final to = g.to;
    final end = style.animated && to != null && to > g.from
        ? Offset.lerp(dotCenter(g.from, g), dotCenter(to, g), g.progress)!
        : dotCenter(style.animated ? g.from : g.nearest, g);
    final dots = Path();
    for (var i = 0; i < g.itemCount; i++) {
      dots.addOval(
        Rect.fromCircle(center: dotCenter(i, g), radius: style.radius),
      );
    }
    canvas
      ..save()
      ..clipPath(dots)
      ..drawLine(
        dotCenter(0, g),
        end,
        Paint()
          ..color = style.activeColor
          ..strokeWidth = 2 * style.radius
          ..strokeCap = StrokeCap.round,
      )
      ..restore();
    paintRings(canvas, g);
  }

  @override
  bool operator ==(Object other) =>
      other is SequentialFillIndicator && other.style == style;

  @override
  int get hashCode => Object.hash(SequentialFillIndicator, style);
}
