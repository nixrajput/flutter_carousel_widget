import 'package:flutter/painting.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

SlideIndicatorGeometry g(
  double position, {
  int n = 5,
  bool infinite = false,
  Axis axis = Axis.horizontal,
  bool flipped = false,
}) => SlideIndicatorGeometry(
  itemCount: n,
  position: position,
  infinite: infinite,
  axis: axis,
  flipped: flipped,
);

void main() {
  test('nearest rounds, from floors, progress is the fraction (#62)', () {
    expect((g(0.9).nearest, g(0.9).from, g(0.9).to), (1, 0, 1));
    expect(g(0.9).progress, closeTo(0.9, 1e-9));
    expect((g(1.9).nearest, g(1.9).from), (2, 1));
    expect(g(4).to, isNull, reason: 'finite: nowhere past the last dot');
    expect(g(4.5, infinite: true).to, 0, reason: 'infinite wraps to the first');
    expect(g(4.5, infinite: true).nearest, 0);
    expect(g(0, n: 0).nearest, 0);
  });

  test('style equality covers every field', () {
    const a = SlideIndicatorStyle();
    expect(a.activeColor, const Color(0xFFFFFFFF));
    expect(a.inactiveColor, const Color(0x66FFFFFF));
    expect(a, const SlideIndicatorStyle());
    for (final other in const [
      SlideIndicatorStyle(activeColor: Color(0xFF000000)),
      SlideIndicatorStyle(inactiveColor: Color(0xFF000000)),
      SlideIndicatorStyle(borderColor: Color(0xFF000000)),
      SlideIndicatorStyle(borderWidth: 2),
      SlideIndicatorStyle(radius: 4),
      SlideIndicatorStyle(spacing: 10),
      SlideIndicatorStyle(halo: BoxDecoration()),
      SlideIndicatorStyle(haloPadding: EdgeInsets.zero),
      SlideIndicatorStyle(animated: true),
    ]) {
      expect(a == other, isFalse, reason: '$other');
    }
  });

  test('dot centres follow item order, mirrored when flipped (#66)', () {
    const p = CircularSlideIndicator(); // radius 6, spacing 20
    expect(p.size(5, Axis.horizontal), const Size(92, 12));
    expect(p.size(5, Axis.vertical), const Size(12, 92));
    expect(p.size(0, Axis.horizontal), const Size(0, 12));
    expect(p.dotCenter(0, g(0)), const Offset(6, 6));
    expect(p.dotCenter(4, g(0)), const Offset(86, 6));
    expect(p.dotCenter(0, g(0, flipped: true)), const Offset(86, 6));
    expect(p.dotCenter(1, g(0, axis: Axis.vertical)), const Offset(6, 26));
    const bordered = CircularSlideIndicator(
      style: SlideIndicatorStyle(
        borderColor: Color(0xFF000000),
        borderWidth: 2,
      ),
    );
    expect(bordered.size(2, Axis.horizontal), const Size(34, 14));
    expect(bordered.dotCenter(0, g(0, n: 2)), const Offset(7, 7));
  });

  test('the slide painter moves the active dot continuously', () {
    const p = CircularSlideIndicator();
    final canvas = RecordingCanvas();
    p.paint(canvas, p.size(5, Axis.horizontal), g(1.5));
    final active = canvas.circles.where((c) => c.$3 == p.style.activeColor);
    expect(active.single.$1, const Offset(36, 6)); // halfway between 26 and 46
    expect(
      canvas.circles.where((c) => c.$3 == p.style.inactiveColor),
      hasLength(5),
    );
  });

  test('the slide painter wraps only when infinite', () {
    const p = CircularSlideIndicator();
    final finite = RecordingCanvas();
    p.paint(finite, p.size(5, Axis.horizontal), g(4));
    expect(
      finite.circles.where((c) => c.$3 == p.style.activeColor),
      hasLength(1),
    );
    final looping = RecordingCanvas();
    p.paint(looping, p.size(5, Axis.horizontal), g(4.5, infinite: true));
    final active = looping.circles
        .where((c) => c.$3 == p.style.activeColor)
        .toList();
    expect(active.map((c) => c.$1), [const Offset(96, 6), const Offset(-4, 6)]);
    expect(looping.clips, greaterThan(0));
  });

  test('CarouselIndicator defaults and equality', () {
    const i = CarouselIndicator();
    expect(i.painter, const CircularSlideIndicator());
    expect(i.placement, CarouselIndicatorPlacement.overlay);
    expect(i.alignment, isNull, reason: 'resolved per axis by the carousel');
    expect(i.margin, const EdgeInsets.all(8));
    expect(i.tapToNavigate, isTrue);
    expect(i, const CarouselIndicator());
    expect(i == const CarouselIndicator(tapToNavigate: false), isFalse);
  });

  test('the static painter switches on rounding, or animates when asked', () {
    const still = CircularStaticIndicator();
    final a = RecordingCanvas();
    still.paint(a, still.size(5, Axis.horizontal), g(1.4));
    expect(
      a.circles.where((c) => c.$3 == still.style.activeColor).map((c) => c.$1),
      [const Offset(26, 6)],
    );
    const moving = CircularStaticIndicator(
      style: SlideIndicatorStyle(animated: true),
    );
    final b = RecordingCanvas();
    moving.paint(b, moving.size(5, Axis.horizontal), g(1.25));
    final active = b.circles
        .where((c) => c.$3 == moving.style.activeColor)
        .toList();
    expect(active.map((c) => (c.$1, c.$2)), [
      (const Offset(26, 6), 4.5),
      (const Offset(46, 6), 1.5),
    ]);
  });

  test(
    'the wave painter shrinks the dot midway and restores it on arrival',
    () {
      const p = CircularWaveIndicator();
      final mid = RecordingCanvas();
      p.paint(mid, p.size(5, Axis.horizontal), g(1.5));
      final dot = mid.circles.lastWhere((c) => c.$3 == p.style.activeColor);
      expect(dot.$1, const Offset(36, 6));
      expect(dot.$2, closeTo(1.8, 1e-9));
      final settled = RecordingCanvas();
      p.paint(settled, p.size(5, Axis.horizontal), g(2));
      expect(
        settled.circles.lastWhere((c) => c.$3 == p.style.activeColor).$2,
        6,
      );
    },
  );

  test('the fill painter fills from the first dot to the position', () {
    const p = SequentialFillIndicator(
      style: SlideIndicatorStyle(animated: true),
    );
    final canvas = RecordingCanvas();
    p.paint(canvas, p.size(5, Axis.horizontal), g(2.5));
    expect(canvas.lines.single.$1, const Offset(6, 6));
    expect(canvas.lines.single.$2, const Offset(56, 6));
    expect(canvas.lines.single.$3, 12);
    expect(canvas.clips, 1);
    const stepped = SequentialFillIndicator();
    final c2 = RecordingCanvas();
    stepped.paint(c2, stepped.size(5, Axis.horizontal), g(2.4));
    expect(c2.lines.single.$2, const Offset(46, 6));
  });

  test('styles, painters and indicators hash by value', () {
    // Not const: a const instance never runs its constructor or asserts.
    final r = 5.0;
    final style = SlideIndicatorStyle(radius: r);
    expect(style.hashCode, SlideIndicatorStyle(radius: r).hashCode);
    final other = SlideIndicatorStyle(radius: r + 1);
    for (final (a, same, different)
        in <(SlideIndicator, SlideIndicator, SlideIndicator)>[
          (
            CircularSlideIndicator(style: style),
            CircularSlideIndicator(style: SlideIndicatorStyle(radius: r)),
            CircularSlideIndicator(style: other),
          ),
          (
            CircularStaticIndicator(style: style),
            CircularStaticIndicator(style: SlideIndicatorStyle(radius: r)),
            CircularStaticIndicator(style: other),
          ),
          (
            CircularWaveIndicator(style: style),
            CircularWaveIndicator(style: SlideIndicatorStyle(radius: r)),
            CircularWaveIndicator(style: other),
          ),
          (
            SequentialFillIndicator(style: style),
            SequentialFillIndicator(style: SlideIndicatorStyle(radius: r)),
            SequentialFillIndicator(style: other),
          ),
        ]) {
      expect(a, same);
      expect(a.hashCode, same.hashCode);
      expect(a == different, isFalse, reason: '$a');
    }
    final indicator = CarouselIndicator(
      painter: CircularWaveIndicator(style: style),
    );
    expect(
      indicator.hashCode,
      CarouselIndicator(painter: CircularWaveIndicator(style: style)).hashCode,
    );
  });

  test('the wave painter wraps past the last dot when infinite', () {
    const p = CircularWaveIndicator();
    final canvas = RecordingCanvas();
    p.paint(canvas, p.size(5, Axis.horizontal), g(4.5, infinite: true));
    final active = canvas.circles.where((c) => c.$3 == p.style.activeColor);
    expect(active.map((c) => c.$1), [const Offset(96, 6), const Offset(-4, 6)]);
    expect(canvas.clips, 1);
  });

  test('a border colour rings every dot', () {
    const p = CircularSlideIndicator(
      style: SlideIndicatorStyle(
        borderColor: Color(0xFF000000),
        borderWidth: 2,
      ),
    );
    final canvas = RecordingCanvas();
    p.paint(canvas, p.size(3, Axis.horizontal), g(0, n: 3));
    expect(
      canvas.circles.where((c) => c.$4 == PaintingStyle.stroke),
      hasLength(3),
    );
  });
}
