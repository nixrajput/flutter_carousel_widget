import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';

import '../data/sliders.dart';

class MultipleItemsCarouselDemo extends StatelessWidget {
  const MultipleItemsCarouselDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Multiple Items in One Screen Carousel Demo')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800.0),
          child: FlutterCarousel.builder(
            options: FlutterCarouselOptions(
              height: 400,
              aspectRatio: 2.0,
              enlargeCenterPage: false,
              viewportFraction: 1,
              showIndicator: true,
              enableInfiniteScroll: true,
              autoPlayInterval: const Duration(seconds: 2),
              autoPlay: true,
              slideIndicator: CircularStaticIndicator(),
            ),
            itemCount: (slides.length / 2).round(),
            itemBuilder: (context, index, realIdx) {
              final first = index * 2;
              final second = first + 1;
              return Row(
                children: [first, second].map((idx) {
                  return Expanded(
                    flex: 1,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child: Container(
                        color: slides[idx].color,
                        height: slides[idx].height,
                        child: Center(
                          child: Text(slides[idx].title),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ),
    );
  }
}
