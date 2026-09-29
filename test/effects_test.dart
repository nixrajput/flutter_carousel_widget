import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

CarouselItemPosition at(
  double offset, {
  Axis axis = Axis.horizontal,
  TextDirection dir = TextDirection.ltr,
}) => CarouselItemPosition(
  index: 0,
  itemCount: 3,
  offset: offset,
  axis: axis,
  textDirection: dir,
  reverse: false,
  viewportFraction: 1,
  extent: const Size(400, 200),
);

Future<void> show(
  WidgetTester tester,
  CarouselEffect effect,
  CarouselItemPosition p, {
  Widget child = const SizedBox(width: 400, height: 200),
}) => tester.pumpWidget(
  Directionality(
    textDirection: TextDirection.ltr,
    child: Center(
      child: SizedBox(
        width: 400,
        height: 200,
        child: Builder(builder: (context) => effect.apply(context, p, child)),
      ),
    ),
  ),
);

double opacity(WidgetTester tester) =>
    tester.widget<Opacity>(find.byType(Opacity)).opacity;

Matrix4 matrix(WidgetTester tester) =>
    tester.widget<Transform>(find.byType(Transform).first).transform;

/// The x scale of the first transform.
double scaleX(WidgetTester tester) => matrix(tester).entry(0, 0);

/// The transform that turns the item, skipping plain translates and scales.
Matrix4 rotation(WidgetTester tester) => tester
    .widgetList<Transform>(find.byType(Transform))
    .map((t) => t.transform)
    .firstWhere((m) => m.entry(0, 2) != 0 || m.entry(1, 2) != 0);

Offset translation(WidgetTester tester) {
  final t = tester.widget<Transform>(find.byType(Transform).first).transform;
  return Offset(t.getTranslation().x, t.getTranslation().y);
}

