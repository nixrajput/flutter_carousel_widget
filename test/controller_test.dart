import 'package:flutter/animation.dart';
import 'package:flutter_carousel_widget/src/controller/flutter_carousel_controller.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

void main() {
  // attachController schedules a post-frame notification.
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a detached controller explains itself instead of crashing (#59)', () {
    final c = FlutterCarouselController();
    addTearDown(c.dispose);
    expect(c.isAttached, isFalse);
    expect(c.isAutoPlaying, isFalse);
    for (final call in <void Function()>[
      () => c.index,
      () => c.position,
      c.nextPage,
      () => c.jumpToPage(0),
      c.startAutoPlay,
      c.stopAutoPlay,
    ]) {
      expect(
        call,
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('not attached to a carousel'),
          ),
        ),
      );
    }
  });

  test('forwards every call to the attached carousel', () async {
    final c = FlutterCarouselController();
    addTearDown(c.dispose);
    final b = FakeBinding()
      ..index = 3
      ..position = 2.5
      ..isAutoPlaying = true;
    attachController(c, b);
    expect(
      (c.isAttached, c.index, c.position, c.isAutoPlaying),
      (true, 3, 2.5, true),
    );
    await c.nextPage(duration: const Duration(seconds: 1));
    await c.previousPage(curve: Curves.linear);
    await c.animateToPage(4);
    c
      ..jumpToPage(1)
      ..stopAutoPlay()
      ..startAutoPlay();
    expect(b.calls, [
      'step 1 0:00:01.000000 null',
      'step -1 null ${Curves.linear}',
      'animateTo 4 null null',
      'jumpTo 1',
      'stopped true',
      'stopped false',
    ]);
  });

  test('the most recent carousel wins, and a stale detach is ignored', () {
    final c = FlutterCarouselController();
    addTearDown(c.dispose);
    final old = FakeBinding();
    final replacement = FakeBinding()..index = 7;
    attachController(c, old);
    attachController(c, replacement);
    detachController(c, old);
    expect(c.index, 7);
    detachController(c, replacement);
    expect(c.isAttached, isFalse);
  });

  testWidgets('attach and detach notify after the frame, not during it', (
    tester,
  ) async {
    final c = FlutterCarouselController();
    addTearDown(c.dispose);
    var notified = 0;
    c.addListener(() => notified++);
    attachController(c, FakeBinding());
    expect(notified, 0);
    await tester.pump();
    expect(notified, 1);
    detachController(c, FakeBinding()); // not the attached one: no change
    await tester.pump();
    expect(notified, 1);
  });
}
