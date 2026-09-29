<p align="center">
  <img src="https://raw.githubusercontent.com/nixrajput/flutter_carousel_widget/master/assets/logo.svg" width="96" alt="flutter_carousel_widget" />
</p>

<h1 align="center">flutter_carousel_widget</h1>

<p align="center">Carousels that move the way you mean them to. Ten effects, lifecycle-aware autoplay, content-sized pages, and keyboard and screen-reader support, with no third-party dependencies.</p>

<p align="center">
  <a href="https://pub.dev/packages/flutter_carousel_widget"><img src="https://img.shields.io/pub/v/flutter_carousel_widget.svg?label=Version" alt="pub package" /></a>
  <a href="https://github.com/nixrajput/flutter_carousel_widget/actions/workflows/ci.yml"><img src="https://img.shields.io/github/actions/workflow/status/nixrajput/flutter_carousel_widget/ci.yml?branch=master&label=CI" alt="CI" /></a>
  <a href="https://pub.dev/packages/flutter_carousel_widget/score"><img src="https://img.shields.io/pub/likes/flutter_carousel_widget?label=Likes" alt="pub likes" /></a>
  <a href="https://pub.dev/packages/flutter_carousel_widget/score"><img src="https://img.shields.io/pub/points/flutter_carousel_widget?label=Points" alt="pub points" /></a>
  <a href="https://github.com/nixrajput/flutter_carousel_widget/graphs/contributors"><img src="https://img.shields.io/github/contributors/nixrajput/flutter_carousel_widget?label=Contributors" alt="contributors" /></a>
  <a href="https://github.com/nixrajput/flutter_carousel_widget/blob/master/LICENSE"><img src="https://img.shields.io/github/license/nixrajput/flutter_carousel_widget?label=Licence" alt="licence" /></a>
</p>

<p align="center">
  <b>10 effects</b> &nbsp;·&nbsp; <b>208 tests</b> &nbsp;·&nbsp; <b>6 platforms</b> &nbsp;·&nbsp; <b>0 third-party dependencies</b> &nbsp;·&nbsp; <b>keyboard and screen-reader ready</b>
</p>

<p align="center">
  <sub>There is no benchmark: a carousel's speed is Flutter's <code>PageView</code>. The effects, tests and dependencies are checked by <code>test/readme_test.dart</code>, and the platforms by pub.dev's analysis.</sub>
</p>

<p align="center">
  <a href="https://nixrajput.github.io/flutter_carousel_widget">Live demo</a> &nbsp;·&nbsp;
  <a href="#quick-start">Quick start</a> &nbsp;·&nbsp;
  <a href="#effects">Effects</a> &nbsp;·&nbsp;
  <a href="#autoplay">Autoplay</a> &nbsp;·&nbsp;
  <a href="#keyboard-and-accessibility">Accessibility</a> &nbsp;·&nbsp;
  <a href="https://github.com/nixrajput/flutter_carousel_widget/blob/master/MIGRATION.md">Migrating from 3.x</a> &nbsp;·&nbsp;
  <a href="https://pub.dev/documentation/flutter_carousel_widget/latest/">API reference</a>
</p>

## Table of contents

