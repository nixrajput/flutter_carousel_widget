import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_carousel_widget/src/auto_play/auto_play_driver.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

const second = Duration(seconds: 1);
const quick = CarouselAutoPlay(
  interval: second,
  duration: Duration(milliseconds: 100),
);

Future<void> tick(WidgetTester tester, [Duration by = second]) async {
  await tester.pump(by);
  await tester.pumpAndSettle();
}

Widget carousel({
  CarouselAutoPlay? autoPlay = quick,
  int n = 3,
  bool infinite = false,
  bool reverse = false,
  FlutterCarouselController? controller,
  CarouselPageChanged? onPageChanged,
  int initialPage = 0,
}) => FlutterCarousel(
  items: boxes(n),
  height: 100,
  autoPlay: autoPlay,
  infinite: infinite,
  reverse: reverse,
  controller: controller,
  onPageChanged: onPageChanged,
  initialPage: initialPage,
);

void main() {
  group('driver', () {
    test('runs only with a config and no pause', () {
      var ticks = 0;
      var changes = 0;
      final d = AutoPlayDriver(
        onTick: () => ticks++,
        onRunningChanged: () => changes++,
      );
      addTearDown(d.dispose);
      expect(d.isRunning, isFalse);
      d.configure(quick);
      expect((d.isRunning, changes), (true, 1));
      d.pause(AutoPlayPause.touch);
      d.pause(AutoPlayPause.hover);
      d.resume(AutoPlayPause.touch);
      expect(d.isRunning, isFalse);
      d.resume(AutoPlayPause.hover);
      expect((d.isRunning, changes), (true, 3));
    });
  });

  testWidgets('advances every interval, reporting timed', (tester) async {
    final changes = <(int, CarouselPageChangedReason)>[];
    await tester.pumpWidget(
      host(carousel(onPageChanged: (i, r) => changes.add((i, r)))),
    );
    await tick(tester);
    await tick(tester);
    expect(changes, [
      (1, CarouselPageChangedReason.timed),
      (2, CarouselPageChangedReason.timed),
    ]);
  });

  testWidgets('each item can have its own interval', (tester) async {
    final c = FlutterCarouselController();
    addTearDown(c.dispose);
    await tester.pumpWidget(
      host(
        carousel(
          controller: c,
          autoPlay: CarouselAutoPlay(
            duration: const Duration(milliseconds: 100),
            intervalFor: (i) => Duration(seconds: i + 1),
          ),
        ),
      ),
    );
    await tick(tester);
    expect(c.index, 1);
    await tick(tester);
    expect(c.index, 1, reason: 'item 1 stays 2 s');
    await tick(tester, const Duration(milliseconds: 1500));
    expect(c.index, 2);
  });

  testWidgets('a parent rebuild does not restart the interval', (tester) async {
    final c = FlutterCarouselController();
    addTearDown(c.dispose);
    late StateSetter set;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, s) {
            set = s;
            return carousel(
              controller: c,
              autoPlay: CarouselAutoPlay(
                interval: second,
                duration: const Duration(milliseconds: 100),
                intervalFor: (_) => second, // a new closure every build
              ),
            );
          },
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 700));
    set(() {});
    await tick(tester, const Duration(milliseconds: 300));
    expect(c.index, 1);
  });

  testWidgets('holds while a finger is down, then resumes', (tester) async {
    final c = FlutterCarouselController();
    addTearDown(c.dispose);
    await tester.pumpWidget(host(carousel(controller: c)));
    final gesture = await tester.startGesture(const Offset(200, 50));
    await tick(tester, const Duration(seconds: 3));
    expect(c.index, 0);
    await gesture.up();
    await tick(tester);
    expect(c.index, 1);
  });

  testWidgets('holds while a mouse hovers', (tester) async {
    final c = FlutterCarouselController();
    addTearDown(c.dispose);
    await tester.pumpWidget(host(carousel(controller: c)));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(200, 50));
    await tick(tester, const Duration(seconds: 3));
    expect(c.index, 0);
    await mouse.moveTo(const Offset(200, 500));
    await tick(tester);
    expect(c.index, 1);
    await mouse.removePointer();
  });

  testWidgets('holds while the app is in the background', (tester) async {
    final c = FlutterCarouselController();
    addTearDown(c.dispose);
    await tester.pumpWidget(host(carousel(controller: c)));
    // AppLifecycleListener asserts the platform's real order of states.
    for (final state in [
      AppLifecycleState.inactive,
      AppLifecycleState.hidden,
      AppLifecycleState.paused,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    await tick(tester, const Duration(seconds: 3));
    expect(c.index, 0);
    for (final state in [
      AppLifecycleState.hidden,
      AppLifecycleState.inactive,
      AppLifecycleState.resumed,
    ]) {
      tester.binding.handleAppLifecycleStateChanged(state);
    }
    await tick(tester);
    expect(c.index, 1);
  });

  // Review Focus 4.
  testWidgets('holds while offstage and keeps its item', (tester) async {
    final c = FlutterCarouselController();
    addTearDown(c.dispose);
    var enabled = true;
    late StateSetter set;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, s) {
            set = s;
            return TickerMode(
              enabled: enabled,
              child: carousel(controller: c),
            );
          },
        ),
      ),
    );
    await tick(tester);
    set(() => enabled = false);
    await tick(tester, const Duration(seconds: 3));
    expect(c.index, 1);
    set(() => enabled = true);
    await tick(tester);
    expect(c.index, 2);
  });

  testWidgets('holds while another route covers it', (tester) async {
    final c = FlutterCarouselController();
    addTearDown(c.dispose);
    final navigator = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      WidgetsApp(
        navigatorKey: navigator,
        color: const Color(0xFF000000),
        pageRouteBuilder: <T>(settings, builder) => PageRouteBuilder<T>(
          settings: settings,
          pageBuilder: (context, _, _) => builder(context),
        ),
        home: carousel(controller: c),
      ),
    );
    unawaited(
      navigator.currentState!.push(
        PageRouteBuilder<void>(pageBuilder: (_, _, _) => const SizedBox()),
      ),
    );
    // The route pause lands on the next frame, before the interval is up.
    await tester.pump();
    await tick(tester, const Duration(seconds: 3));
    expect(c.index, 0);
    navigator.currentState!.pop();
    await tick(tester);
    await tick(tester);
    expect(c.index, 1);
  });

  testWidgets('never runs under reduced motion', (tester) async {
    final c = FlutterCarouselController();
    addTearDown(c.dispose);
    await tester.pumpWidget(
      host(carousel(controller: c), disableAnimations: true),
    );
    await tick(tester, const Duration(seconds: 3));
    expect((c.index, c.isAutoPlaying), (0, false));
  });

  testWidgets('a finite carousel rewinds; stopAtEnd stops it', (tester) async {
    final c = FlutterCarouselController();
    addTearDown(c.dispose);
    await tester.pumpWidget(
      host(carousel(controller: c, n: 2, initialPage: 1)),
    );
    await tick(tester);
    expect(c.index, 0);
    await tester.pumpWidget(
      host(
        carousel(
          controller: c,
          n: 2,
          initialPage: 1,
          autoPlay: const CarouselAutoPlay(interval: second, stopAtEnd: true),
        ),
      ),
    );
    // From item 0 it moves to 1, the end, and stops there.
    await tick(tester, const Duration(seconds: 3));
    expect((c.index, c.isAutoPlaying), (1, false));
  });

  testWidgets('reverse runs backwards and rewinds to the last item', (
    tester,
  ) async {
    final c = FlutterCarouselController();
    addTearDown(c.dispose);
    await tester.pumpWidget(host(carousel(controller: c, reverse: true)));
    await tick(tester);
    expect(c.index, 2);
  });

  testWidgets('stopAutoPlay sticks through touches until startAutoPlay', (
    tester,
  ) async {
    final c = FlutterCarouselController();
    addTearDown(c.dispose);
    var notified = 0;
    c.addListener(() => notified++);
    await tester.pumpWidget(host(carousel(controller: c)));
    await tester.pump();
    expect(c.isAutoPlaying, isTrue);
    c.stopAutoPlay();
    expect(c.isAutoPlaying, isFalse);
    await tester.tap(find.byType(PageView));
    await tick(tester, const Duration(seconds: 3));
    expect(c.index, 0);
    c.startAutoPlay();
    await tick(tester);
    expect(c.index, 1);
    expect(notified, greaterThanOrEqualTo(3));
  });

  // Review Focus 1.
  testWidgets('one item or none: autoplay stays idle', (tester) async {
    for (final n in [0, 1]) {
      await tester.pumpWidget(
        host(
          FlutterCarousel(
            key: ValueKey(n),
            items: boxes(n),
            height: 50,
            autoPlay: quick,
            infinite: true,
          ),
        ),
      );
      await tick(tester, const Duration(seconds: 3));
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('items that arrive late start autoplay', (tester) async {
    final c = FlutterCarouselController();
    addTearDown(c.dispose);
    await tester.pumpWidget(host(carousel(controller: c, n: 0)));
    await tick(tester, const Duration(seconds: 2));
    expect(c.isAutoPlaying, isFalse, reason: 'nothing to play with no items');
    await tester.pumpWidget(host(carousel(controller: c, n: 3)));
    await tick(tester);
    await tick(tester);
    expect(c.isAutoPlaying, isTrue);
    expect(c.index, greaterThan(0));
  });

  testWidgets('stopAtEnd moves on again when items are appended', (
    tester,
  ) async {
    final c = FlutterCarouselController();
    addTearDown(c.dispose);
    const stopping = CarouselAutoPlay(
      interval: second,
      duration: Duration(milliseconds: 100),
      stopAtEnd: true,
    );
    await tester.pumpWidget(
      host(carousel(controller: c, n: 2, autoPlay: stopping)),
    );
    await tick(tester, const Duration(seconds: 3));
    expect((c.index, c.isAutoPlaying), (1, false));
    await tester.pumpWidget(
      host(carousel(controller: c, n: 3, autoPlay: stopping)),
    );
    await tick(tester);
    await tick(tester);
    expect(c.index, 2);
  });
}
