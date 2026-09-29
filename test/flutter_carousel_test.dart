import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_carousel_widget/src/indicators/indicator_view.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

PageController pagesOf(WidgetTester tester) =>
    tester.widget<PageView>(find.byType(PageView)).controller!;

void main() {
  testWidgets('shows the initial item and sizes to height or aspect ratio', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(FlutterCarousel(items: boxes(3), height: 200, initialPage: 1)),
    );
    expect(tester.getSize(find.byType(FlutterCarousel)), const Size(400, 200));
    expect(pagesOf(tester).page, 1);
    await tester.pumpWidget(
      host(FlutterCarousel(items: boxes(3), aspectRatio: 2, indicator: null)),
    );
    expect(tester.getSize(find.byType(FlutterCarousel)), const Size(400, 200));
  });

  testWidgets('reports what moved it: a drag, then the controller', (
    tester,
  ) async {
    final c = FlutterCarouselController();
    addTearDown(c.dispose);
    final changes = <(int, CarouselPageChangedReason)>[];
    await tester.pumpWidget(
      host(
        FlutterCarousel(
          items: boxes(5),
          height: 200,
          controller: c,
          onPageChanged: (i, r) => changes.add((i, r)),
        ),
      ),
    );
    await tester.drag(find.byType(PageView), const Offset(-250, 0));
    await tester.pumpAndSettle();
    unawaited(c.nextPage());
    await tester.pumpAndSettle();
    expect(changes, [
      (1, CarouselPageChangedReason.manual),
      (2, CarouselPageChangedReason.controller),
    ]);
    expect(c.index, 2);
  });

  testWidgets('the controller moves by index, the short way when infinite', (
    tester,
  ) async {
    final c = FlutterCarouselController();
    addTearDown(c.dispose);
    await tester.pumpWidget(
      host(
        FlutterCarousel(
          items: boxes(5),
          height: 200,
          infinite: true,
          controller: c,
        ),
      ),
    );
    unawaited(c.animateToPage(4));
    await tester.pumpAndSettle();
    expect(c.index, 4);
    expect(pagesOf(tester).page, 5 * 10000 - 1);
    c.jumpToPage(2);
    expect(c.index, 2);
    expect(() => c.animateToPage(5), throwsRangeError);
    expect(() => c.jumpToPage(-1), throwsRangeError);
  });

  testWidgets('#59: after dispose the controller detaches and says so', (
    tester,
  ) async {
    final c = FlutterCarouselController();
    addTearDown(c.dispose);
    await tester.pumpWidget(
      host(FlutterCarousel(items: boxes(3), height: 200, controller: c)),
    );
    expect(c.isAttached, isTrue);
    await tester.pumpWidget(host(const SizedBox()));
    expect(c.isAttached, isFalse);
    expect(c.startAutoPlay, throwsStateError);
  });

  testWidgets(
    'a parent rebuild neither leaks a controller nor moves the page',
    (tester) async {
      late StateSetter set;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, s) {
              set = s;
              return FlutterCarousel(
                items: boxes(3),
                height: 200,
                initialPage: 2,
              );
            },
          ),
        ),
      );
      final first = pagesOf(tester);
      for (var i = 0; i < 20; i++) {
        set(() {});
        await tester.pump();
      }
      expect(pagesOf(tester), same(first));
      expect(first.page, 2);
    },
  );

  testWidgets('a new viewportFraction keeps the item', (tester) async {
    var fraction = 0.8;
    late StateSetter set;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, s) {
            set = s;
            return FlutterCarousel(
              items: boxes(5),
              height: 200,
              initialPage: 3,
              viewportFraction: fraction,
            );
          },
        ),
      ),
    );
    set(() => fraction = 1.0);
    await tester.pumpAndSettle();
    expect(pagesOf(tester).viewportFraction, 1.0);
    expect(pagesOf(tester).page, 3);
  });

  testWidgets(
    "#16: removing an earlier keyed item keeps a later item's state",
    (tester) async {
      var removed = false;
      late StateSetter set;
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            builder: (context, s) {
              set = s;
              return FlutterCarousel(
                height: 200,
                viewportFraction: 1,
                indicator: null,
                items: [
                  const SizedBox(key: ValueKey('a')),
                  if (!removed) const SizedBox(key: ValueKey('b')),
                  const Counter(key: ValueKey('c')),
                ],
              );
            },
          ),
        ),
      );
      pagesOf(tester).jumpToPage(2);
      await tester.pump();
      tester.state<CounterState>(find.byType(Counter)).count = 7;
      set(() => removed = true);
      await tester.pumpAndSettle();
      expect(tester.state<CounterState>(find.byType(Counter)).count, 7);
    },
  );

  testWidgets("#65: keepAlive keeps a page's state when it scrolls away", (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const FlutterCarousel(
          height: 200,
          viewportFraction: 1,
          keepAlive: true,
          indicator: null,
          items: [
            Counter(key: ValueKey('c')),
            SizedBox(),
            SizedBox(),
          ],
        ),
      ),
    );
    tester.state<CounterState>(find.byType(Counter)).count = 3;
    pagesOf(tester).jumpToPage(2);
    await tester.pump();
    pagesOf(tester).jumpToPage(0);
    await tester.pump();
    expect(tester.state<CounterState>(find.byType(Counter)).count, 3);
  });

  testWidgets('onScrolled reports the item position, not the virtual page', (
    tester,
  ) async {
    final seen = <double>[];
    await tester.pumpWidget(
      host(
        FlutterCarousel(
          items: boxes(3),
          height: 200,
          viewportFraction: 1,
          infinite: true,
          dragStartBehavior: DragStartBehavior.down,
          onScrolled: seen.add,
        ),
      ),
    );
    final gesture = await tester.startGesture(const Offset(200, 100));
    await gesture.moveBy(const Offset(-200, 0));
    await tester.pump();
    expect(seen.last, closeTo(0.5, 1e-6));
    await gesture.up();
    await tester.pumpAndSettle();
  });

  testWidgets('pages drag with every pointer kind, trackpads included', (
    tester,
  ) async {
    final changes = <int>[];
    await tester.pumpWidget(
      host(
        FlutterCarousel(
          items: boxes(4),
          height: 200,
          onPageChanged: (i, _) => changes.add(i),
        ),
      ),
    );
    for (final kind in [
      PointerDeviceKind.mouse,
      PointerDeviceKind.stylus,
      PointerDeviceKind.trackpad,
    ]) {
      await tester.drag(
        find.byType(PageView),
        const Offset(-250, 0),
        kind: kind,
      );
      await tester.pumpAndSettle();
    }
    expect(changes, [1, 2, 3]);
  });

  testWidgets('physics default to the platform, with the snap spring', (
    tester,
  ) async {
    for (final (platform, parent) in [
      (TargetPlatform.iOS, BouncingScrollPhysics),
      (TargetPlatform.android, ClampingScrollPhysics),
    ]) {
      debugDefaultTargetPlatformOverride = platform;
      await tester.pumpWidget(
        host(
          FlutterCarousel(
            key: ValueKey(platform),
            items: boxes(2),
            height: 100,
          ),
        ),
      );
      final physics = tester.widget<PageView>(find.byType(PageView)).physics!;
      expect(physics, isA<CarouselSnapPhysics>());
      expect(physics.parent.runtimeType, parent);
    }
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('reduced motion jumps instead of animating', (tester) async {
    final c = FlutterCarouselController();
    addTearDown(c.dispose);
    await tester.pumpWidget(
      host(
        FlutterCarousel(items: boxes(3), height: 200, controller: c),
        disableAnimations: true,
      ),
    );
    unawaited(c.nextPage());
    expect(c.index, 1);
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('with padEnds false the last item is reached', (tester) async {
    final c = FlutterCarouselController();
    addTearDown(c.dispose);
    await tester.pumpWidget(
      host(
        FlutterCarousel(
          items: boxes(5),
          height: 100,
          padEnds: false,
          controller: c,
        ),
      ),
    );
    unawaited(c.animateToPage(4));
    await tester.pumpAndSettle();
    expect(c.index, 4);
    expect(c.position, closeTo(4, 1e-6));
  });

  testWidgets('itemAlignment wraps items, and null leaves them bare', (
    tester,
  ) async {
    final aligns = find.descendant(
      of: find.byType(PageView),
      matching: find.byType(Align),
    );
    await tester.pumpWidget(
      host(FlutterCarousel(items: boxes(2), height: 100)),
    );
    expect(aligns, findsWidgets);
    await tester.pumpWidget(
      host(FlutterCarousel(items: boxes(2), height: 100, itemAlignment: null)),
    );
    expect(aligns, findsNothing);
  });

  testWidgets(
    'the default indicator keeps its 3.x key and shows for 2+ items',
    (tester) async {
      await tester.pumpWidget(
        host(FlutterCarousel(items: boxes(3), height: 100)),
      );
      expect(find.byKey(const ValueKey('default_indicator')), findsOneWidget);
      await tester.pumpWidget(
        host(FlutterCarousel(items: boxes(3), height: 100, indicator: null)),
      );
      expect(find.byType(IndicatorView), findsNothing);
    },
  );

  // Review Focus 1.
  testWidgets(
    'zero and one item, infinite, with an indicator: no dots, no error',
    (tester) async {
      for (final n in [0, 1]) {
        await tester.pumpWidget(
          host(
            FlutterCarousel(
              key: ValueKey(n),
              items: boxes(n),
              height: 100,
              infinite: true,
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        expect(find.byType(IndicatorView), findsNothing);
      }
    },
  );

  // Review Focus 2.
  testWidgets('items shrinking below the current one land on the new last', (
    tester,
  ) async {
    for (final infinite in [false, true]) {
      var n = 5;
      late StateSetter set;
      final changes = <int>[];
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            key: ValueKey(infinite),
            builder: (context, s) {
              set = s;
              return FlutterCarousel(
                items: boxes(n),
                height: 100,
                infinite: infinite,
                initialPage: 4,
                onPageChanged: (i, _) => changes.add(i),
              );
            },
          ),
        ),
      );
      set(() => n = 2);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(changes.last, 1, reason: 'infinite: $infinite');
    }
  });

  // Review Focus 3.
  testWidgets('a key change hands the controller to the new carousel', (
    tester,
  ) async {
    final c = FlutterCarouselController();
    addTearDown(c.dispose);
    await tester.pumpWidget(
      host(
        FlutterCarousel(
          key: const ValueKey(1),
          items: boxes(3),
          height: 100,
          controller: c,
        ),
      ),
    );
    await tester.pumpWidget(
      host(
        FlutterCarousel(
          key: const ValueKey(2),
          items: boxes(3),
          height: 100,
          controller: c,
          initialPage: 2,
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect((c.isAttached, c.index), (true, 2));
  });

  // Review Focus 5.
  testWidgets(
    'a tiny viewportFraction shows keyed copies without key clashes',
    (tester) async {
      await tester.pumpWidget(
        host(
          FlutterCarousel(
            items: boxes(2, keyed: true),
            height: 100,
            viewportFraction: 0.2,
            infinite: true,
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('0').evaluate().length, greaterThan(1));
    },
  );

  testWidgets(
    'swapping the controller attaches the new one, detaches the old',
    (tester) async {
      final first = FlutterCarouselController();
      final second = FlutterCarouselController();
      addTearDown(first.dispose);
      addTearDown(second.dispose);
      await tester.pumpWidget(
        host(FlutterCarousel(items: boxes(3), height: 100, controller: first)),
      );
      await tester.pumpWidget(
        host(FlutterCarousel(items: boxes(3), height: 100, controller: second)),
      );
      expect((first.isAttached, second.isAttached), (false, true));
      unawaited(second.nextPage());
      await tester.pumpAndSettle();
      expect(second.index, 1);
    },
  );

  testWidgets('moving, adding or removing the indicator keeps the pages', (
    tester,
  ) async {
    Widget carousel(CarouselIndicator? indicator, {int n = 3}) => host(
      FlutterCarousel(
        height: 100,
        viewportFraction: 1,
        indicator: indicator,
        items: [
          const Counter(key: ValueKey('c')),
          for (var i = 1; i < n; i++) SizedBox(key: ValueKey(i)),
        ],
      ),
    );
    await tester.pumpWidget(carousel(const CarouselIndicator()));
    tester.state<CounterState>(find.byType(Counter)).count = 4;
    for (final next in [
      carousel(
        const CarouselIndicator(placement: CarouselIndicatorPlacement.below),
      ),
      carousel(null),
      carousel(const CarouselIndicator()),
      carousel(const CarouselIndicator(), n: 1),
    ]) {
      await tester.pumpWidget(next);
      expect(tester.takeException(), isNull);
      expect(tester.state<CounterState>(find.byType(Counter)).count, 4);
    }
  });

  testWidgets('#16: removing an earlier keyed item follows the current one', (
    tester,
  ) async {
    for (final infinite in [false, true]) {
      final c = FlutterCarouselController();
      addTearDown(c.dispose);
      var removed = false;
      late StateSetter set;
      final changes = <(int, CarouselPageChangedReason)>[];
      await tester.pumpWidget(
        host(
          StatefulBuilder(
            key: ValueKey(infinite),
            builder: (context, s) {
              set = s;
              return FlutterCarousel(
                height: 200,
                viewportFraction: 1,
                infinite: infinite,
                controller: c,
                indicator: null,
                onPageChanged: (i, r) => changes.add((i, r)),
                items: [
                  const SizedBox(key: ValueKey('a')),
                  if (!removed) const SizedBox(key: ValueKey('b')),
                  const Counter(key: ValueKey('c')),
                  const SizedBox(key: ValueKey('d')),
                ],
              );
            },
          ),
        ),
      );
      c.jumpToPage(2);
      await tester.pump();
      tester.state<CounterState>(find.byType(Counter)).count = 7;
      set(() => removed = true);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(c.index, 1, reason: 'infinite: $infinite');
      expect(changes.last, (1, CarouselPageChangedReason.controller));
      expect(tester.state<CounterState>(find.byType(Counter)).count, 7);
    }
  });

  testWidgets(
    'shrinking to no items reports nothing and keeps semantics valid',
    (tester) async {
      final handle = tester.ensureSemantics();
      for (final (expandable, infinite) in [
        (false, false),
        (false, true),
        (true, false),
        (true, true),
      ]) {
        var n = 5;
        late StateSetter set;
        final changes = <int>[];
        List<Widget> items() => [
          for (var i = 0; i < n; i++) SizedBox(height: 50, child: Text('$i')),
        ];
        await tester.pumpWidget(
          host(
            StatefulBuilder(
              key: ValueKey((expandable, infinite)),
              builder: (context, s) {
                set = s;
                return expandable
                    ? ExpandableCarousel(
                        items: items(),
                        infinite: infinite,
                        initialPage: 3,
                        onPageChanged: (i, _) => changes.add(i),
                      )
                    : FlutterCarousel(
                        items: items(),
                        height: 100,
                        infinite: infinite,
                        initialPage: 3,
                        onPageChanged: (i, _) => changes.add(i),
                      );
              },
            ),
          ),
        );
        set(() => n = 0);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(
          changes,
          isEmpty,
          reason: 'expandable: $expandable, infinite: $infinite',
        );
      }
      handle.dispose();
    },
  );

  testWidgets(
    'keepAlive in an infinite carousel keeps a bounded set of pages',
    (tester) async {
      await tester.pumpWidget(
        host(
          FlutterCarousel(
            height: 100,
            viewportFraction: 1,
            infinite: true,
            keepAlive: true,
            indicator: null,
            autoPlay: const CarouselAutoPlay(
              interval: Duration(seconds: 1),
              duration: Duration(milliseconds: 100),
            ),
            items: [for (var i = 0; i < 3; i++) Counter(key: ValueKey(i))],
          ),
        ),
      );
      for (var i = 0; i < 30; i++) {
        await tester.pump(const Duration(seconds: 1));
        await tester.pumpAndSettle();
      }
      final alive = find.byType(Counter, skipOffstage: false).evaluate().length;
      expect(alive, lessThanOrEqualTo(7));
    },
  );

  testWidgets('a carousel disposed right after a viewportFraction change '
      'disposes each retired controller once', (tester) async {
    final list = ScrollController();
    addTearDown(list.dispose);
    var fraction = 0.8;
    late StateSetter set;
    await tester.pumpWidget(
      host(
        SizedBox(
          height: 300,
          child: StatefulBuilder(
            builder: (context, s) {
              set = s;
              return ListView(
                controller: list,
                children: [
                  FlutterCarousel(
                    items: boxes(3),
                    height: 100,
                    viewportFraction: fraction,
                  ),
                  const SizedBox(height: 5000),
                ],
              );
            },
          ),
        ),
      ),
    );
    set(() => fraction = 0.5);
    list.jumpTo(3000);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('turning looping on or off keeps the current item', (
    tester,
  ) async {
    for (final from in [false, true]) {
      for (final item in [0, 2, 4]) {
        final c = FlutterCarouselController();
        final changes = <int>[];
        Widget build({required bool infinite}) => host(
          FlutterCarousel(
            key: ValueKey((from, item)),
            items: boxes(5),
            height: 100,
            controller: c,
            infinite: infinite,
            indicator: null,
            onPageChanged: (i, _) => changes.add(i),
          ),
        );
        final reason = 'infinite $from -> ${!from}, item $item';
        await tester.pumpWidget(build(infinite: from));
        c.jumpToPage(item);
        await tester.pumpAndSettle();
        changes.clear();
        await tester.pumpWidget(build(infinite: !from));
        await tester.pumpAndSettle();
        expect(c.index, item, reason: reason);
        expect(changes, isEmpty, reason: '$reason: nothing moved');
        expect(tester.getCenter(find.text('$item')).dx, 200, reason: reason);
        unawaited(c.nextPage());
        await tester.pumpAndSettle();
        final next = !from || item < 4 ? (item + 1) % 5 : 4;
        expect(c.index, next, reason: '$reason, then next');
        c.dispose();
      }
    }
  });
}
