import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

import 'circular_slide_indicator.dart';
import 'slide_indicator.dart';

/// Where a carousel's indicator sits.
enum CarouselIndicatorPlacement {
  /// Over the items, placed by the alignment.
  overlay,

  /// Outside the items: below a horizontal carousel, and beside a vertical
  /// one at its trailing edge.
  below,
}

/// A carousel's page indicator: its painter, placement and behaviour. It shows
/// only when the carousel has two or more items.
@immutable
class CarouselIndicator {
  /// Creates an indicator.
  const CarouselIndicator({
    this.painter = const CircularSlideIndicator(),
    this.placement = CarouselIndicatorPlacement.overlay,
    this.alignment,
    this.margin = const EdgeInsets.all(8),
    this.tapToNavigate = true,
  });

  /// What the dots look like.
  final SlideIndicator painter;

  /// Over the items, or below them.
  final CarouselIndicatorPlacement placement;

  /// Where the dots sit: within the items for [CarouselIndicatorPlacement.overlay],
  /// along the items' edge for [CarouselIndicatorPlacement.below]. `null` uses
  /// the bottom centre for a horizontal carousel and the middle of the
  /// trailing edge for a vertical one, where the dots run down the side.
  final AlignmentGeometry? alignment;

  /// Space around the dots.
  final EdgeInsetsGeometry margin;

  /// Whether tapping a dot moves to its item.
  final bool tapToNavigate;

  @override
  bool operator ==(Object other) =>
      other is CarouselIndicator &&
      other.painter == painter &&
      other.placement == placement &&
      other.alignment == alignment &&
      other.margin == margin &&
      other.tapToNavigate == tapToNavigate;

  @override
  int get hashCode =>
      Object.hash(painter, placement, alignment, margin, tapToNavigate);
}
