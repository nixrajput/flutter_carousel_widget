import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

List<Widget> tall(List<double> heights) => [
  for (final (i, h) in heights.indexed)
    SizedBox(key: ValueKey('h$i'), height: h, child: Text('$i')),
];

double heightOf(WidgetTester tester) =>
    tester.getSize(find.byType(PageView)).height;

void main() {
  testWidgets('sizes to the current item and follows the drag between two', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        ExpandableCarousel(
          items: tall([100, 300]),
          viewportFraction: 1,
          indicator: null,
          dragStartBehavior: DragStartBehavior.down,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(heightOf(tester), 100);
    final gesture = await tester.startGesture(const Offset(200, 50));
    await gesture.moveBy(const Offset(-200, 0)); // halfway
    await tester.pump();
    // Item 1 was measured in that frame and reports after it.
    await tester.pump();
    expect(heightOf(tester), closeTo(200, 0.5));
    await gesture.moveBy(const Offset(-200, 0));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(heightOf(tester), 300);
  });

  testWidgets('#60: going back after items are added keeps the old heights', (
    tester,
  ) async {
    final c = FlutterCarouselController();
    addTearDown(c.dispose);
    var heights = [200.0];
    late StateSetter set;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, s) {
            set = s;
            return ExpandableCarousel(
              items: tall(heights),
              viewportFraction: 1,
              controller: c,
              indicator: null,
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (var i = 0; i < 3; i++) {
      set(() => heights = [...heights, 120]);
      await tester.pump();
      unawaited(c.animateToPage(heights.length - 1));
      await tester.pumpAndSettle();
    }
    expect(heightOf(tester), 120);
    unawaited(c.animateToPage(0));
    await tester.pumpAndSettle();
    expect(heightOf(tester), 200);
  });

  testWidgets("#48: with padEnds false the last item's height is reached", (
    tester,
  ) async {
    final c = FlutterCarouselController();
    addTearDown(c.dispose);
    await tester.pumpWidget(
      host(
        ExpandableCarousel(
          items: tall([100, 100, 100, 400]),
          padEnds: false,
          controller: c,
          indicator: null,
        ),
      ),
    );
    await tester.pumpAndSettle();
    unawaited(c.animateToPage(3));
    await tester.pumpAndSettle();
    expect(heightOf(tester), 400);
  });

  testWidgets("#29: pages take the carousel's width, not the screen's", (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        ExpandableCarousel(
          items: [Container(key: const Key('c'), height: 50)],
          viewportFraction: 1,
        ),
        width: 300,
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byKey(const Key('c'))).width, 300);
  });

  testWidgets('#29: a small image fills the page width instead of centring', (
    tester,
  ) async {
    late ui.Image image;
    await tester.runAsync(() async {
      final recorder = ui.PictureRecorder();
      Canvas(recorder).drawRect(
        const Rect.fromLTWH(0, 0, 10, 20),
        Paint()..color = const Color(0xFF000000),
      );
      final picture = recorder.endRecording();
      image = await picture.toImage(10, 20);
      picture.dispose();
    });
    addTearDown(image.dispose);
    await tester.pumpWidget(
      host(
        ExpandableCarousel(
          items: [RawImage(image: image)],
          viewportFraction: 1,
        ),
        width: 300,
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(RawImage)), const Size(300, 600));
  });

  testWidgets('estimatedPageSize holds the first frame, then the real size', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        ExpandableCarousel(
          items: tall([250]),
          estimatedPageSize: 90,
          indicator: null,
        ),
      ),
    );
    expect(heightOf(tester), 90);
    await tester.pumpAndSettle();
    expect(heightOf(tester), 250);
  });

  testWidgets('a vertical carousel measures width', (tester) async {
    await tester.pumpWidget(
      host(
        const Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            height: 300,
            child: ExpandableCarousel(
              scrollDirection: Axis.vertical,
              viewportFraction: 1,
              indicator: null,
              items: [SizedBox(width: 150, height: 40)],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(PageView)).width, 150);
  });

  testWidgets('a below indicator adds its height under the measured page', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        ExpandableCarousel(
          items: tall([100, 100]),
          indicator: const CarouselIndicator(
            placement: CarouselIndicatorPlacement.below,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    // 100 page + 8 margin + 12 dots + 8 margin.
    expect(tester.getSize(find.byType(ExpandableCarousel)).height, 128);
  });

  testWidgets('zero items lay out at size 0', (tester) async {
    await tester.pumpWidget(
      host(const ExpandableCarousel(items: [], infinite: true)),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(ExpandableCarousel)).height, 0);
  });

  // Review Focus 2.
  testWidgets('items shrinking below the current one drop their sizes', (
    tester,
  ) async {
    var heights = <double>[100, 200, 300, 400];
    late StateSetter set;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, s) {
            set = s;
            return ExpandableCarousel(
              items: tall(heights),
              viewportFraction: 1,
              initialPage: 3,
              indicator: null,
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    set(() => heights = [100, 200]);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(heightOf(tester), 200);
  });

  testWidgets('a keyed item that moves keeps its height', (tester) async {
    var items = [('a', 100.0), ('b', 200.0), ('c', 300.0)];
    late StateSetter set;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, s) {
            set = s;
            return ExpandableCarousel(
              viewportFraction: 1,
              indicator: null,
              initialPage: 2,
              items: [
                for (final (k, h) in items)
                  SizedBox(key: ValueKey(k), height: h, child: Text(k)),
              ],
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    set(() => items = [('b', 200), ('c', 300)]);
    await tester.pumpAndSettle();
    expect(find.text('c'), findsOneWidget);
    expect(heightOf(tester), 300);
  });

  testWidgets('a vertical carousel with no height bound says so', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const SingleChildScrollView(
          child: ExpandableCarousel(
            scrollDirection: Axis.vertical,
            items: [SizedBox(width: 100, height: 40)],
          ),
        ),
      ),
    );
    final error = tester.takeException();
    expect(error, isA<FlutterError>());
    expect('$error', contains('needs a bounded height'));
  });

  testWidgets(
    'a carousel narrower than its parent keeps its dots on its items',
    (tester) async {
      await tester.pumpWidget(
        host(
          const SizedBox(
            width: 400,
            height: 300,
            child: ExpandableCarousel(
              scrollDirection: Axis.vertical,
              viewportFraction: 1,
              items: [
                SizedBox(width: 150, height: 40),
                SizedBox(width: 150, height: 40),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final pages = tester.getRect(find.byType(PageView));
      final dots = tester.getRect(find.byType(CustomPaint).last);
      expect(pages.width, 150);
      expect(
        pages.right - dots.right,
        8,
        reason: 'dots at the pages, not the parent',
      );
      expect(
        pages.center.dx,
        200,
        reason: 'the pages centre in the extra width',
      );
    },
  );
}
