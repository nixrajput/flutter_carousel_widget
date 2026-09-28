# flutter_carousel_widget example

## Usage

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';

Widget gallery(List<String> urls) => FlutterCarousel(
  height: 200,
  items: [for (final url in urls) Image.network(url, fit: BoxFit.cover)],
);
```

## The demo app

This directory is also a Flutter demo of every carousel option. It has five parts:

- **Preview and options:** one live carousel with every option beside it: `FlutterCarousel` or `ExpandableCarousel`, the effect and its strength, the indicator painter and placement, the viewport fraction, autoplay with varied intervals, infinite, pad ends, flush edges, reverse, the vertical axis, right-to-left and a soft snap spring. The button under the preview pauses and resumes autoplay.
- **Controller:** first, previous, next and last buttons, with the index and position read live from the controller and `onScrolled`.
- **Effects:** every preset in its own small carousel.
- **Expandable:** slides of different heights, with the carousel's height following the drag between them.
- **Keyboard and screen readers:** how to drive the preview with the arrow keys, Home and End, and what a screen reader hears.

The preview never scrolls away. On wide or landscape screens the options and preview are both pinned side by side, whenever the options fit whole, with the rest in one list beneath. On a portrait phone the preview is pinned above that list, and the options lead it. A mouse wheel anywhere on the page scrolls the list. The app follows the device theme, and the switch in the app bar forces light or dark.

`flutter test` checks the layout at phone to desktop sizes, including a large text scale and a phone's bottom inset.

Run it from this directory with `flutter run -d chrome`, or open the live demo at https://nixrajput.github.io/flutter_carousel_widget.
