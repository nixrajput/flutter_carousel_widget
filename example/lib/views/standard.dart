import 'package:example/data/sliders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';

class StandardCarouselDemo extends StatelessWidget {
  const StandardCarouselDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(title: const Text('Standard Carousel Demo')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            constraints: BoxConstraints(maxHeight: deviceSize.width),
            child: FlutterCarousel(
              options: FlutterCarouselOptions(
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 3),
                height: deviceSize.height,
                viewportFraction: 1.0,
                indicatorMargin: 12.0,
                enableInfiniteScroll: true,
                slideIndicator: CircularSlideIndicator(),
                initialPage: 2,
                reverse: true,
              ),
              items: sliders,
            ),
          ),
        ),
      ),
    );
  }
}
