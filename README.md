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

## Table of Contents

- [flutter\_carousel\_widget](#flutter_carousel_widget)
  - [Table of Contents](#table-of-contents)
  - [Features](#features)
  - [Demo](#demo)
  - [Installation](#installation)
  - [Usage](#usage)
    - [Using `FlutterCarousel` Widget](#using-fluttercarousel-widget)
    - [Using `ExpandableCarousel` Widget](#using-expandablecarousel-widget)
    - [Option Customization](#option-customization)
    - [Build item widgets on demand](#build-item-widgets-on-demand)
  - [Carousel Controller](#carousel-controller)
    - [`CarouselController` methods](#carouselcontroller-methods)
      - [`.nextPage({Duration duration, Curve curve})`](#nextpageduration-duration-curve-curve)
      - [`.previousPage({Duration duration, Curve curve})`](#previouspageduration-duration-curve-curve)
      - [`.jumpToPage(int page)`](#jumptopageint-page)
      - [`.animateToPage(int page, {Duration duration, Curve curve})`](#animatetopageint-page-duration-duration-curve-curve)
  - [Custom Slide Indicators](#custom-slide-indicators)
  - [Contributors](#contributors)
  - [Contributing](#contributing)
  - [License](#license)
  - [Sponsor Me](#sponsor-me)
  - [Connect With Me](#connect-with-me)
  - [Activities](#activities)

## Features

- Infinite Scroll
- Custom Child Widget
- Auto Play
- Horizontal and Vertical Alignment
- Pre-built Carousel Indicators
- Custom Indicators
- Expandable Carousel Widget.
- Auto-sized child support.

## Demo

![Demo](https://raw.githubusercontent.com/nixrajput/flutter_carousel_widget/master/screenshots/flutter_carousel_widget_demo.gif)

[View Demo](https://nixrajput.github.io/flutter_carousel_widget)

## Installation

Add `flutter_carousel_widget` as a dependency in your `pubspec.yaml` file:

```dart
dependencies:
  flutter_carousel_widget: ^latest_version
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
    controller: CarouselController(),
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

In order to manually control the pageview's position, you can create your own `CarouselController`, and pass it to `CarouselSlider`. Then you can use the `CarouselController` instance to manipulate the position.

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

### `CarouselController` methods

#### `.nextPage({Duration duration, Curve curve})`

Animate to the next page

#### `.previousPage({Duration duration, Curve curve})`

Animate to the previous page

#### `.jumpToPage(int page)`

Jump to the given page.

#### `.animateToPage(int page, {Duration duration, Curve curve})`

Animate to the given page.

## Custom Slide Indicators

The `flutter_carousel_widget` package comes with a few [predefined slide indicators](https://github.com/nixrajput/flutter_carousel_widget/tree/master/lib/src/indicators) with their own unique behaviors. This helps drastically and brings focus towards the actual implementation of your carousel widget.

However, there might be cases where you want to control the look or behavior of the slide indicator or implement a totally new one. You can do that by implementing the `SlideIndicator` contract.

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

## Contributors

<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->
<table>
  <tbody>
    <tr>
      <td align="center" valign="top" width="14.28%"><a href="https://nixrajput.vercel.app"><img src="https://avatars.githubusercontent.com/u/10887215?s=100&v=4" width="100px;" alt="Nikhil Rajput"/><br /><sub><b>Nikhil Rajput</b></sub></a><br /><a href="#question-nixrajput" title="Answering Questions">💬</a> <a href="https://github.com/nixrajput/flutter_carousel_widget/commits?author=nixrajput" title="Documentation">📖</a> <a href="#maintenance-nixrajput" title="Maintenance">🚧</a> <a href="#infra-nixrajput" title="Infrastructure (Hosting, Build-Tools, etc)">🚇</a> <a href="https://github.com/nixrajput/flutter_carousel_widget/pulls?q=is%3Apr+reviewed-by%3Anixrajput" title="Reviewed Pull Requests">👀</a> <a href="#talk-nixrajput" title="Talks">📢</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/DDavidPrime"><img src="https://avatars.githubusercontent.com/u/61236867?s=100&v=4" width="100px;" alt="David Djordjevic"/><br /><sub><b>David Djordjevic</b></sub></a><br /> <a href="https://github.com/nixrajput/flutter_carousel_widget/commits?author=DDavidPrime" title="Documentation">📖</a> <a href="https://github.com/nixrajput/flutter_carousel_widget/pulls?q=is%3Apr+reviewed-by%3ADDavidPrime" title="Reviewed Pull Requests">👀</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/MatthewJones517"><img src="https://avatars.githubusercontent.com/u/35195921?s=100&v=4" width="100px;" alt="Matthew Jones"/><br /><sub><b>Matthew Jones</b></sub></a><br /><a href="https://github.com/nixrajput/flutter_carousel_widget/commits?author=MatthewJones517" title="Documentation">📖</a> <a href="https://github.com/nixrajput/flutter_carousel_widget/pulls?q=is%3Apr+reviewed-by%3AMatthewJones517" title="Reviewed Pull Requests">👀</a></td>
      <td align="center" valign="top" width="14.28%"><a href="https://github.com/DjordjeMancic97"><img src="https://avatars.githubusercontent.com/u/58264548?s=100&v=4" width="100px;" alt="DjordjeMancic97"/><br /><sub><b>DjordjeMancic97</b></sub></a><br /><a href="https://github.com/nixrajput/flutter_carousel_widget/commits?author=DjordjeMancic97" title="Documentation">📖</a> <a href="https://github.com/nixrajput/flutter_carousel_widget/pulls?q=is%3Apr+reviewed-by%3ADjordjeMancic97" title="Reviewed Pull Requests">👀</a></td>
    </tr>
  </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->

## Contributing

If you would like to contribute to this project, feel free to fork the repository, make your changes, and submit a pull request. Please follow the guidelines in the [CONTRIBUTING.md](CONTRIBUTING.md) file.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Sponsor Me

- By sponsoring my efforts, you're not merely contributing to the development of my projects; you're investing in its growth and sustainability.
- Your support empowers me to dedicate more time and resources to improving the project's features, addressing issues, and ensuring its continued relevance in the rapidly evolving landscape of technology.
- Your sponsorship directly fuels innovation, fosters a vibrant community, and helps maintain the project's high standards of quality. Together, we can shape the future of the projects and make a lasting impact in the open-source community.
- Thank you for considering sponsoring my work!

[![Sponsor](https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23fe8e86)](https://github.com/sponsors/nixrajput)

## Connect With Me

[![GitHub: nixrajput](https://img.shields.io/badge/nixrajput-EFF7F6?logo=GitHub&logoColor=333&link=https://www.github.com/nixrajput)][github]
[![Linkedin: nixrajput](https://img.shields.io/badge/nixrajput-EFF7F6?logo=LinkedIn&logoColor=blue&link=https://www.linkedin.com/in/nixrajput)][linkedin]
[![Instagram: nixrajput](https://img.shields.io/badge/nixrajput-EFF7F6?logo=Instagram&link=https://www.instagram.com/nixrajput)][instagram]
[![Twitter: nixrajput07](https://img.shields.io/badge/nixrajput-EFF7F6?logo=X&logoColor=333&link=https://x.com/nixrajput)][twitter]
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
