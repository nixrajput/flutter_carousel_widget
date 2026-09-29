import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// How a slide indicator's dots look.
@immutable
class SlideIndicatorStyle {
  /// Creates a style. The defaults match 3.x: white dots on a translucent
  /// white track.
  const SlideIndicatorStyle({
    this.activeColor = const Color(0xFFFFFFFF),
    this.inactiveColor = const Color(0x66FFFFFF),
    this.borderColor,
    this.borderWidth = 1,
    this.radius = 6,
    this.spacing = 24,
    this.halo,
    this.haloPadding = const EdgeInsets.all(8),
    this.animated = false,
  }) : assert(radius > 0),
       assert(spacing >= 0),
       assert(borderWidth >= 0);

  /// The colour of the dot for the current item.
  final Color activeColor;

  /// The colour of the other dots.
  final Color inactiveColor;

  /// The colour of a ring around every dot. `null` draws no ring.
  final Color? borderColor;

  /// The width of the ring.
  final double borderWidth;

  /// The radius of each dot.
  final double radius;

  /// The distance between the centres of neighbouring dots. It is also each
  /// dot's tap target along the row, so the default, 24, is the smallest
  /// target WCAG 2.2 allows (2.5.8).
  final double spacing;

  /// A box drawn behind the dots, such as a translucent pill. `null` draws
  /// none.
  final BoxDecoration? halo;

  /// The space between the [halo]'s edge and the dots.
  final EdgeInsetsGeometry haloPadding;

  /// For painters that support it, whether the active dot animates between
  /// items instead of switching when the carousel settles.
  final bool animated;

  @override
  bool operator ==(Object other) =>
      other is SlideIndicatorStyle &&
      other.activeColor == activeColor &&
      other.inactiveColor == inactiveColor &&
      other.borderColor == borderColor &&
      other.borderWidth == borderWidth &&
      other.radius == radius &&
      other.spacing == spacing &&
      other.halo == halo &&
      other.haloPadding == haloPadding &&
      other.animated == animated;

  @override
  int get hashCode => Object.hash(
    activeColor,
    inactiveColor,
    borderColor,
    borderWidth,
    radius,
    spacing,
    halo,
    haloPadding,
    animated,
  );
}
