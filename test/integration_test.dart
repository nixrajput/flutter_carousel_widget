import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlutterCarousel Integration Tests', () {
    testWidgets('Carousel should update based on CarouselController',
        (WidgetTester tester) async {
      final controller = FlutterCarouselController();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterCarousel(
              options: FlutterCarouselOptions(
                controller: controller,
                height: 300,
                autoPlay: true,
              ),
              items: [const Text('Page 1'), const Text('Page 2')],
            ),
          ),
        ),
      );

      controller.nextPage();
      await tester.pumpAndSettle();

      expect(find.text('Page 2'), findsOneWidget);
    });

    testWidgets('Carousel should autoplay and switch pages automatically',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterCarousel(
              options: FlutterCarouselOptions(
                height: 300,
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 1),
              ),
              items: [const Text('Page 1'), const Text('Page 2')],
            ),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Page 2'), findsOneWidget);
    });

    testWidgets('Carousel should be responsive on different screen sizes',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: LayoutBuilder(
            builder: (context, constraints) {
              return FlutterCarousel(
                items: List<Widget>.generate(5, (index) => Text('Item $index')),
                options: FlutterCarouselOptions(
                  viewportFraction: constraints.maxWidth < 600 ? 0.8 : 0.5,
                ),
              );
            },
          ),
        ),
      );

      await tester.binding
          .setSurfaceSize(const Size(400, 800)); // Simulate mobile screen
      await tester.pumpAndSettle();

      expect(find.text('Item 0'), findsOneWidget);

      await tester.binding
          .setSurfaceSize(const Size(800, 600)); // Simulate tablet screen
      await tester.pumpAndSettle();

      expect(find.text('Item 0'), findsOneWidget);
    });

    testWidgets('Carousel should handle screen orientation changes',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FlutterCarousel(
            items: List<Widget>.generate(5, (index) => Text('Item $index')),
            options: FlutterCarouselOptions(viewportFraction: 0.8),
          ),
        ),
      );

      await tester.binding.setSurfaceSize(const Size(400, 800)); // Portrait
      await tester.pumpAndSettle();
      expect(find.text('Item 0'), findsOneWidget);

      await tester.binding.setSurfaceSize(const Size(800, 400)); // Landscape
      await tester.pumpAndSettle();
      expect(find.text('Item 0'), findsOneWidget);
    });

    testWidgets('Carousel should correctly handle page change events',
        (WidgetTester tester) async {
      var currentPage = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: FlutterCarousel(
            items: List<Widget>.generate(5, (index) => Text('Item $index')),
            options: FlutterCarouselOptions(
              onPageChanged: (index, reason) {
                currentPage = index;
              },
            ),
          ),
        ),
      );

      await tester.drag(
          find.byType(PageView), const Offset(-400, 0)); // Simulate swipe
      await tester.pumpAndSettle();

      expect(currentPage, 1); // Page should have changed to 1
    });

    test('CarouselState and PageController integration', () {
      final options = FlutterCarouselOptions();
      final pageController = PageController();
      final carouselState = FlutterCarouselState(
        options,
        () {}, // onResetTimer
        () {}, // onResumeTimer
        (reason) {}, // changeMode
      );
      carouselState.pageController = pageController;

      expect(carouselState.pageController, isNotNull);
      expect(carouselState.pageController, equals(pageController));
    });

    test('CarouselState mode change integration', () {
      CarouselPageChangedReason? modeChangedReason;
      final carouselState = FlutterCarouselState(
        FlutterCarouselOptions(),
        () {}, // onResetTimer
        () {}, // onResumeTimer
        (reason) {
          modeChangedReason = reason;
        }, // changeMode
      );

      carouselState.changeMode(CarouselPageChangedReason.manual);
      expect(modeChangedReason, CarouselPageChangedReason.manual);
    });

    testWidgets('CarouselController and CarouselOptions integration',
        (WidgetTester tester) async {
      final options = FlutterCarouselOptions(autoPlay: true);
      final controller = FlutterCarouselControllerImpl();
      final state = FlutterCarouselState(
        options,
        () {}, // onResetTimer
        () {}, // onResumeTimer
        (reason) {}, // changeMode
      );

      // Initialize the PageController
      state.pageController = PageController(initialPage: state.initialPage);
      controller.state = state;

      // Build a PageView widget with the PageController
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PageView(
              controller: state.pageController,
              children: List.generate(3, (index) => Text('Page $index')),
            ),
          ),
        ),
      );

      // Capture the initial page
      final initialPage = state.pageController!.page;

      // Move to the next page
      controller.nextPage();
      await tester.pumpAndSettle();

      // Expect the pageController to navigate to the next page
      expect(state.pageController!.page, isNot(equals(initialPage)));

      // Expect the controller to interact with the state correctly
      expect(controller.ready, true);
    });

    testWidgets('CarouselController auto play functionality',
        (WidgetTester tester) async {
      final options = FlutterCarouselOptions(autoPlay: true);
      final controller = FlutterCarouselControllerImpl();
      final state = FlutterCarouselState(
        options,
        () {}, // onResetTimer
        () {}, // onResumeTimer
        (reason) {}, // changeMode
      );

      // Initialize the PageController
      state.pageController = PageController(initialPage: state.initialPage);
      controller.state = state;

      // Build a PageView widget with the PageController
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PageView(
              controller: state.pageController,
              children: List.generate(3, (index) => Text('Page $index')),
            ),
          ),
        ),
      );

      // Capture whether the onResumeTimer is called
      var isAutoPlayStarted = false;
      state.onResumeTimer = () {
        isAutoPlayStarted = true;
      };

      controller.startAutoPlay();
      await tester
          .pump(const Duration(seconds: 1)); // Allow time for autoPlay to start

      // Expect the timer to start
      expect(isAutoPlayStarted, true);

      // Capture whether the onResetTimer is called
      var isAutoPlayStopped = false;
      state.onResetTimer = () {
        isAutoPlayStopped = true;
      };

      controller.stopAutoPlay();
      await tester.pump(const Duration(
          seconds: 1)); // Allow time for stopAutoPlay to complete

      // Expect the timer to stop
      expect(isAutoPlayStopped, true);
    });
  });

  group("CarouselOptions Assertion Tests", () {
    testWidgets('viewportFraction should be between 0.0 and 1.0',
        (WidgetTester tester) async {
      expect(
        () => FlutterCarouselOptions(viewportFraction: 1.2),
        throwsAssertionError,
      );

      expect(
        () => FlutterCarouselOptions(viewportFraction: -0.1),
        throwsAssertionError,
      );
    });

    testWidgets('initialPage should be a non-negative integer',
        (WidgetTester tester) async {
      expect(
        () => FlutterCarouselOptions(initialPage: -1),
        throwsAssertionError,
      );
    });

    testWidgets('autoPlayInterval should be greater than zero',
        (WidgetTester tester) async {
      expect(
        () => FlutterCarouselOptions(autoPlayInterval: Duration.zero),
        throwsAssertionError,
      );
    });

    testWidgets('autoPlayAnimationDuration should be greater than zero',
        (WidgetTester tester) async {
      expect(
        () => FlutterCarouselOptions(autoPlayAnimationDuration: Duration.zero),
        throwsAssertionError,
      );
    });

    testWidgets('indicatorMargin should be a non-negative value',
        (WidgetTester tester) async {
      expect(
        () => FlutterCarouselOptions(indicatorMargin: -1.0),
        throwsAssertionError,
      );
    });

    testWidgets(
        'enlargeFactor should be greater than 0 when enlargeCenterPage is true',
        (WidgetTester tester) async {
      expect(
        () =>
            FlutterCarouselOptions(enlargeCenterPage: true, enlargeFactor: 0.0),
        throwsAssertionError,
      );

      expect(
        () => FlutterCarouselOptions(
            enlargeCenterPage: true, enlargeFactor: null),
        throwsAssertionError,
      );
    });

    testWidgets('enlargeFactor should be greater than 0.0',
        (WidgetTester tester) async {
      expect(
        () => FlutterCarouselOptions(enlargeFactor: 0.0),
        throwsAssertionError,
      );

      expect(
        () => FlutterCarouselOptions(enlargeFactor: -0.1),
        throwsAssertionError,
      );
    });
  });
}
