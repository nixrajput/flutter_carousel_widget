import 'dart:io';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_carousel_widget_example/main.dart';

/// The test font's glyphs are wider than Roboto's, which would report
/// overflows no user sees; load the fonts the app really renders with.
Future<void> loadRealFonts() async {
  final root = Platform.environment['FLUTTER_ROOT'];
  if (root == null) {
    throw StateError(
      'FLUTTER_ROOT is not set. Run these tests with `flutter test`, which '
      'sets it, so the real fonts can be found.',
    );
  }
  final fonts = '$root/bin/cache/artifacts/material_fonts';
  Future<ByteData> read(String name) async =>
      ByteData.sublistView(await File('$fonts/$name').readAsBytes());
  await (FontLoader('Roboto')
        ..addFont(read('Roboto-Regular.ttf'))
        ..addFont(read('Roboto-Medium.ttf')))
      .load();
  await (FontLoader(
    'MaterialIcons',
  )..addFont(read('MaterialIcons-Regular.otf'))).load();
}

/// Name, logical size, bottom inset (a phone's home indicator) and text scale.
const screens = <(String, Size, double, double)>[
  ('phone portrait', Size(390, 844), 34, 1),
  ('small phone', Size(360, 640), 0, 1),
  ('short phone, large text', Size(390, 600), 0, 1.3),
  ('android, large text', Size(412, 915), 48, 1.3),
  ('phone landscape', Size(844, 390), 21, 1),
  ('small phone landscape', Size(667, 375), 21, 1),
  ('tablet', Size(820, 1180), 20, 1),
  ('small laptop', Size(1024, 600), 0, 1),
  ('laptop', Size(1366, 768), 0, 1),
  ('desktop', Size(1440, 900), 0, 1),
];

Future<void> pumpAt(
  WidgetTester tester,
  Size size,
  double bottomInset,
  double textScale,
) async {
  tester.view.devicePixelRatio = 2;
  tester.view.physicalSize = size * 2;
  tester.view.padding = FakeViewPadding(bottom: bottomInset * 2);
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  await tester.pumpWidget(const ExampleApp());
  await tester.pumpAndSettle();
}

ScrollableState scrollableOf(WidgetTester tester, Element list) =>
    tester.state<ScrollableState>(
      find
          .descendant(
            of: find.byWidget(list.widget),
            matching: find.byType(Scrollable),
          )
          .first,
    );

Rect previewRect(WidgetTester tester) => tester.getRect(
  find.ancestor(of: find.text('Preview'), matching: find.byType(Card)).first,
);

void main() {
  setUpAll(loadRealFonts);

  for (final (name, size, bottomInset, textScale) in screens) {
    testWidgets('lays out without overflow, every card reachable: $name', (
      tester,
    ) async {
      await pumpAt(tester, size, bottomInset, textScale);
      expect(tester.takeException(), isNull, reason: 'layout overflow');

      final visibleBottom = size.height - bottomInset;
      final lists = find.byType(ListView).evaluate().toList();
      expect(lists, isNotEmpty);
      // An ExpandableCarousel built on the way down measures itself a frame
      // later and grows the list, so jump until the end stops moving.
      for (var pass = 0; pass < 3; pass++) {
        for (final list in lists) {
          final position = scrollableOf(tester, list).position;
          position.jumpTo(position.maxScrollExtent);
        }
        await tester.pumpAndSettle();
      }

      for (final list in lists) {
        final viewport = tester.getRect(find.byWidget(list.widget));
        final cards = find
            .descendant(
              of: find.byWidget(list.widget),
              matching: find.byType(Card),
            )
            .evaluate()
            .map((e) => tester.getRect(find.byWidget(e.widget)));
        final lastBottom = cards
            .map((r) => r.bottom)
            .reduce((a, b) => a > b ? a : b);
        expect(
          lastBottom,
          lessThanOrEqualTo(viewport.bottom),
          reason: '$name: the last card of a list ends below its viewport',
        );
        expect(
          viewport.bottom,
          lessThanOrEqualTo(visibleBottom),
          reason: '$name: a list runs under the bottom inset',
        );
      }

      // Options and preview must both stay in view: the preview never
      // scrolls away, however far the lists go, and beside it the options
      // stay pinned too.
      // Pinned beside the preview whenever they fit whole with room to spare.
      final pinsOptions =
          (size.width >= 840 || size.width > size.height) &&
          size.height - kToolbarHeight - bottomInset >= 560 * textScale;
      // Off-screen list children are not built, so a missing card is one that
      // scrolled away with the list.
      final optionsText = find.text('Options');
      if (pinsOptions) {
        expect(
          optionsText,
          findsOneWidget,
          reason: '$name: options scrolled away',
        );
      }
      if (optionsText.evaluate().isNotEmpty) {
        final card = find
            .ancestor(of: optionsText, matching: find.byType(Card))
            .evaluate()
            .single;
        final listElements = find.byType(ListView).evaluate().toSet();
        var inList = false;
        card.visitAncestorElements((ancestor) {
          inList = listElements.contains(ancestor);
          return !inList;
        });
        if (!inList) {
          final rect = tester.getRect(find.byWidget(card.widget));
          expect(
            rect.top >= 0 && rect.bottom <= visibleBottom,
            isTrue,
            reason: '$name: pinned options card $rect is cut off',
          );
        }
      }
      final preview = previewRect(tester);
      expect(preview.top, greaterThanOrEqualTo(0), reason: '$name: preview');
      expect(
        preview.bottom,
        lessThanOrEqualTo(visibleBottom),
        reason: '$name: the preview is cut off',
      );
    });
  }

  for (final (name, size, over) in const [
    ('laptop, over the preview', Size(1366, 768), 'Preview'),
    ('laptop, over the options', Size(1366, 768), 'Options'),
    ('landscape phone, over the preview', Size(844, 390), 'Preview'),
    ('phone, over the preview', Size(390, 844), 'Preview'),
  ]) {
    testWidgets('the wheel over a still region scrolls the list: $name', (
      tester,
    ) async {
      await pumpAt(tester, size, 0, 1);
      final list = find.byType(ListView).evaluate().single;
      final position = scrollableOf(tester, list).position;
      expect(position.pixels, 0);

      final still = tester.getCenter(find.text(over));
      final mouse = TestPointer(1, PointerDeviceKind.mouse);
      await tester.sendEventToBinding(mouse.hover(still));
      await tester.sendEventToBinding(mouse.scroll(const Offset(0, 300)));
      await tester.pumpAndSettle();

      expect(position.pixels, greaterThan(0));
    });
  }
}
