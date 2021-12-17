import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_controller.dart';
import 'package:flutter_carousel_widget/flutter_carousel_indicators.dart';
import 'package:flutter_carousel_widget/flutter_carousel_options.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';

final List<String> imgList = [
  'https://source.unsplash.com/random/?abstracts',
  'https://source.unsplash.com/random/?fruits,flowers',
  'https://source.unsplash.com/random/?sports',
  'https://source.unsplash.com/random/?nature',
  'https://source.unsplash.com/random/?science',
  'https://source.unsplash.com/random/?computer'
];

void main() => runApp(const CarouselDemo());

final themeMode = ValueNotifier(2);

class CarouselDemo extends StatelessWidget {
  const CarouselDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      builder: (context, value, g) {
        return MaterialApp(
          initialRoute: '/',
          darkTheme: ThemeData.dark(),
          themeMode: ThemeMode.values.toList()[value as int],
          debugShowCheckedModeBanner: false,
          routes: {
            '/': (ctx) => const CarouselDemoHome(),
            '/complicated': (ctx) => const ComplicatedImageDemo(),
            '/enlarge': (ctx) => const EnlargeStrategyDemo(),
            '/manual': (ctx) => const ManuallyControlledSlider(),
            '/fullscreen': (ctx) => const FullscreenSliderDemo(),
            '/indicator': (ctx) => const CarouselWithIndicatorDemo(),
            '/position': (ctx) => const KeepPageViewPositionDemo(),
            '/multiple': (ctx) => const MultipleItemDemo(),
          },
        );
      },
      valueListenable: themeMode,
    );
  }
}

class DemoItem extends StatelessWidget {
  final String title;
  final String route;

  const DemoItem(this.title, this.route, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      onTap: () {
        Navigator.pushNamed(context, route);
      },
    );
  }
}

class CarouselDemoHome extends StatelessWidget {
  const CarouselDemoHome({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carousel Demo'),
        actions: [
          IconButton(
              icon: const Icon(Icons.nightlight_round),
              onPressed: () {
                themeMode.value = themeMode.value == 1 ? 2 : 1;
              })
        ],
      ),
      body: ListView(
        children: const <Widget>[
          DemoItem('Image Slider Demo', '/complicated'),
          DemoItem('Enlarge Strategy Demo', '/enlarge'),
          DemoItem('Manually Controlled Slider', '/manual'),
          DemoItem('Fullscreen Carousel Slider', '/fullscreen'),
          DemoItem('Carousel with Custom Indicator Demo', '/indicator'),
          DemoItem('Keep PageView Position Demo', '/position'),
          DemoItem('Multiple Item in One Screen Demo', '/multiple'),
        ],
      ),
    );
  }
}

final List<Widget> imageSliders = imgList
    .map((item) => Container(
          margin: const EdgeInsets.all(5.0),
          child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(5.0)),
              child: Image.network(
                item,
                fit: BoxFit.cover,
                width: double.infinity,
              )),
        ))
    .toList();

class ComplicatedImageDemo extends StatelessWidget {
  const ComplicatedImageDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Image Slider Demo')),
      body: Center(
        child: FlutterCarousel(
          options: CarouselOptions(
            autoPlay: true,
            aspectRatio: 1.0,
            enlargeCenterPage: true,
            showIndicator: true,
            slideIndicator: SequentialFillIndicator(),
          ),
          items: imageSliders,
        ),
      ),
    );
  }
}

class EnlargeStrategyDemo extends StatelessWidget {
  const EnlargeStrategyDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enlarge Strategy Demo')),
      body: Center(
        child: FlutterCarousel(
          options: CarouselOptions(
            aspectRatio: 2.0,
            enlargeCenterPage: true,
            enlargeStrategy: CenterPageEnlargeStrategy.height,
            showIndicator: true,
            autoPlay: true,
            slideIndicator: CircularWaveSlideIndicator(),
          ),
          items: imageSliders,
        ),
      ),
    );
  }
}

