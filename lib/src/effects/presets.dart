import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'carousel_effect.dart';
import 'carousel_item_position.dart';

/// How [EnlargeEffect] shrinks the items beside the centre one.
enum CarouselEnlargeStrategy {
  /// Scales them down around their own centre.
  scale,

  /// Shortens them across the scroll axis, keeping their length along it.
  height,

  /// Scales them down towards the centre item, keeping the gap between them.
  zoom,
}

double _distance(CarouselItemPosition p) => p.offset.abs().clamp(0.0, 1.0);

double _lerp(double a, double b, double t) => a + (b - a) * t;

Offset _along(Axis axis, double amount) =>
    axis == Axis.horizontal ? Offset(amount, 0) : Offset(0, amount);

Matrix4 _perspective(double depth) => Matrix4.identity()..setEntry(3, 2, depth);

/// Keeps the centre item full size and shrinks its neighbours: 3.x's
/// `enlargeCenterPage`.
class EnlargeEffect extends CarouselEffect {
  /// Creates the effect; see [CarouselEffect.enlarge].
  const EnlargeEffect({
    this.factor = 0.25,
    this.strategy = CarouselEnlargeStrategy.scale,
  }) : assert(factor > 0 && factor <= 1);

  /// How much smaller a neighbour one item away is, before easing.
  final double factor;

  /// How the neighbours shrink.
  final CarouselEnlargeStrategy strategy;

  @override
  Widget apply(BuildContext context, CarouselItemPosition p, Widget child) {
    final d = Curves.easeOut.transform(
      (1 - p.offset.abs() * factor).clamp(0.0, 1.0),
    );
    final horizontal = p.axis == Axis.horizontal;
    return switch (strategy) {
      CarouselEnlargeStrategy.scale => Transform.scale(scale: d, child: child),
      CarouselEnlargeStrategy.height => FractionallySizedBox(
        heightFactor: horizontal ? d : null,
        widthFactor: horizontal ? null : d,
        child: child,
      ),
      CarouselEnlargeStrategy.zoom => Transform.scale(
        scale: d,
        alignment: _towardsCentre(p),
        child: child,
      ),
    };
  }

  Alignment _towardsCentre(CarouselItemPosition p) {
    final v = p.visualOffset;
    if (v == 0) return Alignment.center;
    if (p.axis == Axis.horizontal) {
      return v < 0 ? Alignment.centerRight : Alignment.centerLeft;
    }
    return v < 0 ? Alignment.bottomCenter : Alignment.topCenter;
  }

  @override
  bool operator ==(Object other) =>
      other is EnlargeEffect &&
      other.factor == factor &&
      other.strategy == strategy;

  @override
  int get hashCode => Object.hash(EnlargeEffect, factor, strategy);
}

/// Fades items as they move away from the centre.
class FadeEffect extends CarouselEffect {
  /// Creates the effect; see [CarouselEffect.fade].
  const FadeEffect({this.minOpacity = 0.3})
    : assert(minOpacity >= 0 && minOpacity <= 1);

  /// The opacity one item away and beyond.
  final double minOpacity;

  @override
  Widget apply(BuildContext context, CarouselItemPosition p, Widget child) =>
      Opacity(opacity: _lerp(1, minOpacity, _distance(p)), child: child);

  @override
  bool operator ==(Object other) =>
      other is FadeEffect && other.minOpacity == minOpacity;

  @override
  int get hashCode => Object.hash(FadeEffect, minOpacity);
}

/// Moves each item's content slower than its frame, so the picture seems to
/// sit behind the page.
class ParallaxEffect extends CarouselEffect {
  /// Creates the effect; see [CarouselEffect.parallax].
  const ParallaxEffect({this.depth = 0.3}) : assert(depth > 0 && depth <= 1);

  /// How far behind the content sits: the share of the page it is enlarged
  /// by and can shift.
  final double depth;

