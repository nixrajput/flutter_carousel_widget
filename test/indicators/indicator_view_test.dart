import 'dart:async';
import 'dart:ui' show Tristate;

import 'package:flutter/gestures.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_carousel_widget/src/indicators/indicator_view.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

/// Records the geometry it is asked to paint.
class Spy extends SlideIndicator {
  const Spy(this.seen);

  final List<SlideIndicatorGeometry> seen;

  @override
  void paint(Canvas canvas, Size size, SlideIndicatorGeometry geometry) =>
      seen.add(geometry);
}

/// A painter that equals every other instance, like a const default one.
class _EqualSpy extends SlideIndicator {
  const _EqualSpy();

  static final seen = <SlideIndicatorGeometry>[];

  @override
  void paint(Canvas canvas, Size size, SlideIndicatorGeometry geometry) =>
      seen.add(geometry);

  @override
  bool operator ==(Object other) => other is _EqualSpy;

  @override
  int get hashCode => 0;
}

void main() {
  testWidgets('#62: the indicator follows the drag, no frame late', (
    tester,
  ) async {
    final seen = <SlideIndicatorGeometry>[];
    await tester.pumpWidget(
      host(
        FlutterCarousel(
          items: boxes(3),
          height: 100,
          viewportFraction: 1,
          dragStartBehavior: DragStartBehavior.down,
          indicator: CarouselIndicator(painter: Spy(seen)),
        ),
      ),
    );
    final gesture = await tester.startGesture(const Offset(200, 50));
    await gesture.moveBy(const Offset(-360, 0));
    await tester.pump();
    expect(seen.last.position, closeTo(0.9, 1e-6));
    expect(seen.last.nearest, 1);
    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('#66: under RTL the first dot sits on the right', (tester) async {
    final seen = <SlideIndicatorGeometry>[];
    await tester.pumpWidget(
      host(
        FlutterCarousel(
          items: boxes(3),
          height: 100,
          indicator: CarouselIndicator(painter: Spy(seen)),
        ),
        textDirection: TextDirection.rtl,
      ),
    );
    expect(seen.last.flipped, isTrue);
    await tester.pumpWidget(
      host(
        FlutterCarousel(
          items: boxes(3),
          height: 100,
          reverse: true,
          indicator: CarouselIndicator(painter: Spy(seen)),
        ),
        textDirection: TextDirection.rtl,
      ),
    );
    expect(seen.last.flipped, isFalse);
  });

  testWidgets('tapping a dot moves there, reported as manual', (tester) async {
    final changes = <(int, CarouselPageChangedReason)>[];
    await tester.pumpWidget(
      host(
        FlutterCarousel(
          items: boxes(5),
          height: 100,
          onPageChanged: (i, r) => changes.add((i, r)),
        ),
      ),
    );
    final dots = tester.getRect(
      find.descendant(
        of: find.byKey(const ValueKey('default_indicator')),
        matching: find.byType(CustomPaint),
      ),
    );
    // Dot 3: radius 6, spacing 24, so its centre is 78 px in.
    await tester.tapAt(Offset(dots.left + 78, dots.center.dy));
    await tester.pumpAndSettle();
    expect(changes.last, (3, CarouselPageChangedReason.manual));
  });

  testWidgets('each dot is a 24 by 48 target, however small it is drawn', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      host(FlutterCarousel(items: boxes(5), height: 100)),
    );
    for (var i = 1; i <= 5; i++) {
      final dot = find.semantics.byLabel('Slide $i of 5').evaluate().single;
      expect(dot.rect.size, const Size(24, 48), reason: 'dot $i');
    }
    handle.dispose();
  });

  testWidgets('a vertical carousel turns the targets to 48 by 24', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        FlutterCarousel(
          items: boxes(3),
          height: 300,
          scrollDirection: Axis.vertical,
        ),
      ),
    );
    final dot = find.semantics.byLabel('Slide 2 of 3').evaluate().single;
    expect(dot.rect.size, const Size(48, 24));
    handle.dispose();
  });

  testWidgets('a tap in the band above a dot moves to it', (tester) async {
    final c = FlutterCarouselController();
    addTearDown(c.dispose);
    await tester.pumpWidget(
      host(FlutterCarousel(items: boxes(5), height: 100, controller: c)),
    );
    final dots = tester.getRect(
      find.descendant(
        of: find.byKey(const ValueKey('default_indicator')),
        matching: find.byType(CustomPaint),
      ),
    );
    // Above what the dots draw, inside the band that grows towards the items.
    await tester.tapAt(Offset(dots.left + 78, dots.top - 20));
    await tester.pumpAndSettle();
    expect(c.index, 3);
  });

  testWidgets('a tap above the band reaches the items, not the dots', (
    tester,
  ) async {
    final c = FlutterCarouselController();
    addTearDown(c.dispose);
    var tapped = 0;
    await tester.pumpWidget(
      host(
        FlutterCarousel.builder(
          itemCount: 5,
          itemBuilder: (context, i, _) => GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => tapped++,
            child: const SizedBox.expand(),
          ),
          height: 100,
          controller: c,
        ),
      ),
    );
    final dots = tester.getRect(
      find.descendant(
        of: find.byKey(const ValueKey('default_indicator')),
        matching: find.byType(CustomPaint),
      ),
    );
    await tester.tapAt(Offset(dots.left + 78, dots.top - 40));
    await tester.pumpAndSettle();
    expect(c.index, 0);
    expect(tapped, 1);
  });

  testWidgets('tapToNavigate false leaves taps to the items', (tester) async {
    final c = FlutterCarouselController();
    addTearDown(c.dispose);
    await tester.pumpWidget(
      host(
        FlutterCarousel(
          items: boxes(5),
          height: 100,
          controller: c,
          indicator: const CarouselIndicator(tapToNavigate: false),
        ),
      ),
    );
    final dots = tester.getRect(find.byType(CustomPaint).last);
    await tester.tapAt(Offset(dots.left + 78, dots.center.dy));
    await tester.pumpAndSettle();
    expect(c.index, 0);
  });

  testWidgets('dots are labelled buttons, the current one selected', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      host(FlutterCarousel(items: boxes(3), height: 100)),
    );
    // Painter semantics belong to no widget, so a semantics finder reaches them.
    SemanticsNode dot(String label) =>
        find.semantics.byLabel(label).evaluate().single;
    expect(dot('Slide 2 of 3').flagsCollection.isButton, isTrue);
    expect(dot('Slide 1 of 3').flagsCollection.isSelected, Tristate.isTrue);
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    final c = tester.widget<PageView>(find.byType(PageView)).controller!;
    c.jumpToPage(2);
    await tester.pump();
    expect(dot('Slide 3 of 3').flagsCollection.isSelected, Tristate.isTrue);
    handle.dispose();
  });

  testWidgets('a below indicator sits under the items; a halo draws behind', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        FlutterCarousel(
          items: boxes(3),
          height: 100,
          indicator: const CarouselIndicator(
            placement: CarouselIndicatorPlacement.below,
            painter: CircularSlideIndicator(
              style: SlideIndicatorStyle(
                halo: BoxDecoration(color: Color(0x33000000)),
              ),
            ),
          ),
        ),
      ),
    );
    final pages = tester.getRect(find.byType(PageView));
    final halo = tester.getRect(find.byType(DecoratedBox).last);
    expect(halo.top, greaterThanOrEqualTo(pages.bottom));
    expect(halo.height, 12 + 16);
  });

  testWidgets('a vertical carousel stacks its dots', (tester) async {
    final seen = <SlideIndicatorGeometry>[];
    await tester.pumpWidget(
      host(
        FlutterCarousel(
          items: boxes(3),
          height: 300,
          scrollDirection: Axis.vertical,
          indicator: CarouselIndicator(
            painter: Spy(seen),
            alignment: Alignment.centerRight,
          ),
        ),
      ),
    );
    expect(seen.last.axis, Axis.vertical);
    expect(tester.getSize(find.byType(CustomPaint).last), const Size(12, 60));
  });

  testWidgets('a controller move repaints the dots through the scroll alone', (
    tester,
  ) async {
    final seen = <SlideIndicatorGeometry>[];
    final c = FlutterCarouselController();
    addTearDown(c.dispose);
    await tester.pumpWidget(
      host(
        FlutterCarousel(
          items: boxes(3),
          height: 100,
          controller: c,
          indicator: CarouselIndicator(painter: Spy(seen)),
        ),
      ),
    );
    seen.clear();
    unawaited(c.nextPage());
    await tester.pumpAndSettle();
    expect(seen.length, greaterThan(2));
    expect(seen.last.position, 1);
  });

  testWidgets('a vertical carousel puts its dots at the end, centred', (
    tester,
  ) async {
    for (final dir in TextDirection.values) {
      await tester.pumpWidget(
        host(
          FlutterCarousel(
            key: ValueKey(dir),
            items: boxes(3),
            height: 300,
            scrollDirection: Axis.vertical,
          ),
          textDirection: dir,
        ),
      );
      final pages = tester.getRect(find.byType(PageView));
      final dots = tester.getRect(
        find.descendant(
          of: find.byType(IndicatorView),
          matching: find.byType(CustomPaint),
        ),
      );
      expect(dots.center.dy, closeTo(pages.center.dy, 0.5), reason: '$dir');
      if (dir == TextDirection.ltr) {
        expect(pages.right - dots.right, 8, reason: 'margin from the end');
      } else {
        expect(dots.left - pages.left, 8, reason: 'margin from the end');
      }
    }
  });

  testWidgets('a below indicator sits beside a vertical carousel, at the end', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const FlutterCarousel(
          items: [SizedBox(), SizedBox(), SizedBox()],
          height: 300,
          scrollDirection: Axis.vertical,
          indicator: CarouselIndicator(
            placement: CarouselIndicatorPlacement.below,
          ),
        ),
      ),
    );
    final pages = tester.getRect(find.byType(PageView));
    final dots = tester.getRect(find.byType(IndicatorView));
    expect(dots.left, greaterThanOrEqualTo(pages.right));
    expect(dots.center.dy, closeTo(pages.center.dy, 0.5));
  });

  testWidgets('the dots repaint when reverse flips them, without a scroll', (
    tester,
  ) async {
    Widget carousel({required bool reverse}) => host(
      FlutterCarousel(
        items: boxes(3),
        height: 100,
        reverse: reverse,
        indicator: const CarouselIndicator(painter: _EqualSpy()),
      ),
    );
    CustomPainter dots() => tester
        .widget<CustomPaint>(
          find.descendant(
            of: find.byType(IndicatorView),
            matching: find.byType(CustomPaint),
          ),
        )
        .painter!;
    await tester.pumpWidget(carousel(reverse: false));
    final before = dots();
    expect(_EqualSpy.seen.last.flipped, isFalse);
    await tester.pumpWidget(carousel(reverse: true));
    expect(_EqualSpy.seen.last.flipped, isTrue);
    // Repainting must not rely on the pages repainting in the same layer.
    expect(dots().shouldRepaint(before), isTrue);
  });

  testWidgets('a screen reader taps a dot to move there, reported as manual', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final changes = <(int, CarouselPageChangedReason)>[];
    await tester.pumpWidget(
      host(
        FlutterCarousel(
          items: boxes(5),
          height: 100,
          onPageChanged: (i, r) => changes.add((i, r)),
        ),
      ),
    );
    tester.semantics.performAction(
      find.semantics.byLabel('Slide 3 of 5'),
      SemanticsAction.tap,
    );
    await tester.pumpAndSettle();
    expect(changes.last, (2, CarouselPageChangedReason.manual));
    handle.dispose();
  });

  testWidgets('with tapToNavigate off, the dots are labels of their own size', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        FlutterCarousel(
          items: boxes(5),
          height: 100,
          indicator: const CarouselIndicator(tapToNavigate: false),
        ),
      ),
    );
    final dot = find.semantics.byLabel('Slide 2 of 5').evaluate().single;
    expect(dot.flagsCollection.isButton, isFalse);
    expect(dot.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);
    expect(dot.rect.size, const Size(24, 12), reason: 'no tap band');
    handle.dispose();
  });

  testWidgets(
    'with tapToNavigate off, a tap just above a dot reaches the item',
    (tester) async {
      final c = FlutterCarouselController();
      addTearDown(c.dispose);
      var tapped = 0;
      await tester.pumpWidget(
        host(
          FlutterCarousel.builder(
            itemCount: 5,
            itemBuilder: (context, i, _) => GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => tapped++,
              child: const SizedBox.expand(),
            ),
            height: 100,
            controller: c,
            indicator: const CarouselIndicator(tapToNavigate: false),
          ),
        ),
      );
      final dots = tester.getRect(find.byType(CustomPaint).last);
      await tester.tapAt(Offset(dots.left + 78, dots.top - 10));
      await tester.pumpAndSettle();
      expect((c.index, tapped), (0, 1));
    },
  );
}
