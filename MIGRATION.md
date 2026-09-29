# Migrating from 3.x to 4.0

4.0 is a rewrite on Flutter 3.47 and `widgets.dart` alone. The options objects become constructor parameters, the two controllers become one, and the enlarged centre page becomes one of ten effects. This page maps every 3.x symbol, then lists every behaviour that changed.

## Symbols

| 3.x | 4.0 |
| --- | --- |
| `options: FlutterCarouselOptions(...)` / `ExpandableCarouselOptions(...)` | constructor parameters |
| `height`, `aspectRatio`, `estimatedPageSize`, `initialPage`, `viewportFraction`, `reverse`, `scrollDirection`, `onPageChanged`, `physics`, `pageSnapping`, `padEnds`, `clipBehavior`, `scrollBehavior`, `dragStartBehavior`, `allowImplicitScrolling`, `restorationId`, `keepPage`, `pageViewKey` | the same names, as constructor parameters |
| `enableInfiniteScroll` | `infinite` |
| `enlargeCenterPage`, `enlargeFactor`, `enlargeStrategy` | `effect: CarouselEffect.enlarge(factor:, strategy:)` |
| `autoPlay`, `autoPlayInterval`, `autoPlayAnimationDuration`, `autoPlayCurve`, `pauseAutoPlayOnTouch`, `pauseAutoPlayOnManualNavigate`, `pauseAutoPlayInFiniteScroll` | `autoPlay: CarouselAutoPlay(interval:, duration:, curve:, pauseOnTouch:, restartOnInteraction:, stopAtEnd:)` |
| `showIndicator`, `floatingIndicator`, `indicatorMargin`, `slideIndicator`, `SlideIndicatorOptions` | `indicator: CarouselIndicator(painter:, placement:, margin:)` / `null`, `SlideIndicatorStyle` |
| `CircularWaveSlideIndicator` | `CircularWaveIndicator` |
| `disableCenter: true` | `itemAlignment: null` |
| `FlutterCarouselController`, `ExpandableCarouselController`, both `Impl`s | `FlutterCarouselController` |
| `ready` / `onReady` | `isAttached` / listen to the controller |
| controller methods returning `void` | returning `Future<void>` |
| `ExtendedWidgetBuilder (context, index, realIndex)` | `CarouselItemBuilder (context, index, pageIndex)`; the third argument was always the page index |
| `onScrolled(rawPage)` | `onScrolled(itemPosition)` |
| `FlutterCarouselState`, `ExpandableCarouselState` | removed (internal) |
| default physics `BouncingScrollPhysics` | platform page physics via `CarouselSnapPhysics` |
| 300 ms `easeInCubic` | 500 ms `easeInOutCubicEmphasized` |
| drag devices `{touch, mouse}` | all but `unknown` |
| imports `material.dart` | `widgets.dart` only |
| `CenterPageEnlargeStrategy` (`scale`, `height`) | `CarouselEnlargeStrategy` (`scale`, `height`, and the new `zoom`) |
| `SlideIndicatorOptions(currentIndicatorColor:, indicatorBackgroundColor:, indicatorBorderColor:, indicatorBorderWidth:, indicatorRadius:, itemSpacing:)` | `SlideIndicatorStyle(activeColor:, inactiveColor:, borderColor:, borderWidth:, radius:, spacing:)`; `spacing` is centre to centre, see below |
| `enableHalo`, `haloDecoration`, `haloPadding` | `halo` (a `BoxDecoration`; `null` draws none), `haloPadding` |
| `enableAnimation` | `animated` |
| `SlideIndicatorOptions.alignment`, `padding` | `CarouselIndicator(alignment:, margin:)` |
| `SlideIndicator.build(currentPage, pageDelta, itemCount)`, returning a widget | `SlideIndicator.paint(canvas, size, geometry)`, a painter; see below |

A 3.x carousel becomes:

```dart
// 3.x
FlutterCarousel(
  items: items,
  options: FlutterCarouselOptions(
    height: 240,
    enableInfiniteScroll: true,
    enlargeCenterPage: true,
    enlargeFactor: 0.3,
    autoPlay: true,
    autoPlayInterval: const Duration(seconds: 4),
    showIndicator: true,
    floatingIndicator: false,
    slideIndicator: CircularWaveSlideIndicator(),
  ),
);

// 4.0
FlutterCarousel(
  items: items,
  height: 240,
  infinite: true,
  effect: const CarouselEffect.enlarge(factor: 0.3),
  autoPlay: const CarouselAutoPlay(interval: Duration(seconds: 4)),
  indicator: const CarouselIndicator(
    painter: CircularWaveIndicator(),
    placement: CarouselIndicatorPlacement.below,
  ),
);
```

## Behaviour changes

**The page-change reason gains `keyboard`**, for arrow, Home and End keys, and `controller` now also covers the app changing the items so that the current one moved. A `switch` over the reason needs the new case:

