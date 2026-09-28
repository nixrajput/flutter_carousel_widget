import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'auto_play/carousel_auto_play.dart';
import 'controller/flutter_carousel_controller.dart';
import 'effects/carousel_effect.dart';
import 'engine/carousel_config.dart';
import 'engine/carousel_engine.dart';
import 'engine/sizing.dart';
import 'indicators/carousel_indicator.dart';
import 'types.dart';

/// A carousel of items that share one size: a fixed [height], or an
/// [aspectRatio] of the available width.
///
/// For items that size themselves, use `ExpandableCarousel`.
class FlutterCarousel extends StatelessWidget {
  /// Creates a carousel of [items].
  const FlutterCarousel({
    super.key,
    required List<Widget> this.items,
    this.height,
    this.aspectRatio = 1.0,
    this.controller,
    this.initialPage = 0,
    this.viewportFraction = 0.8,
    this.infinite = false,
    this.reverse = false,
    this.scrollDirection = Axis.horizontal,
    this.autoPlay,
    this.effect = CarouselEffect.none,
    this.indicator = const CarouselIndicator(),
    this.onPageChanged,
    this.onScrolled,
    this.itemAlignment = Alignment.center,
    this.keepAlive = false,
    this.semanticLabel,
    this.semanticSlideLabel,
    this.keyboardNavigation = true,
    this.focusNode,
    this.autofocus = false,
    this.physics,
    this.pageSnapping = true,
    this.padEnds = true,
    this.edgeAlignment = CarouselEdgeAlignment.center,
    this.clipBehavior = Clip.antiAlias,
    this.scrollBehavior,
    this.dragStartBehavior = DragStartBehavior.start,
    this.allowImplicitScrolling = false,
    this.restorationId,
    this.keepPage = true,
    this.pageViewKey,
  }) : itemCount = null,
       itemBuilder = null,
       assert(height == null || height > 0),
       assert(aspectRatio > 0),
       assert(viewportFraction > 0 && viewportFraction <= 1),
       assert(initialPage >= 0);

  /// Creates a carousel that builds [itemCount] items on demand.
  const FlutterCarousel.builder({
    super.key,
    required int this.itemCount,
    required CarouselItemBuilder this.itemBuilder,
    this.height,
    this.aspectRatio = 1.0,
    this.controller,
    this.initialPage = 0,
    this.viewportFraction = 0.8,
    this.infinite = false,
    this.reverse = false,
    this.scrollDirection = Axis.horizontal,
    this.autoPlay,
    this.effect = CarouselEffect.none,
    this.indicator = const CarouselIndicator(),
    this.onPageChanged,
    this.onScrolled,
    this.itemAlignment = Alignment.center,
    this.keepAlive = false,
    this.semanticLabel,
    this.semanticSlideLabel,
    this.keyboardNavigation = true,
    this.focusNode,
    this.autofocus = false,
    this.physics,
    this.pageSnapping = true,
    this.padEnds = true,
    this.edgeAlignment = CarouselEdgeAlignment.center,
    this.clipBehavior = Clip.antiAlias,
    this.scrollBehavior,
    this.dragStartBehavior = DragStartBehavior.start,
    this.allowImplicitScrolling = false,
    this.restorationId,
    this.keepPage = true,
    this.pageViewKey,
  }) : items = null,
       assert(itemCount >= 0),
       assert(height == null || height > 0),
       assert(aspectRatio > 0),
       assert(viewportFraction > 0 && viewportFraction <= 1),
       assert(initialPage >= 0);

  /// The items, when built from a list. Items with keys keep their state when
  /// the list changes around them.
  final List<Widget>? items;

  /// How many items [itemBuilder] builds.
  final int? itemCount;

  /// Builds the items on demand.
  final CarouselItemBuilder? itemBuilder;

  /// The carousel's height. Wins over [aspectRatio].
  final double? height;

  /// The carousel's width over its height, used when [height] is `null`.
  final double aspectRatio;

  /// Drives the carousel and reports its state.
  final FlutterCarouselController? controller;

  /// The item shown first.
  final int initialPage;

  /// The share of the viewport each page takes; below 1 the neighbours peek in.
  final double viewportFraction;

  /// Whether the carousel loops past its last item to its first.
  final bool infinite;

  /// Whether the items run in reverse. Autoplay then moves backwards too.
  final bool reverse;

