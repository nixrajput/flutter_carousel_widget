import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';

import '../data/sliders.dart';

class ManuallyControlledCarouselDemo extends StatefulWidget {
  const ManuallyControlledCarouselDemo({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ManuallyControlledCarouselDemoState();
  }
}

class _ManuallyControlledCarouselDemoState
    extends State<ManuallyControlledCarouselDemo> {
  final FlutterCarouselController _controller = FlutterCarouselController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manually Controlled Carousel Demo')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: FlutterCarousel(
                  items: sliders,
                  options: FlutterCarouselOptions(
                    viewportFraction: 1.0,
                    autoPlay: false,
                    floatingIndicator: false,
                    enableInfiniteScroll: true,
                    initialPage: 3,
                    controller: _controller,
                    slideIndicator: CircularWaveSlideIndicator(),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 16.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: ElevatedButton(
                        onPressed: _controller.previousPage,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.arrow_back),
                        ),
                      ),
                    ),
                    Flexible(
                      child: ElevatedButton(
                        onPressed: _controller.nextPage,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.arrow_forward),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