```dart
// 3.x
switch (reason) {
  case CarouselPageChangedReason.timed:
  case CarouselPageChangedReason.manual:
  case CarouselPageChangedReason.controller:
}

// 4.0
switch (reason) {
  case CarouselPageChangedReason.timed:
  case CarouselPageChangedReason.manual:
  case CarouselPageChangedReason.controller:
  case CarouselPageChangedReason.keyboard:
}
```

**Dot `spacing` is centre to centre.** 3.x's `itemSpacing` was the width each dot got, and the dots were spread across that width, so five dots of radius 6 at `itemSpacing: 20` sat 22 apart. For the same look, use `(itemCount * itemSpacing - 2 * radius) / (itemCount - 1)`:

```dart
// 3.x
SlideIndicatorOptions(itemSpacing: 20, indicatorRadius: 6)

// 4.0, five items
SlideIndicatorStyle(spacing: 22, radius: 6)
```

**A `below` indicator sits outside `height`.** In 3.x, `floatingIndicator: false` took the dots' room out of the carousel's height; in 4.0, `height` is the items' height and the dots add to it:

```dart
// 3.x: 200 in total, the items a little less
FlutterCarousel(items: items, options: FlutterCarouselOptions(height: 200, floatingIndicator: false))

// 4.0: items 200 tall, the dots below them
FlutterCarousel(items: items, height: 200, indicator: const CarouselIndicator(placement: CarouselIndicatorPlacement.below))
```

**`onScrolled` reports the item position**, in `[0, itemCount)`, rather than the raw `PageView` page, which in an infinite carousel is a large virtual number:

```dart
// 3.x: 50002.5 in an infinite carousel of 5 items
onScrolled: (rawPage) => print(rawPage),

// 4.0: 2.5, halfway between the third and fourth items
onScrolled: (position) => print(position),
```

**The builder's third argument is the page index.** 3.x called it `realIndex`; it was always the underlying page, and 4.0 names it so:

```dart
// 3.x
FlutterCarousel.builder(itemCount: 5, itemBuilder: (context, index, realIndex) => Hero(tag: realIndex, child: items[index]), options: FlutterCarouselOptions())

// 4.0
FlutterCarousel.builder(itemCount: 5, itemBuilder: (context, index, pageIndex) => Hero(tag: pageIndex, child: items[index]))
```

**Default physics and motion changed.** 3.x used `BouncingScrollPhysics` on every platform; autoplay moved in 300 ms on `Curves.easeInCubic`, and controller moves in 300 ms on `Curves.linear`. 4.0 uses the platform's own physics through `CarouselSnapPhysics`, and both autoplay and controller moves take 500 ms on `Curves.easeInOutCubicEmphasized`. Every pointer kind but `unknown` drags the pages, trackpads included, where 3.x allowed only touch and mouse. Pass the old values to keep the old feel:

```dart
// 4.0 with 3.x's feel
FlutterCarousel(
  items: items,
  physics: const BouncingScrollPhysics(),
  autoPlay: const CarouselAutoPlay(
    duration: Duration(milliseconds: 300),
    curve: Curves.easeInCubic,
  ),
);
```

**`CircularWaveSlideIndicator` is renamed** `CircularWaveIndicator`, to match the other three painters:

```dart
// 3.x
slideIndicator: CircularWaveSlideIndicator(),

// 4.0
indicator: const CarouselIndicator(painter: CircularWaveIndicator()),
```

**A custom indicator paints instead of building a widget.** 3.x called `build(currentPage, pageDelta, itemCount)` and placed the widget it returned. In 4.0, extend `SlideIndicator` and implement `paint`: `geometry.position` is the fractional position (3.x's `currentPage + pageDelta`), and `dotCenter` and `size` place the dots, mirrored for right-to-left text. For an indicator made of widgets, hide the built-in one and build yours beside the carousel from the controller, which notifies when the item changes, or from `onScrolled` for the position:

```dart
// 3.x
class Dots extends SlideIndicator {
  @override
  Widget build(int currentPage, double pageDelta, int itemCount) => MyDots(currentPage);
}

// 4.0: a painter
class Dots extends SlideIndicator {
  const Dots();

  @override
  void paint(Canvas canvas, Size size, SlideIndicatorGeometry geometry) {
    // Draw with geometry.position, geometry.nearest and dotCenter(i, geometry).
  }
}

// 4.0: widgets, from the controller
Column(children: [
  FlutterCarousel(items: items, controller: controller, indicator: null),
  ListenableBuilder(
    listenable: controller,
    builder: (context, _) => MyDots(controller.isAttached ? controller.index : 0),
  ),
]);
```

**There is no Material import.** 3.x imported `material.dart` for colours, so a Cupertino or plain `WidgetsApp` app pulled in Material through it. 4.0 imports `widgets.dart` only; if your code relied on this package to bring Material in, import it yourself:

```dart
// 4.0
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
```

**Controller methods return futures**, which complete when the move ends, and `ready` and `onReady` are gone: `isAttached` says whether a carousel is using the controller, and listening to it tells you when that changes.

```dart
// 3.x
await controller.onReady;
controller.nextPage();

// 4.0
if (controller.isAttached) await controller.nextPage();
```
