import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Where a carousel is, in the terms an indicator paints.
@immutable
class SlideIndicatorGeometry {
  /// Creates a geometry. The carousel creates these; tests may too.
  const SlideIndicatorGeometry({
    required this.itemCount,
    required this.position,
    required this.infinite,
    this.axis = Axis.horizontal,
    this.flipped = false,
  });

  /// How many dots to paint.
  final int itemCount;

  /// The carousel's fractional item position, in `[0, itemCount)`.
  final double position;

  /// Whether the carousel loops, so the active dot may wrap from last to
  /// first.
  final bool infinite;

  /// The axis the dots lie along.
  final Axis axis;

  /// Whether item 0 sits at the far end (right or bottom), as under RTL or
  /// `reverse`.
  final bool flipped;

  /// The dot nearest the position: the item `onPageChanged` reports.
  int get nearest => itemCount == 0 ? 0 : position.round() % itemCount;

  /// The dot the active one is leaving.
  int get from => itemCount == 0 ? 0 : position.floor().clamp(0, itemCount - 1);

  /// The dot the active one is moving towards: the next item, the first one
  /// when an infinite carousel wraps, or `null` past a finite one's last item.
  int? get to {
    final next = from + 1;
    if (next < itemCount) return next;
    return infinite && itemCount > 1 ? 0 : null;
  }

  /// How far the active dot has travelled towards [to], in `[0, 1)`.
  double get progress => position - position.floor();
}
