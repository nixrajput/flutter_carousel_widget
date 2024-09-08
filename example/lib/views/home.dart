import 'package:example/components/demo_item.dart';
import 'package:flutter/material.dart';

class CarouselDemoHome extends StatelessWidget {
  const CarouselDemoHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Carousel Demo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600.0),
          child: ListView(
            shrinkWrap: true,
            children: const [
              SizedBox(height: 8.0),
              DemoItem('Standard Carousel Demo', '/standard'),
              DemoItem('Enlarge Strategy Carousel Demo', '/enlarge'),
              DemoItem('Manually Controlled Carousel Demo', '/manual'),
              DemoItem('Fullscreen Carousel Demo', '/fullscreen'),
              DemoItem(
                  'Carousel with Custom Indicator Demo', '/custom_indicator'),
              DemoItem('Carousel with Indicator Halo Demo', '/indicator_halo'),
              DemoItem('Multiple Items in One Screen Carousel Demo',
                  '/multiple_items'),
              DemoItem('Expandable Carousel Demo', '/expandable'),
              DemoItem(
                  'Page Changed Reason Carousel Demo', '/page_changed_reason'),
            ],
          ),
        ),
      ),
    );
  }
}
