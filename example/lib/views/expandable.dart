import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';

import '../data/expandable_sliders.dart';

class ExpandableCarouselDemo extends StatefulWidget {
  const ExpandableCarouselDemo({Key? key}) : super(key: key);

  @override
  State<ExpandableCarouselDemo> createState() => _ExpandableCarouselDemoState();
}

class _ExpandableCarouselDemoState extends State<ExpandableCarouselDemo> {
  final ExpandableCarouselController _controller =
      ExpandableCarouselController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expandable Carousel Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            ExpandableCarousel.builder(
              options: ExpandableCarouselOptions(
                // viewportFraction: 1.0,
                enableInfiniteScroll: true,
                // enlargeCenterPage: true,
                // initialPage: 1,
                autoPlay: true,
                controller: _controller,
                //showIndicator: false,
                floatingIndicator: false,
                restorationId: 'expandable_carousel',
              ),
              itemCount: expandableSliders.length,
              itemBuilder: (context, index, realIdx) {
                return expandableSliders[index];
              },
            ),
          ],
        ),
      ),
    );
  }
}
