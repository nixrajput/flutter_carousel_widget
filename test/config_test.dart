import 'package:flutter/widgets.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_carousel_widget/src/engine/carousel_engine.dart';
import 'package:flutter_test/flutter_test.dart';

CarouselItemPosition at(
  double offset, {
  Axis axis = Axis.horizontal,
  TextDirection dir = TextDirection.ltr,
  bool reverse = false,
}) => CarouselItemPosition(
  index: 0,
  itemCount: 3,
  offset: offset,
  axis: axis,
  textDirection: dir,
  reverse: reverse,
  viewportFraction: 0.8,
  extent: const Size(320, 200),
);

Widget passThrough(BuildContext _, CarouselItemPosition _, Widget child) =>
    child;

void main() {
  test('CarouselAutoPlay defaults and equality', () {
    const a = CarouselAutoPlay();
    expect(kCarouselMoveDuration, const Duration(milliseconds: 500));
    expect(kCarouselMoveCurve, Curves.easeInOutCubicEmphasized);
    expect(a.interval, const Duration(seconds: 5));
    expect((a.duration, a.curve, a.intervalFor), (null, null, null));
    expect(
      (
        a.pauseOnTouch,
        a.pauseOnHover,
        a.pauseOnFocus,
        a.restartOnInteraction,
        a.stopAtEnd,
      ),
      (true, true, true, true, false),
    );
    expect(a, const CarouselAutoPlay());
    expect(a, isNot(const CarouselAutoPlay(stopAtEnd: true)));
    expect(a.hashCode, const CarouselAutoPlay().hashCode);
  });

  test('visualOffset follows the screen under RTL, reverse and vertical', () {
    expect(at(1).visualOffset, 1);
    expect(at(1, dir: TextDirection.rtl).visualOffset, -1);
    expect(at(1, reverse: true).visualOffset, -1);
    expect(at(1, dir: TextDirection.rtl, reverse: true).visualOffset, 1);
    expect(at(1, axis: Axis.vertical, dir: TextDirection.rtl).visualOffset, 1);
    expect(at(1, axis: Axis.vertical, reverse: true).visualOffset, -1);
    expect(at(0).mainExtent, 320);
    expect(at(0, axis: Axis.vertical).mainExtent, 200);
  });

  testWidgets('none is static and returns the child untouched', (tester) async {
    const child = SizedBox();
    late Widget out;
    await tester.pumpWidget(
      Builder(
        builder: (context) {
          out = CarouselEffect.none.apply(context, at(0.5), child);
          return const SizedBox();
        },
      ),
    );
    expect(CarouselEffect.none.isStatic, isTrue);
    expect(identical(out, child), isTrue);
  });

  testWidgets('builder applies its function, and then chains inside out', (
    tester,
  ) async {
    final tags =
        CarouselEffect.builder(
          (_, p, child) =>
              KeyedSubtree(key: ValueKey('a${p.offset}'), child: child),
        ).then(
          CarouselEffect.builder(
            (_, p, child) =>
                KeyedSubtree(key: const ValueKey('b'), child: child),
          ),
        );
    late Widget out;
    await tester.pumpWidget(
      Builder(
        builder: (context) {
          out = tags.apply(context, at(0.5), const SizedBox());
          return const SizedBox();
        },
      ),
    );
    expect(out.key, const ValueKey('b'));
    expect((out as KeyedSubtree).child.key, const ValueKey('a0.5'));
    expect(tags.isStatic, isFalse);
    expect(
      identical(
        CarouselEffect.none.then(CarouselEffect.none),
        CarouselEffect.none,
      ),
      isTrue,
    );
  });

  test('CarouselSnapPhysics keeps Flutter\'s spring unless given one', () {
    const platform = BouncingScrollPhysics();
    expect(
      const CarouselSnapPhysics().applyTo(platform).spring,
      platform.spring,
    );
    final soft = SpringDescription.withDampingRatio(
      mass: 0.5,
      stiffness: 60,
      ratio: 1.2,
    );
    final physics = CarouselSnapPhysics(snapSpring: soft).applyTo(platform);
    expect(physics.spring, soft);
    expect(physics.parent, isA<BouncingScrollPhysics>());
    // PageView wraps its physics in PageScrollPhysics; the spring must survive.
    expect(const PageScrollPhysics().applyTo(physics).spring, soft);
  });

  test('positions and effects compare and hash by value', () {
    expect(at(0.5), at(0.5));
    expect(at(0.5).hashCode, at(0.5).hashCode);
    expect(at(0.5) == at(0.6), isFalse);
    const builder = CarouselEffect.builder(passThrough);
    expect(builder, const CarouselEffect.builder(passThrough));
    expect(
      builder.hashCode,
      const CarouselEffect.builder(passThrough).hashCode,
    );
    final chain = builder.then(const CarouselEffect.fade());
    expect(chain, builder.then(const CarouselEffect.fade()));
    expect(chain.hashCode, builder.then(const CarouselEffect.fade()).hashCode);
    expect(chain == builder.then(const CarouselEffect.zoomOut()), isFalse);
  });
}
