import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';

const n = 4;

Widget item(int i) => SizedBox(width: 120, height: 80, child: Text('$i'));

Widget carousel({
  required bool expandable,
  required bool builder,
  required bool infinite,
  required Axis axis,
  required bool reverse,
  required FlutterCarouselController controller,
  required CarouselPageChanged onPageChanged,
}) {
  final items = [for (var i = 0; i < n; i++) item(i)];
  Widget byIndex(BuildContext context, int i, int _) => item(i);
  if (expandable) {
    return builder
        ? ExpandableCarousel.builder(
            itemCount: n,
            itemBuilder: byIndex,
            controller: controller,
            infinite: infinite,
            scrollDirection: axis,
            reverse: reverse,
            autofocus: true,
            indicator: null,
            onPageChanged: onPageChanged,
          )
        : ExpandableCarousel(
            items: items,
            controller: controller,
            infinite: infinite,
            scrollDirection: axis,
            reverse: reverse,
            autofocus: true,
            indicator: null,
            onPageChanged: onPageChanged,
          );
  }
  return builder
      ? FlutterCarousel.builder(
          itemCount: n,
          itemBuilder: byIndex,
          height: 200,
          controller: controller,
          infinite: infinite,
          scrollDirection: axis,
          reverse: reverse,
          autofocus: true,
          indicator: null,
          onPageChanged: onPageChanged,
        )
      : FlutterCarousel(
          items: items,
          height: 200,
          controller: controller,
          infinite: infinite,
          scrollDirection: axis,
          reverse: reverse,
          autofocus: true,
          indicator: null,
          onPageChanged: onPageChanged,
        );
}

void main() {
  for (final expandable in [false, true]) {
    for (final builder in [false, true]) {
      for (final infinite in [false, true]) {
        for (final axis in Axis.values) {
          for (final dir in TextDirection.values) {
            for (final reverse in [false, true]) {
              final name = [
                if (expandable) 'ExpandableCarousel' else 'FlutterCarousel',
                if (builder) 'builder',
                if (infinite) 'infinite',
                axis.name,
                dir.name,
                if (reverse) 'reverse',
              ].join(' ');
              testWidgets(
                '$name: drag, controller and keys each move one item',
                (tester) async {
                  final flipped =
                      (axis == Axis.horizontal && dir == TextDirection.rtl) !=
                      reverse;
                  final c = FlutterCarouselController();
                  addTearDown(c.dispose);
                  final changes = <(int, CarouselPageChangedReason)>[];
                  await tester.pumpWidget(
                    host(
                      carousel(
                        expandable: expandable,
                        builder: builder,
                        infinite: infinite,
                        axis: axis,
                        reverse: reverse,
                        controller: c,
                        onPageChanged: (i, r) => changes.add((i, r)),
                      ),
                      textDirection: dir,
                    ),
                  );
                  await tester.pump();

                  // Dragging towards the leading edge brings the next item in.
                  final forward = flipped ? 100.0 : -100.0;
                  await tester.fling(
                    find.byType(PageView),
                    axis == Axis.horizontal
                        ? Offset(forward, 0)
                        : Offset(0, forward),
                    1000,
                  );
                  await tester.pumpAndSettle();
                  expect(changes.last, (1, CarouselPageChangedReason.manual));
                  expect(c.index, 1);
                  expect(c.position, closeTo(1, 1e-3));

                  unawaited(c.nextPage());
                  await tester.pumpAndSettle();
                  expect(changes.last, (
                    2,
                    CarouselPageChangedReason.controller,
                  ));
                  expect(c.position, closeTo(2, 1e-3));

                  final next = axis == Axis.horizontal
                      ? (flipped
                            ? LogicalKeyboardKey.arrowLeft
                            : LogicalKeyboardKey.arrowRight)
                      : (flipped
                            ? LogicalKeyboardKey.arrowUp
                            : LogicalKeyboardKey.arrowDown);
                  await tester.sendKeyEvent(next);
                  await tester.pumpAndSettle();
                  expect(changes.last, (3, CarouselPageChangedReason.keyboard));

                  // Past the last item: an infinite carousel wraps, a finite one stays.
                  await tester.sendKeyEvent(next);
                  await tester.pumpAndSettle();
                  expect(changes, hasLength(infinite ? 4 : 3));
                  expect(c.index, infinite ? 0 : 3);
                },
              );
            }
          }
        }
      }
    }
  }
}
