import 'package:flutter/widgets.dart';

/// Builds the item at [index], in `[0, itemCount)`.
///
/// [pageIndex] is the underlying page. In an infinite carousel it is unique
/// for each copy of an item on screen, which is what a `Hero` tag needs.
typedef CarouselItemBuilder = Widget Function(
  BuildContext context,
  int index,
  int pageIndex,
);

/// Called when the current item changes, with what moved it. Like
/// `PageView.onPageChanged`, it fires as the rounded position crosses to
/// another item, so a long move reports the items it passes.
typedef CarouselPageChanged = void Function(
  int index,
  CarouselPageChangedReason reason,
);

/// What moved a carousel to a new item.
enum CarouselPageChangedReason {
  /// An autoplay tick.
  timed,

  /// The user: a drag, a pointer or trackpad scroll, a screen-reader gesture,
  /// or a tap on an indicator dot.
  manual,

  /// A `FlutterCarouselController` call, or the app changing the items so
  /// that the current one moved.
  controller,

  /// A key press while the carousel has focus.
  keyboard,
}

/// Where the first and last items sit in a finite carousel.
enum CarouselEdgeAlignment {
  /// Every item, the first and last included, settles in the middle.
  center,

  /// The first item settles against the leading edge and the last against
  /// the trailing edge; the items between settle in the middle. It needs a
  /// `viewportFraction` above 1/3: narrower pages settle centred.
  flush,
}
