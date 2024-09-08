import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';

import '../data/sliders.dart';

class EnlargeStrategyCarouselDemo extends StatelessWidget {
  const EnlargeStrategyCarouselDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enlarge Strategy Carousel Demo')),
      body: Center(
        child: FlutterCarousel(
          options: FlutterCarouselOptions(
            autoPlay: true,
            enableInfiniteScroll: true,
            autoPlayInterval: const Duration(seconds: 3),
            viewportFraction: 0.8,
            enlargeCenterPage: true,
            slideIndicator: CircularWaveSlideIndicator(),
            floatingIndicator: false,
            scrollDirection: Axis.vertical,
          ),
          items: sliders,
        ),
      ),
    );
  }
}