  @override
  Widget apply(BuildContext context, CarouselItemPosition p, Widget child) {
    final shift = -p.visualOffset.clamp(-1.0, 1.0) * depth * p.mainExtent / 2;
    return ClipRect(
      child: Transform.translate(
        offset: _along(p.axis, shift),
        child: Transform.scale(scale: 1 + depth, child: child),
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ParallaxEffect && other.depth == depth;

  @override
  int get hashCode => Object.hash(ParallaxEffect, depth);
}

/// The next item waits in place, small and faded, and grows in as the current
/// one slides away (Android's depth page transformer).
class DepthEffect extends CarouselEffect {
  /// Creates the effect; see [CarouselEffect.depth].
  const DepthEffect({this.minScale = 0.75, this.minOpacity = 0})
    : assert(minScale > 0 && minScale <= 1),
      assert(minOpacity >= 0 && minOpacity <= 1);

  /// The next item's size before it starts to grow.
  final double minScale;

  /// The next item's opacity before it starts to fade in.
  final double minOpacity;

  @override
  Widget apply(BuildContext context, CarouselItemPosition p, Widget child) {
    // Always the same three widgets, so an item crossing the centre keeps its
    // element and state; the current and earlier items get identity values.
    final t = p.offset.clamp(0.0, 1.0);
    final hold = t == 0 ? 0.0 : -p.visualOffset.clamp(-1.0, 1.0) * p.mainExtent;
    return Opacity(
      opacity: _lerp(1, minOpacity, t),
      child: Transform.translate(
        offset: _along(p.axis, hold),
        child: Transform.scale(scale: _lerp(1, minScale, t), child: child),
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is DepthEffect &&
      other.minScale == minScale &&
      other.minOpacity == minOpacity;

  @override
  int get hashCode => Object.hash(DepthEffect, minScale, minOpacity);
}

/// Neighbours shrink and dim as they leave the centre.
class ZoomOutEffect extends CarouselEffect {
  /// Creates the effect; see [CarouselEffect.zoomOut].
  const ZoomOutEffect({this.minScale = 0.85, this.minOpacity = 0.5})
    : assert(minScale > 0 && minScale <= 1),
      assert(minOpacity >= 0 && minOpacity <= 1);

  /// The size one item away.
  final double minScale;

  /// The opacity one item away.
  final double minOpacity;

  @override
  Widget apply(BuildContext context, CarouselItemPosition p, Widget child) {
    final t = _distance(p);
    return Opacity(
      opacity: _lerp(1, minOpacity, t),
      child: Transform.scale(scale: _lerp(1, minScale, t), child: child),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ZoomOutEffect &&
      other.minScale == minScale &&
      other.minOpacity == minOpacity;

  @override
  int get hashCode => Object.hash(ZoomOutEffect, minScale, minOpacity);
}

/// A deck: the incoming item slides over the current one, which stays behind,
/// set back and smaller.
class StackEffect extends CarouselEffect {
  /// Creates the effect; see [CarouselEffect.stack].
  const StackEffect({this.offset = 24, this.minScale = 0.9})
    : assert(minScale > 0 && minScale <= 1);

  /// How far back a covered item sits, in logical pixels.
  final double offset;

  /// A covered item's size.
  final double minScale;

  @override
  Widget apply(BuildContext context, CarouselItemPosition p, Widget child) {
    // Later items paint over earlier ones, so only earlier items can wait
    // underneath. The structure never changes, so an item keeps its state.
    final t = (-p.offset).clamp(0.0, 1.0);
    final v = p.visualOffset.clamp(-1.0, 1.0);
    final hold = t == 0 ? 0.0 : -v * p.mainExtent + v.sign * offset * t;
    return Transform.translate(
      offset: _along(p.axis, hold),
      child: Transform.scale(scale: _lerp(1, minScale, t), child: child),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is StackEffect &&
      other.offset == offset &&
      other.minScale == minScale;

  @override
  int get hashCode => Object.hash(StackEffect, offset, minScale);
}

/// Neighbours turn to face the centre, in perspective, like album covers.
class CoverflowEffect extends CarouselEffect {
  /// Creates the effect; see [CarouselEffect.coverflow].
  const CoverflowEffect({this.angle = math.pi / 4, this.minScale = 0.8})
    : assert(minScale > 0 && minScale <= 1);

  /// How far a neighbour one item away is turned, in radians.
  final double angle;

  /// A neighbour's size one item away.
  final double minScale;

  @override
  Widget apply(BuildContext context, CarouselItemPosition p, Widget child) {
    final v = p.visualOffset.clamp(-1.0, 1.0);
    final turn = p.axis == Axis.horizontal
        ? Matrix4.rotationY(-v * angle)
        : Matrix4.rotationX(v * angle);
    return Transform(
      alignment: Alignment.center,
      transform: _perspective(0.001)..multiply(turn),
      child: Transform.scale(scale: _lerp(1, minScale, v.abs()), child: child),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is CoverflowEffect &&
      other.angle == angle &&
      other.minScale == minScale;

  @override
  int get hashCode => Object.hash(CoverflowEffect, angle, minScale);
}

/// Items are the faces of a turning cube. Best with a `viewportFraction` of 1.
class CubeEffect extends CarouselEffect {
  /// Creates the effect; see [CarouselEffect.cube].
  const CubeEffect({this.perspective = 0.002});

  /// The strength of the perspective.
  final double perspective;

  @override
  Widget apply(BuildContext context, CarouselItemPosition p, Widget child) {
    final v = p.visualOffset.clamp(-1.0, 1.0);
    final horizontal = p.axis == Axis.horizontal;
    final turn = horizontal
        ? Matrix4.rotationY(-v * math.pi / 2)
        : Matrix4.rotationX(v * math.pi / 2);
    // Each face turns about the edge it shares with the centre face.
    final hinge = horizontal
        ? (v < 0 ? Alignment.centerRight : Alignment.centerLeft)
        : (v < 0 ? Alignment.bottomCenter : Alignment.topCenter);
    return Transform(
      alignment: hinge,
      transform: _perspective(perspective)..multiply(turn),
      child: child,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is CubeEffect && other.perspective == perspective;

  @override
  int get hashCode => Object.hash(CubeEffect, perspective);
}

/// Items flip over in place, like a card. Best with a `viewportFraction` of 1.
class FlipEffect extends CarouselEffect {
  /// Creates the effect; see [CarouselEffect.flip].
  const FlipEffect({this.perspective = 0.002});

  /// The strength of the perspective.
  final double perspective;

  @override
  Widget apply(BuildContext context, CarouselItemPosition p, Widget child) {
    final v = p.visualOffset.clamp(-1.0, 1.0);
    final horizontal = p.axis == Axis.horizontal;
    final turn = horizontal
        ? Matrix4.rotationY(v * math.pi)
        : Matrix4.rotationX(-v * math.pi);
    return Transform.translate(
      offset: _along(p.axis, -v * p.mainExtent),
      child: Opacity(
        // Past halfway the item shows its back.
        opacity: v.abs() < 0.5 ? 1 : 0,
        child: Transform(
          alignment: Alignment.center,
          transform: _perspective(perspective)..multiply(turn),
          child: child,
        ),
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is FlipEffect && other.perspective == perspective;

  @override
  int get hashCode => Object.hash(FlipEffect, perspective);
}

/// Neighbours tilt about an origin, like cards on a wheel.
class RotateEffect extends CarouselEffect {
  /// Creates the effect; see [CarouselEffect.rotate].
  const RotateEffect({
    this.angle = math.pi / 12,
    this.origin = Alignment.bottomCenter,
  });

  /// The tilt one item away, in radians.
  final double angle;

  /// The point the items tilt about.
  final Alignment origin;

  @override
  Widget apply(BuildContext context, CarouselItemPosition p, Widget child) =>
      Transform.rotate(
        angle: p.visualOffset.clamp(-1.0, 1.0) * angle,
        alignment: origin,
        child: child,
      );

  @override
  bool operator ==(Object other) =>
      other is RotateEffect && other.angle == angle && other.origin == origin;

  @override
  int get hashCode => Object.hash(RotateEffect, angle, origin);
}
