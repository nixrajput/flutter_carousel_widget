import 'package:flutter/material.dart' hide CarouselController;

/// Abstraction used as a contract for building a slide indicator widget.
///
/// See also:
///
///  * [CircularSlideIndicator]
///  * [CircularStaticIndicator]
///  * [CircularWaveSlideIndicator]
///  * [SequentialFillIndicator]
abstract class SlideIndicator {
  /// Builder method returning the slide indicator widget.
  /// The method accepts the [currentPage] on which the carousel currently
  /// resides, the [pageDelta] or the difference between the current page and
  /// its resting position and [itemCount] which is the total number of items.
  Widget build(int currentPage, double pageDelta, int itemCount);
}
