import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';

import '../data/sliders.dart';

class HaloIndicatorCarouselDemo extends StatefulWidget {
  const HaloIndicatorCarouselDemo({Key? key}) : super(key: key);

  @override
  State<HaloIndicatorCarouselDemo> createState() =>
      _HaloIndicatorCarouselDemoState();
}

class _HaloIndicatorCarouselDemoState extends State<HaloIndicatorCarouselDemo> {
  bool useCustomIndicatorOptions = false;

  SlideIndicatorOptions defaultOptions = const SlideIndicatorOptions(
    enableHalo: true,
  );

  SlideIndicatorOptions customOptions = const SlideIndicatorOptions(
    enableHalo: true,
    currentIndicatorColor: Colors.white,
    haloDecoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [
          Color(0xFF9B2BFF),
          Color(0xFF2BFF88),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.all(Radius.circular(15.0)),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(title: const Text('Carousel with Indicator Halo Demo')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              const Spacer(
                flex: 1,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          useCustomIndicatorOptions = false;
                        });
                      },
                      child: const Text("Default Halo")),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          useCustomIndicatorOptions = true;
                        });
                      },
                      child: const Text("Custom Halo")),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.width,
                ),
                child: FlutterCarousel(
                  options: FlutterCarouselOptions(
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 3),
                    disableCenter: true,
                    viewportFraction: deviceSize.width > 800.0 ? 0.8 : 1.0,
                    height: deviceSize.height * 0.45,
                    indicatorMargin: 12.0,
                    enableInfiniteScroll: true,
                    slideIndicator: CircularSlideIndicator(
                      slideIndicatorOptions: useCustomIndicatorOptions
                          ? customOptions
                          : defaultOptions,
                    ),
                    initialPage: 2,
                  ),
                  items: sliders,
                ),
              ),
              const Spacer(
                flex: 5,
              )
            ],
          ),
        ),
      ),
    );
  }
}
