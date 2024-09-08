import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';

import '../data/sliders.dart';

class PageChangedReasonCarouselDemo extends StatefulWidget {
  const PageChangedReasonCarouselDemo({Key? key}) : super(key: key);

  @override
  State<PageChangedReasonCarouselDemo> createState() =>
      _PageChangedReasonCarouselDemoState();
}

class _PageChangedReasonCarouselDemoState
    extends State<PageChangedReasonCarouselDemo> {
  FlutterCarouselController? controller = FlutterCarouselController();
  bool autoplay = false;
  CarouselPageChangedReason? lastReason;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        title: const Text('Page Changed Reason Carousel Demo'),
        actions: [
          IconButton(
            onPressed: () => setState(() {
              autoplay = !autoplay;
              print('autoplay toggled');
            }),
            icon: Icon(autoplay ? Icons.pause : Icons.play_arrow),
          ),
          IconButton(
            onPressed: () => setState(() {
              controller =
                  controller == null ? FlutterCarouselController() : null;
              print('controller toggled');
            }),
            icon: Icon(
              controller == null ? Icons.gamepad_outlined : Icons.gamepad,
            ),
          )
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
                'Last changed reason:\n${lastReason != null ? lastReason!.toString() : 'None'}'),
            Expanded(
              child: FlutterCarousel(
                items: sliders,
                options: FlutterCarouselOptions(
                  onPageChanged: (_, reason) => setState(
                    () {
                      lastReason = reason;
                      print(reason);
                    },
                  ),
                  controller: controller,
                  enableInfiniteScroll: true,
                  autoPlay: autoplay,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