class ManuallyControlledSlider extends StatefulWidget {
  const ManuallyControlledSlider({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ManuallyControlledSliderState();
  }
}

class _ManuallyControlledSliderState extends State<ManuallyControlledSlider> {
  final CarouselController _controller = CarouselController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Manually Controlled Slider')),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16.0),
              FlutterCarousel(
                items: imageSliders,
                options: CarouselOptions(
                  enlargeCenterPage: true,
                  height: 200,
                  showIndicator: true,
                  autoPlay: true,
                  slideIndicator: CircularWaveSlideIndicator(),
                ),
                carouselController: _controller,
              ),
              Column(
                children: <Widget>[
                  const SizedBox(height: 16.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: ElevatedButton(
                          onPressed: () => _controller.previousPage(),
                          child: const Text('←'),
                        ),
                      ),
                      Flexible(
                        child: ElevatedButton(
                          onPressed: () => _controller.nextPage(),
                          child: const Text('→'),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ...Iterable<int>.generate(imgList.length).map(
                        (int pageIndex) => Flexible(
                          child: ElevatedButton(
                            onPressed: () =>
                                _controller.animateToPage(pageIndex),
                            child: Text("$pageIndex"),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              )
            ],
          ),
        ));
  }
}

class FullscreenSliderDemo extends StatelessWidget {
  const FullscreenSliderDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fullscreen Slider Demo')),
      body: Builder(
        builder: (context) {
          final double height = MediaQuery.of(context).size.height;
          return FlutterCarousel(
            options: CarouselOptions(
              height: height,
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              showIndicator: true,
              autoPlay: true,
              slideIndicator: CircularWaveSlideIndicator(),
              // autoPlay: false,
            ),
            items: imgList
                .map((item) => Center(
                        child: Image.network(
                      item,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      height: height,
                    )))
                .toList(),
          );
        },
      ),
    );
  }
}

class CarouselWithIndicatorDemo extends StatefulWidget {
  const CarouselWithIndicatorDemo({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CarouselWithIndicatorState();
  }
}

class _CarouselWithIndicatorState extends State<CarouselWithIndicatorDemo> {
  int _current = 0;
  final CarouselController _controller = CarouselController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carousel with Custom Indicator Demo')),
      body: Column(children: [
        const SizedBox(height: 20.0),
        const Text(
          'Carousel with Custom Indicator Demo',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          child: FlutterCarousel(
            items: imageSliders,
            carouselController: _controller,
            options: CarouselOptions(
                autoPlay: true,
                enlargeCenterPage: false,
                viewportFraction: 1.0,
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                  });
                }),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: imgList.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => _controller.animateToPage(entry.key),
              child: Container(
                width: 12.0,
                height: 12.0,
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black)
                        .withOpacity(_current == entry.key ? 0.9 : 0.4)),
              ),
            );
          }).toList(),
        ),
      ]),
    );
  }
}

class KeepPageViewPositionDemo extends StatelessWidget {
  const KeepPageViewPositionDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keep PageView Position Demo')),
      body: ListView.builder(itemBuilder: (ctx, index) {
        if (index == 3) {
          return FlutterCarousel(
            options: CarouselOptions(
              aspectRatio: 1.0,
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              showIndicator: true,
              autoPlay: true,
              slideIndicator: CircularStaticIndicator(),
              pageViewKey: const PageStorageKey<String>('carousel_slider'),
            ),
            items: imageSliders,
          );
        } else {
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 20),
            color: Colors.blue,
            height: 200,
            child: const Center(
              child: Text('other content'),
            ),
          );
        }
      }),
    );
  }
}

class MultipleItemDemo extends StatelessWidget {
  const MultipleItemDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Multiple Item in One Slide Demo')),
      body: Center(
        child: FlutterCarousel.builder(
          options: CarouselOptions(
            aspectRatio: 2.0,
            enlargeCenterPage: false,
            viewportFraction: 1,
            showIndicator: true,
            autoPlay: true,
            slideIndicator: CircularStaticIndicator(),
          ),
          itemCount: (imgList.length / 2).round(),
          itemBuilder: (context, index, realIdx) {
            final int first = index * 2;
            final int second = first + 1;
            return Row(
              children: [first, second].map((idx) {
                return Expanded(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: Image.network(imgList[idx], fit: BoxFit.cover),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ),
    );
  }
}
