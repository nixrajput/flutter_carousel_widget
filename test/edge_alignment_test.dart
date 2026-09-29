import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  // 400 wide, viewportFraction 0.8: each page is 320, the side gap 40.
  Future<FlutterCarouselController> flush(
    WidgetTester tester, {
    double fraction = 0.8,
  }) async {
    final c = FlutterCarouselController();
    addTearDown(c.dispose);
    await tester.pumpWidget(
      host(
        FlutterCarousel(
          items: boxes(5, keyed: true),
          height: 100,
          viewportFraction: fraction,
          controller: c,
          edgeAlignment: CarouselEdgeAlignment.flush,
          indicator: null,
        ),
      ),
    );
    await tester.pumpAndSettle();
    return c;
  }

  Rect item(WidgetTester tester, int i) =>
      tester.getRect(find.byKey(ValueKey(i)));

  testWidgets('#58: the first item is flush with the leading edge', (
    tester,
  ) async {
    await flush(tester);
    expect(item(tester, 0).left, 0);
  });

  testWidgets('#58: middle items are centred, the last flush at the end', (
    tester,
  ) async {
    final c = await flush(tester);
    unawaited(c.animateToPage(2));
    await tester.pumpAndSettle();
    expect(item(tester, 2).left, 40);
    expect(item(tester, 2).right, 360);
    unawaited(c.animateToPage(4));
    await tester.pumpAndSettle();
    expect(item(tester, 4).right, 400);
    expect((c.index, c.position), (4, 4.0));
  });

  testWidgets('#58: a drag snaps to the next item and reports it', (
    tester,
  ) async {
    final c = await flush(tester);
    await tester.drag(find.byType(PageView), const Offset(-200, 0));
    await tester.pumpAndSettle();
    expect(c.index, 1);
    expect(item(tester, 1).left, 40);
  });

  testWidgets('#58: indices stay right with narrow pages', (tester) async {
    final c = await flush(tester, fraction: 0.4);
    expect(c.index, 0);
    unawaited(c.animateToPage(1));
    await tester.pumpAndSettle();
    expect(c.index, 1);
    unawaited(c.animateToPage(4));
    await tester.pumpAndSettle();
    expect((c.index, item(tester, 4).right), (4, 400));
  });

  testWidgets('flush is ignored when infinite', (tester) async {
    await tester.pumpWidget(
      host(
        FlutterCarousel(
          items: boxes(5, keyed: true),
          height: 100,
          infinite: true,
          edgeAlignment: CarouselEdgeAlignment.flush,
          indicator: null,
        ),
      ),
    );
    expect(item(tester, 0).left, 40);
  });

  testWidgets('#58: nextPage steps one item from a flush edge, narrow pages', (
    tester,
  ) async {
    final c = await flush(tester, fraction: 0.4);
    unawaited(c.nextPage());
    await tester.pumpAndSettle();
    expect(c.index, 1);
  });

  testWidgets('#58: effects see a settled flush item at offset 0', (
    tester,
  ) async {
    final offsets = <int, double>{};
    await tester.pumpWidget(
      host(
        FlutterCarousel(
          items: boxes(5, keyed: true),
          height: 100,
          edgeAlignment: CarouselEdgeAlignment.flush,
          indicator: null,
          effect: CarouselEffect.builder((context, p, child) {
            offsets[p.index] = p.offset;
            return child;
          }),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(offsets[0], closeTo(0, 1e-9));
  });

  testWidgets('#58: pages too narrow to settle apart fall back to centred', (
    tester,
  ) async {
    final changes = <int>[];
    final c = FlutterCarouselController();
    addTearDown(c.dispose);
    await tester.pumpWidget(
      host(
        FlutterCarousel(
          items: boxes(5, keyed: true),
          height: 100,
          viewportFraction: 0.25,
          controller: c,
          edgeAlignment: CarouselEdgeAlignment.flush,
          indicator: null,
          onPageChanged: (i, _) => changes.add(i),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(c.index, 0);
    expect(changes, isEmpty);
    unawaited(c.nextPage());
    await tester.pumpAndSettle();
    expect(c.index, 1);
  });

  testWidgets('#58: a new viewportFraction keeps the flush item', (
    tester,
  ) async {
    final c = FlutterCarouselController();
    addTearDown(c.dispose);
    var fraction = 0.8;
    late StateSetter set;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, s) {
            set = s;
            return FlutterCarousel(
              items: boxes(6, keyed: true),
              height: 100,
              viewportFraction: fraction,
              controller: c,
              edgeAlignment: CarouselEdgeAlignment.flush,
              indicator: null,
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    unawaited(c.animateToPage(3));
    await tester.pumpAndSettle();
    set(() => fraction = 0.5);
    await tester.pumpAndSettle();
    expect(c.index, 3);
  });

  testWidgets('switching from flush back to centre re-centres the item', (
    tester,
  ) async {
    Widget carousel(CarouselEdgeAlignment edges) => host(
      FlutterCarousel(
        items: boxes(5, keyed: true),
        height: 100,
        viewportFraction: 0.8,
        edgeAlignment: edges,
        indicator: null,
      ),
    );
    await tester.pumpWidget(carousel(CarouselEdgeAlignment.flush));
    await tester.pumpAndSettle();
    expect(item(tester, 0).left, 0);
    await tester.pumpWidget(carousel(CarouselEdgeAlignment.center));
    await tester.pumpAndSettle();
    expect(item(tester, 0).left, closeTo(40, 1e-9));
  });
}