- [Table of contents](#table-of-contents)
- [Overview](#overview)
- [Demo](#demo)
- [Quick start](#quick-start)
  - [Prerequisites](#prerequisites)
  - [Install](#install)
  - [Your first carousel](#your-first-carousel)
- [Sizing](#sizing)
- [Controller](#controller)
- [Autoplay](#autoplay)
- [Effects](#effects)
- [Indicators](#indicators)
- [Keyboard and accessibility](#keyboard-and-accessibility)
- [Edges and infinite scrolling](#edges-and-infinite-scrolling)
- [Before and after](#before-and-after)
- [Is this for you](#is-this-for-you)
- [Compared to](#compared-to)
- [FAQ](#faq)
- [Migrating from 3.x](#migrating-from-3x)
- [Contributing](#contributing)
- [Contributors](#contributors)
- [License](#license)
- [Support the project](#support-the-project)
- [Connect](#connect)

## Overview

flutter_carousel_widget shows a row (or column) of items one page at a time, and moves between them by drag, key, screen-reader gesture, controller call or autoplay. `FlutterCarousel` is for items that share one size; `ExpandableCarousel` sizes itself to each item and follows the drag between their heights. Both run on one engine, take their options as constructor parameters, share one `FlutterCarouselController`, and report exactly what moved them: 4.0 is a rewrite, and [MIGRATION.md](https://github.com/nixrajput/flutter_carousel_widget/blob/master/MIGRATION.md) maps every 3.x symbol.

## Demo

Try every option in the [live web demo](https://nixrajput.github.io/flutter_carousel_widget): the effects and their strength, autoplay, the four indicators, keyboard navigation, right-to-left and the vertical axis, beside a pinned preview. It is the [example app](https://github.com/nixrajput/flutter_carousel_widget/blob/master/example/README.md) built for the web; the same app runs on Android, iOS, macOS, Windows and Linux.

## Quick start

### Prerequisites

- Flutter 3.47 or newer (Dart `^3.13.0`).
- No other dependency. The package imports `widgets.dart` only, so it works in a Material app, a Cupertino app or neither.

### Install

```sh
flutter pub add flutter_carousel_widget
```

### Your first carousel

```dart
FlutterCarousel(
  height: 200,
  itemAlignment: null,
  items: [for (final url in urls) Image.network(url, fit: BoxFit.cover)],
);
```

`itemAlignment: null` hands each image its page's full size, so `BoxFit.cover` fills the page; the default centres smaller items instead (see [Sizing](#sizing)). Items are built lazily. Use `FlutterCarousel.builder` with `itemCount` and `itemBuilder` for long or generated lists; the builder's third argument is the underlying page, unique for each copy of an item in an infinite carousel, which is what a `Hero` tag needs.

## Sizing

`FlutterCarousel` takes a `height`, or an `aspectRatio` of the available width (1.0 by default) when there is none. `ExpandableCarousel` has neither: each item sizes itself, and the carousel's height moves between neighbouring items' heights as it scrolls.

```dart
ExpandableCarousel(
  items: [for (final review in reviews) ReviewCard(review)],
);
```

An item the carousel has not measured yet counts as `estimatedPageSize` tall, or as tall as the current item when that is `null`. Items report their size from layout, so there is no measuring pass on builds where nothing changed. A vertical `ExpandableCarousel` follows its items' widths instead.

In an `ExpandableCarousel` every page keeps the carousel's full width, so a small image scales up to fill it. A `FlutterCarousel` centres each item with `itemAlignment`, which gives it loose constraints; pass `itemAlignment: null` to hand the page's tight constraints through, or give the image a `fit` and a size.

## Controller

```dart
final controller = FlutterCarouselController();

// In build:
FlutterCarousel(controller: controller, items: items);

// Any time after the first frame:
await controller.nextPage();
final showing = controller.index;
```

The controller attaches when its carousel is first built and detaches when it is disposed; `isAttached` says which. Reading `index` or calling a method while detached throws a `StateError` that says so, rather than failing somewhere inside the carousel.

`index` is the current item, rounded the way `PageView` rounds, and `position` is the fractional item position: `2.5` is halfway between the third and fourth items. The controller is a `ChangeNotifier` that notifies when the item changes, when a carousel attaches or detaches, and when autoplay starts or stops.

`nextPage`, `previousPage` and `animateToPage` take an optional `duration` and `curve` and return a future that completes when the move ends. `animateToPage` takes the short way round an infinite carousel, and `jumpToPage` moves without animating. Both throw a `RangeError` for an index outside the items.

## Autoplay

```dart
FlutterCarousel(
  items: items,
  autoPlay: CarouselAutoPlay(
    interval: const Duration(seconds: 4),
    intervalFor: (index) => index == 0
        ? const Duration(seconds: 8)
        : const Duration(seconds: 4),
  ),
);
```

`interval` is how long each item stays (5 seconds by default), and `intervalFor` gives an item its own. A move takes 500 ms on `Curves.easeInOutCubicEmphasized` unless `duration` and `curve` say otherwise. The interval starts again whenever the carousel settles, so a parent rebuild never restarts it.

Autoplay holds while a finger or pressed pointer is on the carousel, while a mouse hovers over it, and while keyboard focus is inside it; `pauseOnTouch`, `pauseOnHover` and `pauseOnFocus` turn those off. It always holds while another route covers the carousel, while the app is not in the foreground (on the web and desktop, that includes its window losing focus), while the carousel sits in an inactive tab (`TickerMode` off) and while the platform asks for reduced motion.

`controller.stopAutoPlay()` stops it until `startAutoPlay()`, through touches and rebuilds, which is the pause control [WCAG 2.2.2](https://www.w3.org/WAI/WCAG22/Understanding/pause-stop-hide.html) asks moving content to have. A finite carousel rewinds from its last item to its first, or stops there with `stopAtEnd: true`; with `reverse: true` it runs backwards.

## Effects

| Preset                     | What it does                                                                                                                    |
| -------------------------- | ------------------------------------------------------------------------------------------------------------------------------- |
| `CarouselEffect.enlarge`   | Keeps the centre item full size and shrinks its neighbours, by scale, height or towards the centre (`CarouselEnlargeStrategy`). |
| `CarouselEffect.fade`      | Fades items as they leave the centre, down to `minOpacity`.                                                                     |
| `CarouselEffect.parallax`  | Moves each item's content slower than its page, so the picture seems to sit behind it.                                          |
| `CarouselEffect.depth`     | The next item waits small and faded, and grows in as the current one slides away.                                               |
| `CarouselEffect.zoomOut`   | Neighbours shrink and dim.                                                                                                      |
| `CarouselEffect.stack`     | The incoming item slides over the current one, which waits behind, set back.                                                    |
| `CarouselEffect.coverflow` | Neighbours turn to face the centre, in perspective.                                                                             |
| `CarouselEffect.cube`      | Items are the faces of a turning cube.                                                                                          |
| `CarouselEffect.flip`      | Items flip over in place, like a card.                                                                                          |
| `CarouselEffect.rotate`    | Neighbours tilt about an origin, like cards on a wheel.                                                                         |

Effects compose with `then`, which applies the second around the first:

```dart
FlutterCarousel(
  items: items,
  effect: const CarouselEffect.coverflow().then(const CarouselEffect.fade()),
);
```

`CarouselEffect.builder` takes any function of the item's position:

```dart
FlutterCarousel(
  items: items,
  effect: CarouselEffect.builder(
    (context, position, child) => Opacity(
      opacity: 1 - position.offset.abs().clamp(0.0, 1.0) * 0.5,
      child: child,
    ),
  ),
);
```

`position.offset` is the item's distance from its settled slot in reading order: `0` when settled, `1` one item after. `position.visualOffset` is the same distance on screen, positive to the right or downwards whatever the text direction or `reverse` say, which is what a transform needs to mirror correctly.

Effects never replace your widget, so an item's state survives it crossing the centre, and only the effect's wrapper rebuilds while the carousel moves. With no effect, items do not rebuild at all during a drag. Page snapping uses the platform's physics with a tunable spring: pass `physics: CarouselSnapPhysics(snapSpring: ...)`.

## Indicators

Four painters draw the dots: `CircularSlideIndicator` (the default) slides the active dot with the drag, `CircularStaticIndicator` fills the current one, `CircularWaveIndicator` shrinks it midway, and `SequentialFillIndicator` fills from the first dot up to the position like a progress bar. `SlideIndicatorStyle` sets their colours, radius, spacing (centre to centre), a ring, a halo behind them, and whether the static and fill painters animate.

```dart
FlutterCarousel(
  items: items,
  indicator: const CarouselIndicator(
    painter: CircularWaveIndicator(
      style: SlideIndicatorStyle(activeColor: Color(0xFF9B8CFF)),
    ),
    placement: CarouselIndicatorPlacement.below,
  ),
);
```

`overlay` places the dots over the items by `alignment`, which defaults to the bottom centre, or the middle of the trailing edge for a vertical carousel, where the dots run down the side. `below` puts them outside the items: under a horizontal carousel, outside its height, and beside a vertical one at its trailing edge. The dots repaint from the scroll position without rebuilding any widget, follow the drag with no frame of lag, and mirror under right-to-left text and `reverse`. Tapping a dot moves to its item unless `tapToNavigate` is off, and each dot is a labelled button for screen readers. However small a dot is drawn, its target is one `spacing` wide (24 pixels by default, the smallest WCAG 2.2 allows) and 48 pixels tall, growing towards the items so none of it falls off the carousel's edge. Pass `indicator: null` to hide them; they never show for fewer than two items. Extend `SlideIndicator` for a look of your own.

## Keyboard and accessibility

A focused carousel moves with the arrow keys, and with Home and End to the first and last items. The arrow pointing at the next item moves to it, so the keys mirror under right-to-left text, `reverse` and the vertical axis. The keys act only while the carousel itself has focus, so keys typed into a field inside a slide stay with the field. `keyboardNavigation`, `focusNode` and `autofocus` control it; the carousel draws no focus ring, so the app can draw one that matches its design.

Screen readers read the carousel as "Carousel" with the value "Slide 2 of 5", and move it with their increase and decrease gestures. When the platform reports accessible navigation, a move by the user or the app is announced once, on the item it settles on; autoplay is never announced, because that would be noise. Under reduced motion, moves jump instead of animating and autoplay does not run.

The labels are yours to translate:

```dart
FlutterCarousel(
  items: items,
  semanticLabel: 'Featured products',
  semanticSlideLabel: (index, count) => 'Product ${index + 1} of $count',
);
```

## Edges and infinite scrolling

`infinite: true` loops past the last item to the first, in both directions. A finite carousel with `padEnds: true`, the default, lets the first and last items settle in the middle; `padEnds: false` pulls them to the edges but shifts every item off centre.

`edgeAlignment: CarouselEdgeAlignment.flush` settles the first item against the leading edge and the last against the trailing edge, while the items between stay centred:

```dart
FlutterCarousel(
  items: items,
  viewportFraction: 0.8,
  edgeAlignment: CarouselEdgeAlignment.flush,
);
```

The index and position follow the clamped settle offsets, so they stay right for any `viewportFraction` above one third. Narrower pages settle centred, because several items would share the leading edge's offset. It is ignored when `infinite` is on.

## Before and after

In 3.x, options lived in a separate object and the enlarged centre page was a flag:

```dart
// 3.x
FlutterCarousel(
  items: items,
  options: FlutterCarouselOptions(
    height: 240,
    enlargeCenterPage: true,
    autoPlay: true,
    autoPlayInterval: const Duration(seconds: 4),
    slideIndicator: CircularWaveSlideIndicator(),
    onPageChanged: (index, reason) => setState(() => current = index),
  ),
);
```

In 4.0, the options are constructor parameters, and the enlarged centre is one effect among ten:

```dart
FlutterCarousel(
  items: items,
  height: 240,
  effect: const CarouselEffect.enlarge(),
  autoPlay: const CarouselAutoPlay(interval: Duration(seconds: 4)),
  indicator: const CarouselIndicator(painter: CircularWaveIndicator()),
  onPageChanged: (index, reason) => setState(() => current = index),
);
```

## Is this for you

Use it for image galleries, product and onboarding carousels, card decks and featured-content rows, in any Flutter app on any platform. It fits particularly well when the carousel has to be usable with a keyboard or a screen reader, when items have different heights, or when autoplay must behave around routes, tabs and the app's lifecycle.

**Skip it if** your items need different widths in one view; Material's [`CarouselView.weighted`](https://api.flutter.dev/flutter/material/CarouselView/CarouselView.weighted.html) lays those out. Skip it too if you need the carousel as a sliver inside a `CustomScrollView`, which this package does not offer.

## Compared to

**[`carousel_slider`](https://pub.dev/packages/carousel_slider)** is the most used carousel on pub.dev. It has an enlarged centre page and autoplay but no effects hook, keyboard navigation or screen-reader semantics, and its maintainers have asked for help ([#289](https://github.com/serenader2014/flutter_carousel_slider/issues/289)).

**[`carousel_slider_x`](https://pub.dev/packages/carousel_slider_x)** is a maintained fork on `widgets.dart` alone. It removed the page-change reason and the pause options on purpose, where this package makes both exact.

**[`card_swiper`](https://pub.dev/packages/card_swiper)** offers a page transformer hook and stack and tinder layouts. Its last release was in 2023.

**Material's [`CarouselView`](https://api.flutter.dev/flutter/material/CarouselView-class.html)** lays out weighted, variable-width items and ships with Flutter. It has no autoplay, indicators, keyboard shortcuts or carousel semantics of its own, and its controller is named `CarouselController`.

**This package** is the carousel with the accessibility built in: keyboard navigation, screen-reader semantics and announcements, and an autoplay that pauses for touch, hover, focus, routes, tabs, the app's lifecycle and reduced motion, with ten composable effects and content sizing on top.

## FAQ

**Why not Material's `CarouselView`?**
Use it if you want weighted layouts in a Material app. This package works without Material, and adds autoplay, indicators, effects, content sizing and keyboard and screen-reader support.

**What happened to `CarouselController`?**
Flutter's Material library added a `CarouselController` of its own, so 2.3 renamed this package's ([#46](https://github.com/nixrajput/flutter_carousel_widget/issues/46)). 4.0 has one controller for both widgets, `FlutterCarouselController`, and imports no Material, so the two never meet inside this package.

**How do I keep an item's state, such as a `TextField` or a playing video?**
Give each item a key: keyed items keep their state when the list changes around them. `keepAlive: true` keeps a page's state while it is scrolled out of view.

**Why is `ExpandableCarousel` slower than `FlutterCarousel`?**
It lays out each item at its own size and resizes the viewport on every scroll frame; `FlutterCarousel` gives every page one fixed size. Prefer `FlutterCarousel` when the items share a size.

**What do the numbers in the header mean?**
They are the things this package controls and can check: how many effects it ships, how many tests pin its behaviour down, how many platforms pub.dev confirms it supports, and that it depends on nothing but Flutter. A carousel's speed is `PageView`'s, so there is no benchmark.

## Migrating from 3.x

4.0 replaces the options objects with constructor parameters, merges the two controllers into `FlutterCarouselController`, turns `enlargeCenterPage` into `CarouselEffect.enlarge`, and requires Flutter 3.47. [MIGRATION.md](https://github.com/nixrajput/flutter_carousel_widget/blob/master/MIGRATION.md) maps every 3.x symbol and lists every behaviour that changed.

## Contributing

Contributions are welcome. Fork, branch and open a pull request - see [CONTRIBUTING.md](https://github.com/nixrajput/flutter_carousel_widget/blob/master/CONTRIBUTING.md) for the checks a PR has to pass, and note that every PR must bump the version in `pubspec.yaml` and add a matching `CHANGELOG.md` entry. Bugs and ideas go to [Issues](https://github.com/nixrajput/flutter_carousel_widget/issues), questions to [Discussions](https://github.com/nixrajput/flutter_carousel_widget/discussions), and vulnerabilities follow [SECURITY.md](https://github.com/nixrajput/flutter_carousel_widget/blob/master/SECURITY.md).

## Contributors

Thanks to everyone who has contributed to flutter_carousel_widget.

<a href="https://github.com/nixrajput/flutter_carousel_widget/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=nixrajput/flutter_carousel_widget" alt="Contributors" />
</a>

## License

MIT. See [LICENSE](https://github.com/nixrajput/flutter_carousel_widget/blob/master/LICENSE).

## Support the project

<div align="center">

flutter_carousel_widget is MIT licensed and free to use, always. If it saves you building a carousel from scratch, sponsorship is welcome.

<br />

<a href="https://github.com/sponsors/nixrajput">
  <img src="https://img.shields.io/badge/Sponsor_on_GitHub-EA4AAA?style=for-the-badge&logo=githubsponsors&logoColor=white" alt="GitHub Sponsors" />
</a>
<a href="https://ko-fi.com/nixrajput">
  <img src="https://img.shields.io/badge/Ko--fi-FF5E5B?style=for-the-badge&logo=kofi&logoColor=white" alt="Ko-fi" />
</a>
<a href="https://www.buymeacoffee.com/nixrajput">
  <img src="https://img.shields.io/badge/Buy_Me_a_Coffee-FFDD00?style=for-the-badge&logo=buymeacoffee&logoColor=black" alt="Buy Me a Coffee" />
</a>

</div>

## Connect

<div align="center">

**Nikhil Rajput**

<a href="https://github.com/nixrajput"><img src="https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white" alt="GitHub" /></a>
<a href="https://linkedin.com/in/nixrajput"><img src="https://img.shields.io/badge/LinkedIn-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white" alt="LinkedIn" /></a>
<a href="https://x.com/nixrajput"><img src="https://img.shields.io/badge/X-000000?style=for-the-badge&logo=x&logoColor=white" alt="X" /></a>
<a href="https://instagram.com/nixrajput"><img src="https://img.shields.io/badge/Instagram-E4405F?style=for-the-badge&logo=instagram&logoColor=white" alt="Instagram" /></a>
<a href="https://telegram.me/nixrajput"><img src="https://img.shields.io/badge/Telegram-26A5E4?style=for-the-badge&logo=telegram&logoColor=white" alt="Telegram" /></a>
<a href="mailto:nkr.nikhil.nkr@gmail.com"><img src="https://img.shields.io/badge/Email-EA4335?style=for-the-badge&logo=gmail&logoColor=white" alt="Email" /></a>

</div>
