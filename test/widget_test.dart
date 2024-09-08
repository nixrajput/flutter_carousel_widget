import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlutterCarousel Widget Tests', () {
    testWidgets(
        'Carousel should render correctly with options and page changes on drag',
        (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterCarousel(
              options: FlutterCarouselOptions(
                viewportFraction: 1.0,
                height: 400,
                initialPage: 0,
              ),
              items: [
                const SizedBox(child: Text('Page 1')),
                const SizedBox(child: Text('Page 2'))
              ],
            ),
          ),
        ),
      );

      // Check initial state
      expect(find.text('Page 1'), findsOneWidget);
      expect(find.text('Page 2'), findsNothing);

      // Perform the horizontal drag to change the page
      final screenWidth = tester.view.physicalSize.width;
      await tester.drag(find.byType(FlutterCarousel), Offset(-screenWidth, 0));
      await tester.pumpAndSettle();

      // Verify the page has changed
      expect(find.text('Page 1'), findsNothing);
      expect(find.text('Page 2'), findsOneWidget);
    });

    testWidgets('Carousel should show or hide indicator based on options',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterCarousel(
              options: FlutterCarouselOptions(
                height: 400,
                showIndicator: true,
              ),
              items: [
                const SizedBox(child: Text('Page 1')),
                const SizedBox(child: Text('Page 2'))
              ],
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('default_indicator')), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterCarousel(
              options: FlutterCarouselOptions(
                height: 400,
                showIndicator: false,
              ),
              items: [
                const SizedBox(child: Text('Page 1')),
                const SizedBox(child: Text('Page 2'))
              ],
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('default_indicator')), findsNothing);
    });

    testWidgets('Carousel should render correctly with initial page option',
        (WidgetTester tester) async {
      // Arrange
      const initialPage = 2;
      await tester.pumpWidget(
        MaterialApp(
          home: FlutterCarousel(
            items: List<Widget>.generate(
                5, (index) => SizedBox(child: Text('Item $index'))),
            options: FlutterCarouselOptions(initialPage: initialPage),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Item $initialPage'), findsOneWidget);
    });

    testWidgets('Carousel should auto-play and change pages',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterCarousel(
              options: FlutterCarouselOptions(
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 1),
                viewportFraction: 1.0,
              ),
              items: [
                const SizedBox(child: Text('Page 1')),
                const SizedBox(child: Text('Page 2')),
                const SizedBox(child: Text('Page 3')),
              ],
            ),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('Page 2'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('Page 3'), findsOneWidget);
    });

    testWidgets('Carousel should pause auto-play on user interaction',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterCarousel(
              options: FlutterCarouselOptions(
                autoPlay: true,
                autoPlayInterval: const Duration(seconds: 2),
                pauseAutoPlayOnTouch: true,
              ),
              items: [
                const SizedBox(child: Text('Page 1')),
                const SizedBox(child: Text('Page 2')),
                const SizedBox(child: Text('Page 3')),
              ],
            ),
          ),
        ),
      );

      await tester.pump(const Duration(seconds: 1));
      await tester.tap(find.byType(FlutterCarousel));
      await tester.pump(const Duration(seconds: 2));

      expect(find.text('Page 2'),
          findsOneWidget); // Shouldn't move to the next page
    });

    testWidgets('Carousel should support reverse scrolling',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterCarousel(
              options: FlutterCarouselOptions(
                viewportFraction: 1.0,
                reverse: true,
              ),
              items: [
                const SizedBox(child: Text('Page 1')),
                const SizedBox(child: Text('Page 2')),
                const SizedBox(child: Text('Page 3')),
                const SizedBox(child: Text('Page 4')),
              ],
            ),
          ),
        ),
      );

      final screenWidth = tester.view.physicalSize.width;
      await tester.drag(find.byType(FlutterCarousel), Offset(screenWidth, 0));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.text('Page 4'), findsOneWidget);
    });

    testWidgets('Carousel should maintain page position when keepPage is true',
        (WidgetTester tester) async {
      final controller = FlutterCarouselController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterCarousel(
              options: FlutterCarouselOptions(
                viewportFraction: 1.0,
                keepPage: true,
                controller: controller,
              ),
              items: [
                const SizedBox(child: Text('Page 1')),
                const SizedBox(child: Text('Page 2')),
                const SizedBox(child: Text('Page 3')),
              ],
            ),
          ),
        ),
      );

      controller.nextPage();
      await tester.pumpAndSettle();
      expect(find.text('Page 2'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterCarousel(
              options: FlutterCarouselOptions(
                viewportFraction: 1.0,
                keepPage: true,
                controller: controller,
              ),
              items: [
                const SizedBox(child: Text('Page 1')),
                const SizedBox(child: Text('Page 2')),
                const SizedBox(child: Text('Page 3')),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Page 2'), findsOneWidget);
    });

    testWidgets('CarouselController should control page navigation',
        (WidgetTester tester) async {
      final controller = FlutterCarouselController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterCarousel(
              options: FlutterCarouselOptions(
                viewportFraction: 1.0,
                height: 400,
                initialPage: 0,
                controller: controller,
              ),
              items: [
                const SizedBox(child: Text('Page 1')),
                const SizedBox(child: Text('Page 2')),
                const SizedBox(child: Text('Page 3')),
                const SizedBox(child: Text('Page 4')),
                const SizedBox(child: Text('Page 5')),
              ],
            ),
          ),
        ),
      );

      controller.animateToPage(2);
      await tester.pumpAndSettle();
      expect(find.text('Page 3'), findsOneWidget);

      controller.previousPage();
      await tester.pumpAndSettle();
      expect(find.text('Page 2'), findsOneWidget);

      controller.nextPage();
      await tester.pumpAndSettle();
      expect(find.text('Page 3'), findsOneWidget);
    });

    testWidgets('Carousel should support vertical scrolling',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterCarousel(
              options: FlutterCarouselOptions(
                scrollDirection: Axis.vertical,
                viewportFraction: 1.0,
              ),
              items: [
                const Text('Page 1'),
                const Text('Page 2'),
                const Text('Page 3'),
              ],
            ),
          ),
        ),
      );

      // Ensure widgets are rendered before performing any action
      await tester.pumpAndSettle();

      final screenHeight = tester.view.physicalSize.height;
      await tester.drag(
        find.byType(FlutterCarousel),
        Offset(0, -screenHeight * 0.5),
      );
      await tester.pumpAndSettle();

      // Assert Page 2 is displayed after the drag
      expect(find.text('Page 2'), findsOneWidget);
    });

    testWidgets(
        'Carousel should support snapping when pageSnapping is true and false',
        (WidgetTester tester) async {
      final screenWidth = tester.view.physicalSize.width;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterCarousel(
              key: const ValueKey('page_snapping_true_carousel'),
              options: FlutterCarouselOptions(
                viewportFraction: 1.0,
                pageSnapping: true,
              ),
              items: [
                const SizedBox(child: Text('Page 1')),
                const SizedBox(child: Text('Page 2')),
                const SizedBox(child: Text('Page 3')),
              ],
            ),
          ),
        ),
      );

      // Ensure widgets are rendered before performing any action
      await tester.pumpAndSettle();

      await tester.drag(
        find.byKey(const ValueKey('page_snapping_true_carousel')),
        Offset(-screenWidth * 0.25, 0),
      );

      // Ensure all animations settle
      await tester.pumpAndSettle();

      // Debug output to check if Page 2 is found
      final page2Finder = find.text('Page 2');
      print('Page 2 found: ${page2Finder.evaluate().isNotEmpty}');

      // Assert Page 2 is displayed after the drag
      expect(find.text('Page 2'), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterCarousel(
              key: const ValueKey('page_snapping_false_carousel'),
              options: FlutterCarouselOptions(
                viewportFraction: 1.0,
                pageSnapping: false,
              ),
              items: [
                const SizedBox(child: Text('Page 1')),
                const SizedBox(child: Text('Page 2')),
                const SizedBox(child: Text('Page 3')),
              ],
            ),
          ),
        ),
      );

      // Ensure widgets are rendered before performing any action
      await tester.pumpAndSettle();

      await tester.drag(
        find.byKey(const ValueKey('page_snapping_false_carousel')),
        Offset(-screenWidth * 0.25, 0),
      );

      // Ensure all animations settle
      await tester.pumpAndSettle();

      // Shouldn't snap to the next page, so Page 1
      // should still be partially visible
      expect(find.text('Page 1'), findsOneWidget);
      expect(find.text('Page 2'), findsOneWidget);
    });
  });
}
