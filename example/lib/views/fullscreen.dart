import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';

import '../data/sliders.dart';

class FullscreenCarouselDemo extends StatelessWidget {
  const FullscreenCarouselDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fullscreen Carousel Demo')),
      body: Center(
        child: Builder(
          builder: (context) {
            final height = MediaQuery.of(context).size.height;
            return FlutterCarousel(
              options: FlutterCarouselOptions(
                height: height,
                viewportFraction: 1.0,
                enlargeCenterPage: false,
                autoPlay: true,
                enableInfiniteScroll: true,
                autoPlayInterval: const Duration(seconds: 5),
                slideIndicator: CircularWaveSlideIndicator(),
              ),
              items: sliders,
            );
          },
        ),
      ),
    );
  }
}