  /// The scroll axis.
  final Axis scrollDirection;

  /// Moves the carousel on by itself; `null` turns autoplay off.
  final CarouselAutoPlay? autoPlay;

  /// How items transform as they move.
  final CarouselEffect effect;

  /// The page indicator; `null` hides it. It shows only for two or more items.
  final CarouselIndicator? indicator;

  /// Called when the current item changes, with what moved it. Like
  /// `PageView.onPageChanged`, it fires as the rounded position crosses to
  /// another item, so a long move reports the items it passes.
  final CarouselPageChanged? onPageChanged;

  /// Called on every scroll frame with the fractional item position, in
  /// `[0, itemCount)`.
  final ValueChanged<double>? onScrolled;

  /// Aligns each item in its page; `null` passes the page's constraints
  /// through unchanged, which lets an image fill its page.
  final AlignmentGeometry? itemAlignment;

  /// Whether pages keep their state while scrolled out of view.
  final bool keepAlive;

  /// The carousel's label for screen readers. `null` uses "Carousel".
  final String? semanticLabel;

  /// Labels an item for screen readers. `null` uses "Slide 2 of 5".
  final String Function(int index, int count)? semanticSlideLabel;

  /// Whether the arrow, Home and End keys move the focused carousel.
  final bool keyboardNavigation;

  /// The carousel's focus node, for keyboard navigation.
  final FocusNode? focusNode;

  /// Whether the carousel takes focus when first built.
  final bool autofocus;

  /// How the pages respond to drags. `null` uses [CarouselSnapPhysics] over
  /// the platform's physics.
  final ScrollPhysics? physics;

  /// Whether a drag settles on a page.
  final bool pageSnapping;

  /// Whether the first and last pages can sit in the middle of the viewport.
  final bool padEnds;

  /// Where the first and last items settle; ignored when [infinite].
  /// [CarouselEdgeAlignment.flush] keeps middle items centred, which
  /// `padEnds: false` does not. It needs a [viewportFraction] above 1/3.
  final CarouselEdgeAlignment edgeAlignment;

  /// How the pages clip.
  final Clip clipBehavior;

  /// The scroll behavior. `null` lets every pointer kind drag, trackpads
  /// included, and hides scrollbars and overscroll indicators.
  final ScrollBehavior? scrollBehavior;

  /// When a drag starts.
  final DragStartBehavior dragStartBehavior;

  /// Whether the pages next to the current one are built for accessibility.
  final bool allowImplicitScrolling;

  /// Restores the scroll offset.
  final String? restorationId;

  /// Whether the page is saved in `PageStorage` and restored.
  final bool keepPage;

  /// The key of the underlying `PageView`, for `PageStorage`.
  final PageStorageKey<Object?>? pageViewKey;

  @override
  Widget build(BuildContext context) {
    final items = this.items;
    return CarouselEngine(
      config: CarouselConfig(
        controller: controller,
        initialPage: initialPage,
        viewportFraction: viewportFraction,
        infinite: infinite,
        reverse: reverse,
        scrollDirection: scrollDirection,
        autoPlay: autoPlay,
        effect: effect,
        indicator: indicator,
        onPageChanged: onPageChanged,
        onScrolled: onScrolled,
        itemAlignment: itemAlignment,
        keepAlive: keepAlive,
        semanticLabel: semanticLabel,
        semanticSlideLabel: semanticSlideLabel,
        keyboardNavigation: keyboardNavigation,
        focusNode: focusNode,
        autofocus: autofocus,
        physics: physics,
        pageSnapping: pageSnapping,
        padEnds: padEnds,
        edgeAlignment: edgeAlignment,
        clipBehavior: clipBehavior,
        scrollBehavior: scrollBehavior,
        dragStartBehavior: dragStartBehavior,
        allowImplicitScrolling: allowImplicitScrolling,
        restorationId: restorationId,
        keepPage: keepPage,
        pageViewKey: pageViewKey,
      ),
      sizing: FixedSizing(height: height, aspectRatio: aspectRatio),
      itemCount: items?.length ?? itemCount!,
      itemBuilder: items == null
          ? itemBuilder!
          : (context, index, page) => items[index],
      itemKeys: items != null && items.any((item) => item.key != null)
          ? [for (final item in items) item.key]
          : null,
    );
  }
}