void main() {
  testWidgets('enlarge keeps the centre full size, eased like 3.x', (
    tester,
  ) async {
    const effect = CarouselEffect.enlarge();
    await show(tester, effect, at(0));
    expect(scaleX(tester), 1);
    await show(tester, effect, at(1));
    final side = Curves.easeOut.transform(0.75);
    expect(scaleX(tester), closeTo(side, 1e-9));
    await show(tester, effect, at(-1));
    expect(scaleX(tester), closeTo(side, 1e-9));
  });

  testWidgets('enlarge height shortens across the axis; zoom leans in', (
    tester,
  ) async {
    await show(
      tester,
      const CarouselEffect.enlarge(strategy: CarouselEnlargeStrategy.height),
      at(1),
    );
    final box = tester.widget<FractionallySizedBox>(
      find.byType(FractionallySizedBox),
    );
    expect(box.heightFactor, closeTo(Curves.easeOut.transform(0.75), 1e-9));
    expect(box.widthFactor, isNull);
    const zoom = CarouselEffect.enlarge(strategy: CarouselEnlargeStrategy.zoom);
    await show(tester, zoom, at(-1));
    expect(
      tester.widget<Transform>(find.byType(Transform)).alignment,
      Alignment.centerRight,
    );
    await show(tester, zoom, at(-1, dir: TextDirection.rtl));
    expect(
      tester.widget<Transform>(find.byType(Transform)).alignment,
      Alignment.centerLeft,
    );
  });

  testWidgets('fade runs from opaque to minOpacity over one item', (
    tester,
  ) async {
    const effect = CarouselEffect.fade(minOpacity: 0.2);
    for (final (offset, expected) in [
      (0.0, 1.0),
      (0.5, 0.6),
      (1.0, 0.2),
      (-2.0, 0.2),
    ]) {
      await show(tester, effect, at(offset));
      expect(opacity(tester), closeTo(expected, 1e-9), reason: '$offset');
    }
  });

  testWidgets('parallax shifts the content against the motion, clipped', (
    tester,
  ) async {
    await show(tester, const CarouselEffect.parallax(depth: 0.2), at(1));
    expect(find.byType(ClipRect), findsOneWidget);
    // Half the extra width, the other way: -1 * 0.2 * 400 / 2.
    expect(translation(tester).dx, closeTo(-40, 1e-9));
    await show(
      tester,
      const CarouselEffect.parallax(depth: 0.2),
      at(1, dir: TextDirection.rtl),
    );
    expect(translation(tester).dx, closeTo(40, 1e-9));
  });

  testWidgets('depth holds the next item in place and fades it in', (
    tester,
  ) async {
    const effect = CarouselEffect.depth(minScale: 0.5);
    await show(tester, effect, at(-0.5));
    expect(opacity(tester), 1, reason: 'the leaving item slides normally');
    expect(translation(tester), Offset.zero);
    await show(tester, effect, at(0.5));
    expect(opacity(tester), closeTo(0.5, 1e-9));
    expect(translation(tester).dx, closeTo(-200, 1e-9));
  });

  testWidgets('zoomOut shrinks and dims the neighbours', (tester) async {
    await show(tester, const CarouselEffect.zoomOut(), at(1));
    expect(opacity(tester), closeTo(0.5, 1e-9));
    expect(scaleX(tester), closeTo(0.85, 1e-9));
  });

  testWidgets('stack holds the previous item under the incoming one', (
    tester,
  ) async {
    const effect = CarouselEffect.stack(offset: 20, minScale: 0.8);
    await show(tester, effect, at(0.5));
    expect(translation(tester), Offset.zero, reason: 'incoming slides over');
    await show(tester, effect, at(-0.5));
    // Held at the centre (+200) and set back half the offset (-10).
    expect(translation(tester).dx, closeTo(190, 1e-9));
  });

  testWidgets('coverflow, cube and flip mirror across the centre', (
    tester,
  ) async {
    for (final effect in const [
      CarouselEffect.coverflow(),
      CarouselEffect.cube(),
      CarouselEffect.flip(),
    ]) {
      await show(tester, effect, at(0.3));
      final right = rotation(tester).clone();
      await show(tester, effect, at(-0.3));
      final left = rotation(tester);
      expect(
        right.entry(0, 2),
        closeTo(-left.entry(0, 2), 1e-9),
        reason: '$effect',
      );
    }
  });

  testWidgets('cube turns each face about the shared edge', (tester) async {
    await show(tester, const CarouselEffect.cube(), at(0.5));
    expect(
      tester.widget<Transform>(find.byType(Transform)).alignment,
      Alignment.centerLeft,
    );
    await show(tester, const CarouselEffect.cube(), at(-0.5));
    expect(
      tester.widget<Transform>(find.byType(Transform)).alignment,
      Alignment.centerRight,
    );
  });

  testWidgets('flip hides the back face past halfway', (tester) async {
    await show(tester, const CarouselEffect.flip(), at(0.4));
    expect(opacity(tester), 1);
    await show(tester, const CarouselEffect.flip(), at(0.6));
    expect(opacity(tester), 0);
  });

  testWidgets('rotate turns about its origin in proportion to the offset', (
    tester,
  ) async {
    const effect = CarouselEffect.rotate(angle: math.pi / 6);
    await show(tester, effect, at(0.5));
    final t = tester.widget<Transform>(find.byType(Transform));
    expect(t.alignment, Alignment.bottomCenter);
    expect(
      math.atan2(t.transform.entry(1, 0), t.transform.entry(0, 0)),
      closeTo(math.pi / 12, 1e-9),
    );
  });

  testWidgets('no preset replaces its child, so child state survives', (
    tester,
  ) async {
    // No GlobalKey: a changed widget structure would remount the item.
    for (final effect in const [
      CarouselEffect.enlarge(),
      CarouselEffect.fade(),
      CarouselEffect.parallax(),
      CarouselEffect.depth(),
      CarouselEffect.zoomOut(),
      CarouselEffect.stack(),
      CarouselEffect.coverflow(),
      CarouselEffect.cube(),
      CarouselEffect.flip(),
      CarouselEffect.rotate(),
    ]) {
      await show(tester, effect, at(0.2), child: const Counter());
      tester.state<CounterState>(find.byType(Counter)).count = 5;
      for (final offset in [0.8, 0.0, -0.6, 0.5, -1.0]) {
        await show(tester, effect, at(offset), child: const Counter());
        expect(
          tester.state<CounterState>(find.byType(Counter)).count,
          5,
          reason: '$effect at $offset',
        );
      }
      await tester.pumpWidget(const SizedBox());
    }
  });

  testWidgets('with no effect, items never rebuild while dragged', (
    tester,
  ) async {
    var builds = 0;
    Widget counted(BuildContext context, int index, int page) => Builder(
      builder: (context) {
        if (index == 0) builds++;
        return const SizedBox.expand();
      },
    );
    await tester.pumpWidget(
      host(
        FlutterCarousel.builder(
          itemCount: 3,
          itemBuilder: counted,
          height: 100,
        ),
      ),
    );
    final gesture = await tester.startGesture(const Offset(200, 50));
    for (var i = 0; i < 5; i++) {
      await gesture.moveBy(const Offset(-5, 0));
      await tester.pump();
    }
    expect(builds, 1);
    await gesture.up();
    await tester.pumpAndSettle();
    await tester.pumpWidget(
      host(
        FlutterCarousel.builder(
          itemCount: 3,
          itemBuilder: counted,
          height: 100,
          effect: const CarouselEffect.fade(),
        ),
      ),
    );
    builds = 0;
    final again = await tester.startGesture(const Offset(200, 50));
    for (var i = 0; i < 5; i++) {
      await again.moveBy(const Offset(-5, 0));
      await tester.pump();
    }
    await again.up();
    await tester.pumpAndSettle();
    expect(builds, 0, reason: 'effects rebuild their wrapper, not the item');
  });

  // Review Focus 5.
  testWidgets('each on-screen copy of an item sees its own offset', (
    tester,
  ) async {
    final seen = <int, double>{};
    await tester.pumpWidget(
      host(
        FlutterCarousel(
          items: boxes(2, keyed: true),
          height: 100,
          viewportFraction: 0.2,
          infinite: true,
          effect: CarouselEffect.builder((context, p, child) {
            seen[(p.offset * 1000).round()] = p.offset;
            return child;
          }),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(seen.length, greaterThanOrEqualTo(5));
    expect(seen.values, contains(0));
  });

  test('presets compare by value', () {
    expect(const CarouselEffect.fade(), const FadeEffect());
    expect(
      const CarouselEffect.fade(minOpacity: 0.1) == const FadeEffect(),
      isFalse,
    );
    expect(
      const CarouselEffect.enlarge(factor: 0.3),
      const EnlargeEffect(factor: 0.3),
    );
  });

  test('every preset compares and hashes by value', () {
    // Not const: a const instance never runs its constructor or asserts.
    final v = 0.5;
    final cases = <(CarouselEffect, CarouselEffect, CarouselEffect)>[
      (
        EnlargeEffect(factor: v),
        EnlargeEffect(factor: v),
        EnlargeEffect(factor: v, strategy: CarouselEnlargeStrategy.zoom),
      ),
      (
        FadeEffect(minOpacity: v),
        FadeEffect(minOpacity: v),
        FadeEffect(minOpacity: v / 2),
      ),
      (
        ParallaxEffect(depth: v),
        ParallaxEffect(depth: v),
        ParallaxEffect(depth: v / 2),
      ),
      (
        DepthEffect(minScale: v),
        DepthEffect(minScale: v),
        DepthEffect(minScale: v, minOpacity: v),
      ),
      (
        ZoomOutEffect(minScale: v),
        ZoomOutEffect(minScale: v),
        ZoomOutEffect(minScale: v, minOpacity: v / 2),
      ),
      (
        StackEffect(offset: v),
        StackEffect(offset: v),
        StackEffect(offset: v, minScale: v),
      ),
      (
        CoverflowEffect(angle: v),
        CoverflowEffect(angle: v),
        CoverflowEffect(angle: v, minScale: v),
      ),
      (
        CubeEffect(perspective: v),
        CubeEffect(perspective: v),
        CubeEffect(perspective: v / 2),
      ),
      (
        FlipEffect(perspective: v),
        FlipEffect(perspective: v),
        FlipEffect(perspective: v / 2),
      ),
      (
        RotateEffect(angle: v),
        RotateEffect(angle: v),
        RotateEffect(angle: v, origin: Alignment.center),
      ),
    ];
    for (final (a, same, other) in cases) {
      expect(a, same);
      expect(a.hashCode, same.hashCode);
      expect(a == other, isFalse, reason: '$a');
    }
  });

  testWidgets('vertical carousels hinge and turn along the vertical axis', (
    tester,
  ) async {
    await show(
      tester,
      const CarouselEffect.enlarge(strategy: CarouselEnlargeStrategy.zoom),
      at(-1, axis: Axis.vertical),
    );
    expect(
      tester.widget<Transform>(find.byType(Transform)).alignment,
      Alignment.bottomCenter,
    );
    await show(
      tester,
      const CarouselEffect.cube(),
      at(0.5, axis: Axis.vertical),
    );
    expect(
      tester.widget<Transform>(find.byType(Transform)).alignment,
      Alignment.topCenter,
    );
    for (final effect in const [
      CarouselEffect.coverflow(),
      CarouselEffect.cube(),
      CarouselEffect.flip(),
    ]) {
      await show(tester, effect, at(0.3, axis: Axis.vertical));
      final down = rotation(tester).clone();
      await show(tester, effect, at(-0.3, axis: Axis.vertical));
      expect(
        down.entry(1, 2),
        closeTo(-rotation(tester).entry(1, 2), 1e-9),
        reason: '$effect',
      );
    }
  });

  testWidgets('with padEnds false the last item settles at offset 0', (
    tester,
  ) async {
    final c = FlutterCarouselController();
    addTearDown(c.dispose);
    final offsets = <int, double>{};
    await tester.pumpWidget(
      host(
        FlutterCarousel(
          items: boxes(5),
          height: 100,
          padEnds: false,
          controller: c,
          indicator: null,
          effect: CarouselEffect.builder((context, p, child) {
            offsets[p.index] = p.offset;
            return child;
          }),
        ),
      ),
    );
    unawaited(c.animateToPage(4));
    await tester.pumpAndSettle();
    expect(offsets[4], closeTo(0, 1e-6));
  });
}
