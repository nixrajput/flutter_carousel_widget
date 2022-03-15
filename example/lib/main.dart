import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_controller.dart';
import 'package:flutter_carousel_widget/flutter_carousel_indicators.dart';
import 'package:flutter_carousel_widget/flutter_carousel_options.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';

import 'app_themes.dart';

final List<String> imgList = [
  'https://source.unsplash.com/random/1920x1920/?abstracts',
  'https://source.unsplash.com/random/1920x1920/?fruits,flowers',
  'https://source.unsplash.com/random/1920x1920/?sports',
  'https://source.unsplash.com/random/1920x1920/?nature',
  'https://source.unsplash.com/random/1920x1920/?science',
  'https://source.unsplash.com/random/1920x1920/?computer'
];

void main() => runApp(const CarouselDemo());

class CarouselDemo extends StatelessWidget {
  const CarouselDemo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
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
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: ThemeMode.system,
    );
  }
}

class DemoItem extends StatelessWidget {
  final String title;
  final String route;

  const DemoItem(this.title, this.route, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, route);
      },
      child: Card(
        color: Colors.redAccent.withOpacity(0.25),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 16.0,
            horizontal: 16.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18.0,
                ),
              ),
              const Icon(Icons.arrow_forward_ios)
            ],
          ),
        ),
        margin: const EdgeInsets.only(
          bottom: 16.0,
          left: 16.0,
          right: 16.0,
        ),
      ),
    );
  }
}

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
      body: ListView(
        shrinkWrap: true,
        children: const [
          SizedBox(height: 8.0),
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
    .map((item) => ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(4.0)),
          child: Image.network(
            item,
            width: double.infinity,
            loadingBuilder: (BuildContext ctx, Widget child,
                ImageChunkEvent? loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (
              BuildContext context,
              Object exception,
              StackTrace? stackTrace,
            ) {
              return const Text(
                'Oops!! An error occurred. 😢',
                style: TextStyle(fontSize: 16.0),
              );
            },
          ),
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
            height: MediaQuery.of(context).size.height * 0.5,
            autoPlay: true,
          ),
          items: imgList
              .map((item) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ClipRRect(
                      borderRadius:
                          const BorderRadius.all(Radius.circular(4.0)),
                      child: Image.network(
                        item,
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.5,
                        loadingBuilder: (BuildContext ctx, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (
                          BuildContext context,
                          Object exception,
                          StackTrace? stackTrace,
                        ) {
                          return const Text(
                            'Oops!! An error occurred. 😢',
                            style: TextStyle(fontSize: 16.0),
                          );
                        },
                      ),
                    ),
                  ))
              .toList(),
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
      appBar: AppBar(title: const Text('Center Enlarge Strategy Demo')),
      body: Center(
        child: FlutterCarousel(
          options: CarouselOptions(
            enlargeCenterPage: true,
            autoPlay: true,
            viewportFraction: 0.8,
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
            const SizedBox(height: 8.0),
            FlutterCarousel(
              items: imgList
                  .map((item) => Image.network(
                        item,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                        loadingBuilder: (BuildContext ctx, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                        errorBuilder: (
                          BuildContext context,
                          Object exception,
                          StackTrace? stackTrace,
                        ) {
                          return const Text(
                            'Oops!! An error occurred. 😢',
                            style: TextStyle(fontSize: 16.0),
                          );
                        },
                      ))
                  .toList(),
              options: CarouselOptions(
                viewportFraction: 1.0,
                height: MediaQuery.of(context).size.height * 0.5,
                showIndicator: true,
                autoPlay: false,
                floatingIndicator: false,
                slideIndicator: CircularWaveSlideIndicator(),
              ),
              carouselController: _controller,
            ),
            const SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
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
    );
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
          final height = MediaQuery.of(context).size.height;
          return FlutterCarousel(
            options: CarouselOptions(
              height: height,
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              showIndicator: true,
              floatingIndicator: false,
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
      appBar: AppBar(title: const Text('Custom Indicator Demo')),
      body: Column(
        children: [
          Expanded(
            child: FlutterCarousel(
              items: imageSliders,
              carouselController: _controller,
              options: CarouselOptions(
                  autoPlay: true,
                  enlargeCenterPage: false,
                  viewportFraction: 1.0,
                  showIndicator: false,
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
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 4.0),
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
        ],
      ),
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
        if (index == 2) {
          return FlutterCarousel(
            options: CarouselOptions(
              viewportFraction: 1.0,
              aspectRatio: 16 / 9,
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
            final first = index * 2;
            final second = first + 1;
            return Row(
              children: [first, second].map((idx) {
                return Expanded(
                  flex: 1,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    child: Image.network(
                      imgList[idx],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
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
