import 'dart:async';

import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

Future<List<(int, CarouselPageChangedReason)>> keyed(
  WidgetTester tester, {
  TextDirection textDirection = TextDirection.ltr,
  Axis axis = Axis.horizontal,
  bool reverse = false,
  bool keyboardNavigation = true,
  int n = 3,
}) async {
  final changes = <(int, CarouselPageChangedReason)>[];
  await tester.pumpWidget(
    host(
      FlutterCarousel(
        // A fresh carousel per call, so autofocus applies and the index resets.
        key: UniqueKey(),
        items: boxes(n),
        height: 100,
        autofocus: true,
        scrollDirection: axis,
        reverse: reverse,
        keyboardNavigation: keyboardNavigation,
        onPageChanged: (i, r) => changes.add((i, r)),
      ),
      textDirection: textDirection,
    ),
  );
  await tester.pump();
  return changes;
}

Future<void> press(WidgetTester tester, LogicalKeyboardKey key) async {
  await tester.sendKeyEvent(key);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('arrows move the focused carousel, reported as keyboard', (
    tester,
  ) async {
    final changes = await keyed(tester);
    await press(tester, LogicalKeyboardKey.arrowRight);
    await press(tester, LogicalKeyboardKey.arrowRight);
    await press(tester, LogicalKeyboardKey.arrowLeft);
    expect(changes, [
      (1, CarouselPageChangedReason.keyboard),
      (2, CarouselPageChangedReason.keyboard),
      (1, CarouselPageChangedReason.keyboard),
    ]);
  });

  testWidgets('the arrow pointing at the next item moves to it', (
    tester,
  ) async {
    for (final (dir, axis, reverse, next) in [
      (TextDirection.rtl, Axis.horizontal, false, LogicalKeyboardKey.arrowLeft),
      (TextDirection.ltr, Axis.horizontal, true, LogicalKeyboardKey.arrowLeft),
      (TextDirection.ltr, Axis.vertical, false, LogicalKeyboardKey.arrowDown),
      (TextDirection.ltr, Axis.vertical, true, LogicalKeyboardKey.arrowUp),
    ]) {
      final changes = await keyed(
        tester,
        textDirection: dir,
        axis: axis,
        reverse: reverse,
      );
      await press(tester, next);
      expect(changes.last.$1, 1, reason: '$dir $axis reverse: $reverse');
    }
  });

  testWidgets('Home and End go to the first and last items', (tester) async {
    final changes = await keyed(tester, n: 5);
    await press(tester, LogicalKeyboardKey.end);
    expect(changes.last.$1, 4);
    await press(tester, LogicalKeyboardKey.home);
    expect(changes.last.$1, 0);
    // PageView reports each page it passes; every one of them is the key's.
    expect(changes.map((c) => c.$2).toSet(), {
      CarouselPageChangedReason.keyboard,
    });
  });

  testWidgets('keyboardNavigation false ignores the keys', (tester) async {
    final changes = await keyed(tester, keyboardNavigation: false);
    await press(tester, LogicalKeyboardKey.arrowRight);
    expect(changes, isEmpty);
  });

  // Review Focus 1.
  testWidgets('keys do nothing with one item or none', (tester) async {
    for (final n in [0, 1]) {
      final changes = await keyed(tester, n: n);
      await press(tester, LogicalKeyboardKey.arrowRight);
      await press(tester, LogicalKeyboardKey.end);
      expect(changes, isEmpty);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('the carousel reads as "Slide x of n" and adjusts', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final changes = <(int, CarouselPageChangedReason)>[];
    await tester.pumpWidget(
      host(
        FlutterCarousel(
          items: boxes(3),
          height: 100,
          indicator: null,
          onPageChanged: (i, r) => changes.add((i, r)),
        ),
      ),
    );
    final node = tester.getSemantics(find.bySemanticsLabel('Carousel'));
    expect(node.value, 'Slide 1 of 3');
    expect(node.increasedValue, 'Slide 2 of 3');
    tester.semantics.performAction(
      find.semantics.byLabel('Carousel'),
      SemanticsAction.increase,
    );
    await tester.pumpAndSettle();
    expect(changes.single, (1, CarouselPageChangedReason.manual));
    expect(
      tester.getSemantics(find.bySemanticsLabel('Carousel')).value,
      'Slide 2 of 3',
    );
    tester.semantics.performAction(
      find.semantics.byLabel('Carousel'),
      SemanticsAction.decrease,
    );
    await tester.pumpAndSettle();
    expect(changes.last, (0, CarouselPageChangedReason.manual));
    handle.dispose();
  });

  testWidgets('labels can be translated', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      host(
        FlutterCarousel(
          items: boxes(2),
          height: 100,
          indicator: null,
          semanticLabel: 'Galerie',
          semanticSlideLabel: (i, n) => 'Bild ${i + 1} von $n',
        ),
      ),
    );
    expect(
      tester.getSemantics(find.bySemanticsLabel('Galerie')).value,
      'Bild 1 von 2',
    );
    handle.dispose();
  });

  testWidgets('screen readers hear user moves, never autoplay', (tester) async {
    final c = FlutterCarouselController();
    addTearDown(c.dispose);
    await tester.pumpWidget(
      host(
        FlutterCarousel(
          items: boxes(3),
          height: 100,
          controller: c,
          autoPlay: const CarouselAutoPlay(interval: Duration(seconds: 1)),
        ),
        accessibleNavigation: true,
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(c.index, 1);
    expect(tester.takeAnnouncements(), isEmpty);
    c.stopAutoPlay();
    unawaited(c.nextPage());
    await tester.pumpAndSettle();
    expect(tester.takeAnnouncements().map((a) => a.message), ['Slide 3 of 3']);
  });

  testWidgets('nothing is announced without accessible navigation', (
    tester,
  ) async {
    final c = FlutterCarouselController();
    addTearDown(c.dispose);
    await tester.pumpWidget(
      host(FlutterCarousel(items: boxes(3), height: 100, controller: c)),
    );
    unawaited(c.nextPage());
    await tester.pumpAndSettle();
    expect(tester.takeAnnouncements(), isEmpty);
  });

  testWidgets('focus holds autoplay until it leaves', (tester) async {
    final c = FlutterCarouselController();
    addTearDown(c.dispose);
    final node = FocusNode();
    addTearDown(node.dispose);
    await tester.pumpWidget(
      host(
        FlutterCarousel(
          items: boxes(3),
          height: 100,
          controller: c,
          focusNode: node,
          autoPlay: const CarouselAutoPlay(interval: Duration(seconds: 1)),
        ),
      ),
    );
    node.requestFocus();
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(c.index, 0);
    node.unfocus();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(c.index, 1);
  });

  testWidgets('keys typed into a field inside a slide stay with the field', (
    tester,
  ) async {
    final c = FlutterCarouselController();
    addTearDown(c.dispose);
    final text = TextEditingController(text: 'hello');
    addTearDown(text.dispose);
    final field = FocusNode();
    addTearDown(field.dispose);
    await tester.pumpWidget(
      WidgetsApp(
        color: const Color(0xFF000000),
        builder: (context, _) => host(
          FlutterCarousel(
            height: 100,
            controller: c,
            items: [
              EditableText(
                controller: text,
                focusNode: field,
                style: const TextStyle(),
                cursorColor: const Color(0xFF000000),
                backgroundCursorColor: const Color(0xFF000000),
              ),
              const SizedBox(),
              const SizedBox(),
            ],
          ),
        ),
      ),
    );
    field.requestFocus();
    await tester.pump();
    await press(tester, LogicalKeyboardKey.arrowRight);
    await press(tester, LogicalKeyboardKey.end);
    expect(c.index, 0);
  });

  testWidgets('a move is announced once, at its destination', (tester) async {
    final c = FlutterCarouselController();
    addTearDown(c.dispose);
    await tester.pumpWidget(
      host(
        FlutterCarousel(items: boxes(3), height: 100, controller: c),
        accessibleNavigation: true,
      ),
    );
    unawaited(c.animateToPage(2));
    await tester.pumpAndSettle();
    expect(tester.takeAnnouncements().map((a) => a.message), ['Slide 3 of 3']);
  });
}
