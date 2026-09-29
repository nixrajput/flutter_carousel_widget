import 'package:flutter/widgets.dart';

import 'carousel_engine.dart';
import 'size_reporter.dart';

/// How a carousel sizes itself and its items: the one thing its two widgets
/// differ in.
@immutable
abstract class CarouselSizing {
  /// Lets subclasses be const.
  const CarouselSizing();

  /// Wraps the scrolling pages.
  Widget wrapViewport(BuildContext context, CarouselView view, Widget pages);

  /// Wraps one item inside its page.
  Widget wrapItem(
    Widget child, {
    required int index,
    required AlignmentGeometry? alignment,
    required CarouselView view,
  });
}

/// A fixed height, or an aspect ratio when there is none.
class FixedSizing extends CarouselSizing {
  /// Creates fixed sizing.
  const FixedSizing({required this.height, required this.aspectRatio});

  /// The carousel's height; wins over [aspectRatio].
  final double? height;

  /// Width over height, used when [height] is `null`.
  final double aspectRatio;

  @override
  Widget wrapViewport(BuildContext context, CarouselView view, Widget pages) {
    final height = this.height;
    return height != null
        ? SizedBox(height: height, child: pages)
        : AspectRatio(aspectRatio: aspectRatio, child: pages);
  }

  @override
  Widget wrapItem(
    Widget child, {
    required int index,
    required AlignmentGeometry? alignment,
    required CarouselView view,
  }) => alignment == null ? child : Align(alignment: alignment, child: child);
}

/// The measured cross-axis size of each item, by index.
class PageSizes extends ChangeNotifier {
  final _sizes = <int, double>{};

  /// The size measured for [index], if any.
  double? operator [](int index) => _sizes[index];

  /// Records [size] for [index].
  void report(int index, double size) {
    if (_sizes[index] == size) return;
    _sizes[index] = size;
    notifyListeners();
  }

  /// The extent last applied to the viewport: the fallback when nothing that
  /// is showing has been measured yet.
  double lastExtent = 0;

  /// Forgets items at or past [itemCount].
  void retain(int itemCount) =>
      _sizes.removeWhere((index, _) => index >= itemCount);
}

/// Sizes the carousel to its content, interpolating between neighbouring
/// items while it moves.
class ContentSizing extends CarouselSizing {
  /// Creates content sizing.
  const ContentSizing({this.estimatedPageSize});

  /// The size of an item not yet measured. `null` falls back to the current
  /// item's size, or 0 before anything is measured.
  final double? estimatedPageSize;

  @override
  Widget wrapViewport(BuildContext context, CarouselView view, Widget pages) =>
      ListenableBuilder(
        listenable: Listenable.merge([view.scroll, view.sizes]),
        builder: (context, child) {
          final extent = _extent(view);
          view.sizes.lastExtent = extent;
          return view.axis == Axis.horizontal
              ? SizedBox(height: extent, child: child)
              : SizedBox(width: extent, child: child);
        },
        child: pages,
      );

  double _extent(CarouselView view) {
    final n = view.itemCount;
    if (n == 0) return 0;
    final p = view.position;
    final from = p.floor() % n;
    final to = view.infinite ? (from + 1) % n : (from + 1).clamp(0, n - 1);
    final t = p - p.floor();
    final a = _size(view, from);
    return a + (_size(view, to) - a) * t;
  }

  double _size(CarouselView view, int index) =>
      view.sizes[index] ??
      estimatedPageSize ??
      view.sizes[view.index] ??
      view.sizes.lastExtent;

  @override
  Widget wrapItem(
    Widget child, {
    required int index,
    required AlignmentGeometry? alignment,
    required CarouselView view,
  }) {
    final horizontal = view.axis == Axis.horizontal;
    // Only the measured axis is loosened; the other keeps the page's tight
    // extent, so a small image scales up to the page width (#29).
    return OverflowBox(
      alignment: alignment ?? Alignment.topCenter,
      minHeight: horizontal ? 0 : null,
      maxHeight: horizontal ? double.infinity : null,
      minWidth: horizontal ? null : 0,
      maxWidth: horizontal ? null : double.infinity,
      child: SizeReporter(
        slot: index,
        onSize: (size) =>
            view.sizes.report(index, horizontal ? size.height : size.width),
        child: child,
      ),
    );
  }
}
