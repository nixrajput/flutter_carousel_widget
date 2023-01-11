# flutter_carousel_widget

A customizable carousel slider widget in Flutter which supports infinite scrolling, auto scrolling, custom child widget, custom animations and pre-built indicators.

[![pub package](https://img.shields.io/pub/v/flutter_carousel_widget.svg?label=Version)][pub]
[![Stars](https://img.shields.io/github/stars/nixrajput/flutter_carousel_widget?label=Stars)][repo]
[![Forks](https://img.shields.io/github/forks/nixrajput/flutter_carousel_widget?label=Forks)][repo]
[![Watchers](https://img.shields.io/github/watchers/nixrajput/flutter_carousel_widget?label=Watchers)][repo]
[![Contributors](https://img.shields.io/github/contributors/nixrajput/flutter_carousel_widget?label=Contributors)][repo]

[![GitHub release (latest by date)](https://img.shields.io/github/v/release/nixrajput/flutter_carousel_widget?label=Latest)][releases]
[![GitHub last commit](https://img.shields.io/github/last-commit/nixrajput/flutter_carousel_widget?label=Last+Commit)][repo]
[![GitHub issues](https://img.shields.io/github/issues/nixrajput/flutter_carousel_widget?label=Issues)][issues]
[![GitHub pull requests](https://img.shields.io/github/issues-pr/nixrajput/flutter_carousel_widget?label=Pull+Requests)][pulls]
[![GitHub Licence](https://img.shields.io/github/license/nixrajput/flutter_carousel_widget?label=Licence)][license]

## Features

* Infinite Scroll
* Custom Child Widget
* Auto Play
* Horizontal and Vertical Alignment
* Pre-built Carousel Indicators
* Custom Indicators

## New Features

* Expandable Carousel Widget.
* Auto-sized child support.

## Demo

[View Demo](https://nixrajput.github.io/flutter_carousel_widget)

## Installation

Add `flutter_carousel_widget` as a dependency in your `pubspec.yaml` file:

```dart
dependencies:
  flutter_carousel_widget: latest_version
```

And import it:

```dart
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
```

## Usage

### Using `FlutterCarousel` Widget

Flutter Carousel is a carousel widget which supports infinite scrolling, auto scrolling, custom child widget, custom animations and pre-built indicators.

```dart
FlutterCarousel(
  options: CarouselOptions(
    height: 400.0, 
    showIndicator: true,
    slideIndicator: CircularSlideIndicator(),
  ),
  items: [1,2,3,4,5].map((i) {
    return Builder(
      builder: (BuildContext context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.symmetric(horizontal: 5.0),
          decoration: BoxDecoration(
            color: Colors.amber
          ),
          child: Text('text $i', style: TextStyle(fontSize: 16.0),)
        );
      },
    );
  }).toList(),
)
```

### Using `ExpandableCarousel` Widget

Expandable Carousel is a carousel widget which automatically expands to the size of its child widget. It is useful when you want to show a carousel with different sized child widgets.

```dart
ExpandableCarousel(
  options: CarouselOptions(
    autoPlay: true,
    autoPlayInterval: const Duration(seconds: 2),
  ),
  items: [1,2,3,4,5].map((i) {
    return Builder(
      builder: (BuildContext context) {
        return Container(
          width: MediaQuery.of(context).size.width,
          margin: EdgeInsets.symmetric(horizontal: 5.0),
          decoration: BoxDecoration(
            color: Colors.amber
          ),
          child: Text('text $i', style: TextStyle(fontSize: 16.0),)
        );
      },
    );
  }).toList(),
)
```

### Option Customization

```dart
FlutterCarousel(
  items: items,
  options: CarouselOptions(
  height: 400.0,
  aspectRatio: 16 / 9,
  viewportFraction: 1.0,
  initialPage: 0,
  enableInfiniteScroll: true,
  reverse: false,
  autoPlay: false,
  autoPlayInterval: const Duration(seconds: 2),
  autoPlayAnimationDuration: const Duration(milliseconds: 800),
  autoPlayCurve: Curves.fastOutSlowIn,
  enlargeCenterPage: false,
  carouselController: CarouselController(),
  onPageChanged: callbackFunction,
  pageSnapping: true,
  scrollDirection: Axis.horizontal,
  pauseAutoPlayOnTouch: true,
  pauseAutoPlayOnManualNavigate: true,
  pauseAutoPlayInFiniteScroll: false,
  enlargeStrategy: CenterPageEnlargeStrategy.scale,
  disableCenter: false,
  showIndicator: true,
  floatingIndicator = true,
  slideIndicator: CircularSlideIndicator(),
  )
 )
```

### Build item widgets on demand

This method will save memory by building items once it becomes necessary. This way they won't be
built if they're not currently meant to be visible on screen. It can be used to build different
child item widgets related to content or by item index.

```dart
FlutterCarousel.builder(
  itemCount: 15,
  itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) =>
  Container(
    child: Text(itemIndex.toString()),
  ),
)
```

```dart
ExpandableCarousel.builder(
  itemCount: 15,
  itemBuilder: (BuildContext context, int itemIndex, int pageViewIndex) =>
  Container(
    child: Text(itemIndex.toString()),
  ),
)
```

## Carousel Controller

In order to manually control the pageview's position, you can create your own `CarouselController`,
and pass it to `CarouselSlider`. Then you can use the `CarouselController` instance to manipulate
the position.

```dart
class CarouselDemo extends StatelessWidget {
  CarouselController buttonCarouselController = CarouselController();

 @override
  Widget build(BuildContext context) => Column(
    children: [
      FlutterCarousel(
        items: child,
        options: CarouselOptions(
          autoPlay: false,
          carouselController: buttonCarouselController,
          enlargeCenterPage: true,
          viewportFraction: 0.9,
          aspectRatio: 2.0,
          initialPage: 2,
        ),
      ),
      RaisedButton(
        onPressed: () => buttonCarouselController.nextPage(
            duration: Duration(milliseconds: 300), curve: Curves.linear),
        child: Text('→'),
      )
    ]
  );
}
```

### `CarouselController` methods

#### `.nextPage({Duration duration, Curve curve})`

Animate to the next page

#### `.previousPage({Duration duration, Curve curve})`

Animate to the previous page

#### `.jumpToPage(int page)`

Jump to the given page.

#### `.animateToPage(int page, {Duration duration, Curve curve})`

Animate to the given page.

## Activities

![Alt](https://repobeats.axiom.co/api/embed/841225761cb31adc7197f30708fd62f1bc210c6c.svg "Repobeats analytics image")

## Connect With Me

[![Instagram: nixrajput](https://img.shields.io/badge/nixrajput-141430?logo=Instagram&logoColor=fff)][instagram]
[![Linkedin: nixrajput](https://img.shields.io/badge/nixrajput-141430?logo=Linkedin&logoColor=fff)][linkedin]
[![GitHub: nixrajput](https://img.shields.io/badge/nixrajput-141430?logo=Github&logoColor=fff)][github]
[![Twitter: nixrajput07](https://img.shields.io/badge/nixrajput07-141430?logo=Twitter&logoColor=fff)][twitter]
[![Facebook: nixrajput07](https://img.shields.io/badge/nixrajput07-141430?logo=Facebook&logoColor=fff)][facebook]

[pub]: https://pub.dev/packages/flutter_carousel_widget
[github]: https://github.com/nixrajput
[facebook]: https://facebook.com/nixrajput07
[twitter]: https://twitter.com/nixrajput07
[instagram]: https://instagram.com/nixrajput
[linkedin]: https://linkedin.com/in/nixrajput
[releases]: https://github.com/nixrajput/flutter_carousel_widget/releases
[repo]: https://github.com/nixrajput/flutter_carousel_widget
[issues]: https://github.com/nixrajput/flutter_carousel_widget/issues
[license]: https://github.com/nixrajput/flutter_carousel_widget/blob/master/LICENSE.md
[pulls]: https://github.com/nixrajput/flutter_carousel_widget/pulls
