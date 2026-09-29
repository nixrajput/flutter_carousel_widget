import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

/// Where an item sits relative to the carousel's settled slot, for an effect.
@immutable
class CarouselItemPosition {
  /// Creates a position. The carousel creates these; tests may too.
  const CarouselItemPosition({
    required this.index,
    required this.itemCount,
    required this.offset,
    required this.axis,
    required this.textDirection,
    required this.reverse,
    required this.viewportFraction,
    required this.extent,
  });

  /// The item, in `[0, itemCount)`.
  final int index;

  /// How many items the carousel has.
  final int itemCount;

  /// The signed distance from the settled slot, in items and reading order:
  /// `0` when settled, `-1` one item before, `1` one item after. It changes
  /// continuously while the carousel moves.
  final double offset;

  /// The carousel's scroll axis.
  final Axis axis;

  /// The ambient text direction.
  final TextDirection textDirection;

  /// Whether the carousel lays its items out in reverse.
  final bool reverse;

  /// The share of the viewport each page takes.
  final double viewportFraction;

  /// The size of the page box the item sits in.
  final Size extent;

  /// [offset] in screen terms: positive is to the right for a horizontal
  /// carousel and downwards for a vertical one, whatever [textDirection] or
  /// [reverse] say.
  double get visualOffset {
    final flipped =
        (axis == Axis.horizontal && textDirection == TextDirection.rtl) !=
        reverse;
    return flipped ? -offset : offset;
  }

  /// The page's size along [axis].
  double get mainExtent =>
      axis == Axis.horizontal ? extent.width : extent.height;

  @override
  bool operator ==(Object other) =>
      other is CarouselItemPosition &&
      other.index == index &&
      other.itemCount == itemCount &&
      other.offset == offset &&
      other.axis == axis &&
      other.textDirection == textDirection &&
      other.reverse == reverse &&
      other.viewportFraction == viewportFraction &&
      other.extent == extent;

  @override
  int get hashCode => Object.hash(
    index,
    itemCount,
    offset,
    axis,
    textDirection,
    reverse,
    viewportFraction,
    extent,
  );
}
