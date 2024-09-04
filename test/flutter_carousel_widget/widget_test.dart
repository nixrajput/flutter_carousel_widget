import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlutterCarousel Widget Tests', () {
    testWidgets('Carousel should render correctly with default options',
        (WidgetTester tester) async {
      // Build the widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterCarousel(
              options: CarouselOptions(
                scrollDirection: Axis.vertical,
                height: 300,
                initialPage: 0, // Ensure initialPage is set correctly
              ),
              items: [const Text('Page 1'), const Text('Page 2')],
            ),
          ),
        ),
      );

      // Debug print statement
      print('Initial widget state: ${find.byType(FlutterCarousel)}');

      // Check initial state
      expect(find.text('Page 1'), findsOneWidget);
      expect(find.text('Page 2'), findsNothing);

      // Perform the drag to change the page
      await tester.drag(find.byType(FlutterCarousel), const Offset(0, -300));
      await tester.pumpAndSettle();

      // Debug print statement
      print('After dragging: ${find.byType(FlutterCarousel)}');

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
              options: CarouselOptions(
                height: 300,
                showIndicator: true,
              ),
              items: [const Text('Page 1'), const Text('Page 2')],
            ),
          ),
        ),
      );

      expect(find.byType(SlideIndicator), findsOneWidget);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FlutterCarousel(
              options: CarouselOptions(
                height: 300,
                showIndicator: false,
              ),
              items: [const Text('Page 1'), const Text('Page 2')],
            ),
          ),
        ),
      );

      expect(find.byType(SlideIndicator), findsNothing);
    });

    testWidgets('Carousel should render correctly with initial page option',
        (WidgetTester tester) async {
      // Arrange
      const initialPage = 2;
      await tester.pumpWidget(
        MaterialApp(
          home: FlutterCarousel(
            items: List<Widget>.generate(5, (index) => Text('Item $index')),
            options: CarouselOptions(initialPage: initialPage),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Item $initialPage'), findsOneWidget);
    });
  });
}
