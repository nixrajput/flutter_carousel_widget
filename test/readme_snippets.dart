// Every ```dart block in README.md appears in this file verbatim, so the
// analyzer compiles it; readme_test.dart checks the match.
// ignore_for_file: unused_element, unused_local_variable

import 'package:flutter/widgets.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';

// dart format off

class Review {
  const Review(this.text);
  final String text;
}

class ReviewCard extends StatelessWidget {
  const ReviewCard(this.review, {super.key});
  final Review review;
  @override
  Widget build(BuildContext context) => Text(review.text);
}

Widget quickStart(List<String> urls) {
  return FlutterCarousel(
  height: 200,
  itemAlignment: null,
  items: [for (final url in urls) Image.network(url, fit: BoxFit.cover)],
);
}

Widget expandable(List<Review> reviews) {
  return ExpandableCarousel(
  items: [for (final review in reviews) ReviewCard(review)],
);
}

Future<void> controlled(List<Widget> items) async {
final controller = FlutterCarouselController();

// In build:
FlutterCarousel(controller: controller, items: items);

// Any time after the first frame:
await controller.nextPage();
final showing = controller.index;
}

Widget autoPlay(List<Widget> items) {
  return FlutterCarousel(
  items: items,
  autoPlay: CarouselAutoPlay(
    interval: const Duration(seconds: 4),
    intervalFor: (index) => index == 0
        ? const Duration(seconds: 8)
        : const Duration(seconds: 4),
  ),
);
}

Widget effects(List<Widget> items) {
  return FlutterCarousel(
  items: items,
  effect: const CarouselEffect.coverflow().then(const CarouselEffect.fade()),
);
}

Widget customEffect(List<Widget> items) {
  return FlutterCarousel(
  items: items,
  effect: CarouselEffect.builder(
    (context, position, child) => Opacity(
      opacity: 1 - position.offset.abs().clamp(0.0, 1.0) * 0.5,
      child: child,
    ),
  ),
);
}

Widget indicators(List<Widget> items) {
  return FlutterCarousel(
  items: items,
  indicator: const CarouselIndicator(
    painter: CircularWaveIndicator(
      style: SlideIndicatorStyle(activeColor: Color(0xFF9B8CFF)),
    ),
    placement: CarouselIndicatorPlacement.below,
  ),
);
}

Widget labels(List<Widget> items) {
  return FlutterCarousel(
  items: items,
  semanticLabel: 'Featured products',
  semanticSlideLabel: (index, count) => 'Product ${index + 1} of $count',
);
}

Widget flush(List<Widget> items) {
  return FlutterCarousel(
  items: items,
  viewportFraction: 0.8,
  edgeAlignment: CarouselEdgeAlignment.flush,
);
}

class _BeforeAfter extends StatefulWidget {
  const _BeforeAfter();
  @override
  State<_BeforeAfter> createState() => _BeforeAfterState();
}

class _BeforeAfterState extends State<_BeforeAfter> {
  var current = 0;
  final items = <Widget>[];
  @override
  Widget build(BuildContext context) {
    return FlutterCarousel(
  items: items,
  height: 240,
  effect: const CarouselEffect.enlarge(),
  autoPlay: const CarouselAutoPlay(interval: Duration(seconds: 4)),
  indicator: const CarouselIndicator(painter: CircularWaveIndicator()),
  onPageChanged: (index, reason) => setState(() => current = index),
);
  }
}
// dart format on
