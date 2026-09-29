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

- **Preview:** one live carousel with the controller's first, previous, play or pause, next and last buttons under it, and the index and position read live from the controller and `onScrolled`.
- **Options:** every option in five cards: the carousel (`FlutterCarousel` or `ExpandableCarousel`, the viewport fraction, infinite, pad ends and flush edges), the effect and its strength, the indicator painter and placement, motion (autoplay with varied intervals and a soft snap spring) and direction (vertical, reverse and right-to-left).
- **Effects:** every preset in its own small carousel.
- **Expandable:** slides of different heights, with the carousel's height following the drag between them.
- **Keyboard and screen readers:** how to drive the preview with the arrow keys, Home and End, and what a screen reader hears.

The preview never scrolls away. The options sit in cards that open and close, and a closed card shows its current values, so a phone starts with an overview of everything. From 840 pixels wide, and on a landscape phone, the options get a scrolling panel beside the preview, with the rest of the demo scrolling under the preview; a narrower screen pins the preview above one list of cards. An open card's header stays pinned while the card is on screen, Reset puts every option back, and Expand all opens every card in a group. A mouse wheel over the preview scrolls the list beside or under it. The app follows the device theme, and the switch in the app bar forces light or dark.

`flutter test` checks the layout at 20 screen sizes, from a 320-pixel phone to a 3440-pixel ultrawide and including 200% text, and that cards open by tap and keyboard, focus is never hidden behind a pinned header and the page keeps its state across a resize.

Run it from this directory with `flutter run -d chrome`, or open the live demo at https://nixrajput.github.io/flutter_carousel_widget.
