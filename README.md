# flutter_carousel_widget

A customizable carousel slider widget for Flutter, offering features such as infinite scrolling, auto-scrolling, custom child widgets, custom animations, pre-built indicators, expandable carousel widgets, and auto-sized child support.

[![pub package](https://img.shields.io/pub/v/flutter_carousel_widget.svg?label=Version&style=flat)][pub]
[![Stars](https://img.shields.io/github/stars/nixrajput/flutter_carousel_widget?label=Stars&style=flat)][repo]
[![Forks](https://img.shields.io/github/forks/nixrajput/flutter_carousel_widget?label=Forks&style=flat)][repo]
[![Watchers](https://img.shields.io/github/watchers/nixrajput/flutter_carousel_widget?label=Watchers&style=flat)][repo]
[![Contributors](https://img.shields.io/github/contributors/nixrajput/flutter_carousel_widget?label=Contributors&style=flat)][repo]

[![GitHub release (latest by date)](https://img.shields.io/github/v/release/nixrajput/flutter_carousel_widget?label=Latest&style=flat)][releases]
[![GitHub last commit](https://img.shields.io/github/last-commit/nixrajput/flutter_carousel_widget?label=Last+Commit&style=flat)][repo]
[![GitHub issues](https://img.shields.io/github/issues/nixrajput/flutter_carousel_widget?label=Issues&style=flat)][issues]
[![GitHub pull requests](https://img.shields.io/github/issues-pr/nixrajput/flutter_carousel_widget?label=Pull+Requests&style=flat)][pulls]
[![GitHub License](https://img.shields.io/github/license/nixrajput/flutter_carousel_widget?label=Licence&style=flat)][license]

## Table of Contents

- [flutter\_carousel\_widget](#flutter_carousel_widget)
  - [Table of Contents](#table-of-contents)
  - [Features](#features)
  - [Breaking Changes for v3.0.0](#breaking-changes-for-v300)
    - [Separation of Carousel Options, Controller, and State](#separation-of-carousel-options-controller-and-state)
    - [Impact](#impact)
  - [Demo](#demo)
    - [Click here to experience the demo in a Web App](#click-here-to-experience-the-demo-in-a-web-app)
  - [Installation](#installation)
  - [Usage](#usage)
    - [Using `FlutterCarousel` Widget](#using-fluttercarousel-widget)
    - [Using `ExpandableCarousel` Widget](#using-expandablecarousel-widget)
    - [Carousel Options Customization](#carousel-options-customization)
    - [Build item widgets on demand](#build-item-widgets-on-demand)
  - [Carousel Controller](#carousel-controller)
    - [`FlutterCarouselController` methods](#fluttercarouselcontroller-methods)
      - [`.nextPage({Duration duration, Curve curve})`](#nextpageduration-duration-curve-curve)
      - [`.previousPage({Duration duration, Curve curve})`](#previouspageduration-duration-curve-curve)
      - [`.jumpToPage(int page)`](#jumptopageint-page)
      - [`.animateToPage(int page, {Duration duration, Curve curve})`](#animatetopageint-page-duration-duration-curve-curve)
  - [Predefined Slide Indicators](#predefined-slide-indicators)
    - [Slide Indicator Options Customization](#slide-indicator-options-customization)
  - [Custom Slide Indicators](#custom-slide-indicators)
  - [Contributing](#contributing)
  - [License](#license)
  - [Sponsor Me](#sponsor-me)
  - [Connect With Me](#connect-with-me)
  - [Activities](#activities)

## Features

- **Infinite Scrolling:** Seamlessly scroll through items in a loop.
- **Auto Scrolling:** Automatically advance slides at a configurable interval.
- **Custom Child Widgets:** Use any Flutter widget as a carousel item.
- **Custom Animations:** Apply custom animations to the carousel transitions.
- **Pre-built Indicators:** Easily add indicators to show the current slide position.
- **Expandable Carousel Widget:** Expand the carousel widget to fit the available space.
- **Auto-sized Child Support:** Automatically adjust the size of the carousel items to fit their content.
- **Enlarge Center Page:** The focused item can be enlarged.

## Breaking Changes for v3.0.0

In version 3.0.0 of the package, the following breaking changes have been introduced:

### Separation of Carousel Options, Controller, and State

- `FlutterCarousel` **Changes**:
  - Previously used classes:
    - CarouselOptions
    - CarouselController
    - CarouselState
  - From v3.0.0, these classes have been replaced by:
    - FlutterCarouselOptions
    - FlutterCarouselController
    - FlutterCarouselState
- `ExpandableCarousel` **Changes**:
  - Previously used classes:
    - CarouselOptions
    - CarouselController
    - CarouselState
  - From v3.0.0, these classes have been replaced by:
    - ExpandableCarouselOptions
    - ExpandableCarouselController
    - ExpandableCarouselState

### Impact

If you have been using CarouselOptions, CarouselController, and CarouselState for both FlutterCarousel and ExpandableCarousel, you will need to update your code to use the newly introduced classes specific to each carousel type.

## Demo

![Demo](https://raw.githubusercontent.com/nixrajput/flutter_carousel_widget/master/screenshots/flutter_carousel_widget_demo.gif)

### [Click here to experience the demo in a Web App](https://nixrajput.github.io/flutter_carousel_widget)

## Installation

Add `flutter_carousel_widget` as a dependency in your `pubspec.yaml` file:

```yaml
dependencies:
  flutter_carousel_widget: ^latest_version
```

Then run `flutter pub get` to fetch the package.

## Usage

### Using `FlutterCarousel` Widget

Flutter Carousel is a carousel widget which supports infinite scrolling, auto scrolling, custom child widget, custom animations and pre-built indicators.

```dart
FlutterCarousel(
  options: FlutterCarouselOptions(
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
  options: ExpandableCarouselOptions(
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

### Carousel Options Customization

```dart
FlutterCarousel(
  items: items,
  options: FlutterCarouselOptions(
    height: 400.0,
    // Sets the height of the carousel widget.

    aspectRatio: 16 / 9,
    // Defines the aspect ratio of the carousel widget.

    viewportFraction: 1.0,
    // Fraction of the viewport that each page should occupy.

    initialPage: 0,
    // The initial page to display when the carousel is first shown.

    enableInfiniteScroll: true,
    // Enables infinite looping of the carousel items.

    reverse: false,
    // Reverses the order of the carousel items.

    autoPlay: false,
    // Enables automatic scrolling through the carousel items.

    autoPlayInterval: const Duration(seconds: 2),
    // Duration between automatic scrolls when autoPlay is enabled.

    autoPlayAnimationDuration: const Duration(milliseconds: 800),
    // Duration of the animation when automatically scrolling between items.

    autoPlayCurve: Curves.fastOutSlowIn,
    // Curve for the auto-play animation to control the animation's speed.

    enlargeCenterPage: false,
    // Enlarges the center page of the carousel to make it more prominent.

    controller: CarouselController(),
    // Controls the carousel programmatically.

    onPageChanged: callbackFunction,
    // Callback function that is triggered when the page is changed.

    pageSnapping: true,
    // Enables snapping of the carousel pages to ensure they stop at each item.

    scrollDirection: Axis.horizontal,
    // Direction of the carousel scroll (horizontal or vertical).

    pauseAutoPlayOnTouch: true,
    // Pauses auto-play when the user touches the carousel.

    pauseAutoPlayOnManualNavigate: true,
    // Pauses auto-play when the user manually navigates through the carousel.

    pauseAutoPlayInFiniteScroll: false,
    // Pauses auto-play in infinite scroll mode.

    enlargeStrategy: CenterPageEnlargeStrategy.scale,
    // Strategy to enlarge the center page, such as scaling or zooming.

    disableCenter: false,
    // Disables centering of the carousel items.

    showIndicator: true,
    // Shows an indicator to display the current slide position.

    floatingIndicator: true,
    // Shows a floating indicator above the carousel.

    slideIndicator: CircularSlideIndicator(),
    // Sets a custom indicator widget for the carousel slides.
  )
)
```

### Build item widgets on demand

This method will save memory by building items once it becomes necessary. This way they won't be built if they're not currently meant to be visible on screen. It can be used to build different child item widgets related to content or by item index.

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

In order to manually control the PageView's position, you can create your own `FlutterCarouselController`, and pass it to `FlutterCarouselOptions`. Then you can use the `FlutterCarouselController` instance to manipulate the position.

```dart
class CarouselDemo extends StatelessWidget {
  FlutterCarouselController buttonCarouselController = FlutterCarouselController();

 @override
  Widget build(BuildContext context) => Column(
    children: [
      FlutterCarousel(
        items: child,
        options: FlutterCarouselOptions(
          autoPlay: false,
          controller: buttonCarouselController,
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

### `FlutterCarouselController` methods

#### `.nextPage({Duration duration, Curve curve})`

Animate to the next page

#### `.previousPage({Duration duration, Curve curve})`

Animate to the previous page

#### `.jumpToPage(int page)`

Jump to the given page.

#### `.animateToPage(int page, {Duration duration, Curve curve})`

Animate to the given page.

## Predefined Slide Indicators

The `flutter_carousel_widget` package comes with a few [predefined slide indicators](https://github.com/nixrajput/flutter_carousel_widget/tree/master/lib/src/indicators) each with its own distinct behavior. To customize the slide indicators, you can pass an instance of `SlideIndicatorOptions` to the indicator you're using.

### Slide Indicator Options Customization

```dart
  FlutterCarousel(
    ...
    options: FlutterCarouselOptions(
      ...
      slideIndicator: CircularSlideIndicator(
        slideIndicatorOptions: SlideIndicatorOptions(
          /// The alignment of the indicator.
          alignment: Alignment.bottomCenter,

          /// The color of the currently active item indicator.
          currentIndicatorColor: Colors.white,

          /// The background color of all inactive item indicators.
          indicatorBackgroundColor: Colors.white.withOpacity(0.5),

          /// The border color of all item indicators.
          indicatorBorderColor: Colors.white,

          /// The border width of all item indicators.
          indicatorBorderWidth: 1,

          /// The radius of all item indicators.
          indicatorRadius: 6,

          /// The spacing between each item indicator.
          itemSpacing: 20,

          /// The padding of the indicator.
          padding: const EdgeInsets.all(8.0),

          /// The decoration of the indicator halo.
          haloDecoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(15.0)),
              color: Colors.black.withOpacity(0.5)),

          /// The padding of the indicator halo.
          haloPadding: const EdgeInsets.all(8.0),

          /// Whether to enable the indicator halo.
          enableHalo: true,

          /// Whether to enable the animation. Only used in [CircularStaticIndicator] and [SequentialFillIndicator].
          enableAnimation: true,
        ),
      ),
    ),
  );
```

## Custom Slide Indicators

There might be cases where you want to control the look or behavior of the slide indicator or implement a totally new one. You can do that by implementing the `SlideIndicator` contract.

The following example implements an indicator which tells the percentage of the slide the user is on:

```dart
class SlidePercentageIndicator implements SlideIndicator {
  SlidePercentageIndicator({
    this.decimalPlaces = 0,
    this.style,
  });

  /// The number of decimal places to show in the output
  final int decimalPlaces;

  /// The text style to be used by the percentage text
  final TextStyle? style;

  @override
  Widget build(int currentPage, double pageDelta, int itemCount) {
    if (itemCount < 2) return const SizedBox.shrink();
    final step = 100 / (itemCount - 1);
    final percentage = step * (pageDelta + currentPage);
    return Center(
      child: Text(
        '${percentage.toStringAsFixed(decimalPlaces)}%',
        style: style ??
            const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
```

## Contributing

If you would like to contribute to this project, feel free to fork the repository, make your changes, and submit a pull request. Please follow the guidelines in the [CONTRIBUTING.md](CONTRIBUTING.md) file.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Sponsor Me

By sponsoring my efforts, you're not merely contributing to the development of my projects; you're investing in its growth and sustainability.

Your support empowers me to dedicate more time and resources to improving the project's features, addressing issues, and ensuring its continued relevance in the rapidly evolving landscape of technology.

Your sponsorship directly fuels innovation, fosters a vibrant community, and helps maintain the project's high standards of quality. Together, we can shape the future of the projects and make a lasting impact in the open-source community.

Thank you for considering sponsoring my work!

[![Sponsor](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/nixrajput)

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/nixrajput)

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://www.buymeacoffee.com/nixrajput)

## Connect With Me

[![GitHub: nixrajput](https://img.shields.io/badge/nixrajput-EFF7F6?logo=GitHub&logoColor=333&link=https://www.github.com/nixrajput)][github]
[![Linkedin: nixrajput](https://img.shields.io/badge/nixrajput-EFF7F6?logo=LinkedIn&logoColor=blue&link=https://www.linkedin.com/in/nixrajput)][linkedin]
[![Instagram: nixrajput](https://img.shields.io/badge/nixrajput-EFF7F6?logo=Instagram&link=https://www.instagram.com/nixrajput)][instagram]
[![Twitter: nixrajput07](https://img.shields.io/badge/nixrajput07-EFF7F6?logo=X&logoColor=333&link=https://x.com/nixrajput07)][twitter]
[![Telegram: nixrajput](https://img.shields.io/badge/nixrajput-EFF7F6?logo=Telegram&link=https://telegram.me/nixrajput)][telegram]
[![Gmail: nkr.nikhi.nkr@gmail.com](https://img.shields.io/badge/nkr.nikhil.nkr@gmail.com-EFF7F6?logo=Gmail&link=mailto:nkr.nikhil.nkr@gmail.com)][gmail]

## Activities

![Alt](https://repobeats.axiom.co/api/embed/841225761cb31adc7197f30708fd62f1bc210c6c.svg "Repobeats analytics image")

[pub]: https://pub.dev/packages/flutter_carousel_widget
[github]: https://github.com/nixrajput
[telegram]: https://telegram.me/nixrajput
[twitter]: https://twitter.com/nixrajput07
[instagram]: https://instagram.com/nixrajput
[linkedin]: https://linkedin.com/in/nixrajput
[gmail]: mailto:nkr.nikhil.nkr@gmail.com
[releases]: https://github.com/nixrajput/flutter_carousel_widget/releases
[repo]: https://github.com/nixrajput/flutter_carousel_widget
[issues]: https://github.com/nixrajput/flutter_carousel_widget/issues
[license]: https://github.com/nixrajput/flutter_carousel_widget/blob/master/LICENSE
[pulls]: https://github.com/nixrajput/flutter_carousel_widget/pulls
