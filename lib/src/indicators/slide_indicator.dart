import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'slide_indicator_geometry.dart';
import 'slide_indicator_style.dart';

/// Paints the dots of a carousel indicator. Extend it and implement [paint]
/// for a custom look; [dotCenter] and [size] place the dots.
@immutable
abstract class SlideIndicator {
  /// Lets subclasses be const.
  const SlideIndicator({this.style = const SlideIndicatorStyle()});

  /// How the dots look.
  final SlideIndicatorStyle style;

  double get _pad => style.borderColor == null ? 0 : style.borderWidth;

  /// The size the dots need for [itemCount] items along [axis].
  Size size(int itemCount, Axis axis) {
    final main = itemCount == 0
        ? 0.0
        : 2 * style.radius + (itemCount - 1) * style.spacing + _pad;
    final cross = 2 * style.radius + _pad;
    return axis == Axis.horizontal ? Size(main, cross) : Size(cross, main);
  }

  /// The centre of dot [i], in item order, mirrored when [g] is flipped.
  Offset dotCenter(int i, SlideIndicatorGeometry g) {
    final slot = g.flipped ? g.itemCount - 1 - i : i;
    final main = _pad / 2 + style.radius + slot * style.spacing;
    final cross = _pad / 2 + style.radius;
    return g.axis == Axis.horizontal
        ? Offset(main, cross)
        : Offset(cross, main);
  }

  /// Paints the dots into a box of [size], for [geometry].
  void paint(Canvas canvas, Size size, SlideIndicatorGeometry geometry);

  /// Draws the inactive dots and, when the style has a border colour, the
  /// rings around them; the base for the built-in painters.
  @protected
  void paintTrack(Canvas canvas, SlideIndicatorGeometry g) {
    final fill = Paint()..color = style.inactiveColor;
    for (var i = 0; i < g.itemCount; i++) {
      canvas.drawCircle(dotCenter(i, g), style.radius, fill);
    }
  }

  /// Draws the rings, last, so they sit over the active dot.
  @protected
  void paintRings(Canvas canvas, SlideIndicatorGeometry g) {
    final color = style.borderColor;
    if (color == null) return;
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = style.borderWidth
      ..color = color;
    for (var i = 0; i < g.itemCount; i++) {
      canvas.drawCircle(dotCenter(i, g), style.radius, ring);
    }
  }

  /// One dot pitch in the direction of increasing index, on screen.
  @protected
  Offset step(SlideIndicatorGeometry g) {
    final d = g.flipped ? -style.spacing : style.spacing;
    return g.axis == Axis.horizontal ? Offset(d, 0) : Offset(0, d);
  }
}
