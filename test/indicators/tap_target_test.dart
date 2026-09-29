import 'package:flutter/widgets.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_carousel_widget/src/indicators/indicator_view.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

/// A painter of the app's own, which gets the same targets as the built-in
/// ones because the view, not the painter, owns them.
class _Plain extends SlideIndicator {
  const _Plain({super.style});

  @override
  void paint(Canvas canvas, Size size, SlideIndicatorGeometry geometry) {}
}

void main() {
  testWidgets('every painter, axis, placement and alignment gets 24 by 48 '
      'targets that take a tap at either edge', (tester) async {
    final handle = tester.ensureSemantics();
    const haloed = SlideIndicatorStyle(
      halo: BoxDecoration(color: Color(0x33000000)),
    );
    final painters = <String, SlideIndicator Function(SlideIndicatorStyle)>{
      'slide': (s) => CircularSlideIndicator(style: s),
      'static': (s) => CircularStaticIndicator(style: s),
      'wave': (s) => CircularWaveIndicator(style: s),
      'fill': (s) => SequentialFillIndicator(style: s),
      'custom': (s) => _Plain(style: s),
    };
    var cases = 0;
    for (final MapEntry(key: name, value: painter) in painters.entries) {
      for (final axis in Axis.values) {
        for (final placement in CarouselIndicatorPlacement.values) {
          for (final bias in const [-1.0, 0.0, 1.0]) {
            for (final dir in TextDirection.values) {
              for (final style in const [SlideIndicatorStyle(), haloed]) {
                for (final expandable in [false, true]) {
                  final horizontal = axis == Axis.horizontal;
                  final label =
                      '$name $axis $placement bias $bias $dir '
                      '${style.halo == null ? 'plain' : 'halo'} '
                      '${expandable ? 'expandable' : 'fixed'}';
                  final controller = FlutterCarouselController();
                  final indicator = CarouselIndicator(
                    painter: painter(style),
                    placement: placement,
                    alignment: horizontal
                        ? Alignment(0, bias)
                        : AlignmentDirectional(bias, 0),
                  );
                  Widget carousel = expandable
                      ? ExpandableCarousel(
                          key: ValueKey(cases),
                          controller: controller,
                          scrollDirection: axis,
                          indicator: indicator,
                          items: [
                            for (var i = 0; i < 5; i++)
                              horizontal
                                  ? SizedBox(height: 200, child: Text('$i'))
                                  : SizedBox(width: 200, child: Text('$i')),
                          ],
                        )
                      : FlutterCarousel(
                          key: ValueKey(cases),
                          controller: controller,
                          scrollDirection: axis,
                          indicator: indicator,
                          height: 200,
                          items: boxes(5),
                        );
                  if (!horizontal) {
                    carousel = SizedBox(height: 300, child: carousel);
                  }
                  cases++;
                  await tester.pumpWidget(host(carousel, textDirection: dir));
                  await tester.pumpAndSettle();

                  final dot = find.semantics
                      .byLabel('Slide 2 of 5')
                      .evaluate()
                      .single
                      .rect;
                  final (along, across) = horizontal
                      ? (dot.width, dot.height)
                      : (dot.height, dot.width);
                  expect(along, 24, reason: label);
                  expect(across, greaterThanOrEqualTo(48), reason: label);

                  // The dot's rect is in the painted box's coordinates: tap
                  // just inside each of its outer edges, where a screen
                  // reader says the second dot is.
                  final paint = tester.getRect(
                    find
                        .descendant(
                          of: find.byType(IndicatorView),
                          matching: find.byType(CustomPaint),
                        )
                        .first,
                  );
                  final target = dot.shift(paint.topLeft);
                  final points = horizontal
                      ? [
                          Offset(target.center.dx, target.top + 1),
                          Offset(target.center.dx, target.bottom - 1),
                        ]
                      : [
                          Offset(target.left + 1, target.center.dy),
                          Offset(target.right - 1, target.center.dy),
                        ];
                  for (final point in points) {
                    controller.jumpToPage(0);
                    await tester.pumpAndSettle();
                    await tester.tapAt(point);
                    await tester.pumpAndSettle();
                    expect(controller.index, 1, reason: '$label at $point');
                  }
                  controller.dispose();
                }
              }
            }
          }
        }
      }
    }
    expect(cases, 5 * 2 * 2 * 3 * 2 * 2 * 2);
    handle.dispose();
  });
}
