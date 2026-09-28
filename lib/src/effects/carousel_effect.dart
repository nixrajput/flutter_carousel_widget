import 'package:flutter/widgets.dart';

import 'carousel_item_position.dart';
import 'presets.dart';

/// Transforms each item of a carousel as it moves.
///
/// Presets cover common transitions, [CarouselEffect.builder] takes any
/// function of the item's position, and [then] chains effects.
@immutable
abstract class CarouselEffect {
  /// Lets subclasses be const.
  const CarouselEffect();

  /// No transform. Items then never rebuild while the carousel scrolls.
  static const CarouselEffect none = _NoEffect();

  /// Wraps each item with [builder]'s result, on every frame the carousel
  /// moves.
  const factory CarouselEffect.builder(
    Widget Function(
      BuildContext context,
      CarouselItemPosition position,
      Widget child,
    )
    builder,
  ) = _BuilderEffect;

  /// Keeps the centre item full size and shrinks its neighbours.
  const factory CarouselEffect.enlarge({
    double factor,
    CarouselEnlargeStrategy strategy,
  }) = EnlargeEffect;

  /// Fades items as they move away from the centre.
  const factory CarouselEffect.fade({double minOpacity}) = FadeEffect;

  /// Moves each item's content slower than its frame.
  const factory CarouselEffect.parallax({double depth}) = ParallaxEffect;

  /// The next item waits small and faded, and grows in.
  const factory CarouselEffect.depth({double minScale, double minOpacity}) =
      DepthEffect;

  /// Neighbours shrink and dim.
  const factory CarouselEffect.zoomOut({double minScale, double minOpacity}) =
      ZoomOutEffect;

  /// The incoming item slides over the current one, which waits behind.
  const factory CarouselEffect.stack({double offset, double minScale}) =
      StackEffect;

  /// Neighbours turn to face the centre, in perspective.
  const factory CarouselEffect.coverflow({double angle, double minScale}) =
      CoverflowEffect;

  /// Items are the faces of a turning cube.
  const factory CarouselEffect.cube({double perspective}) = CubeEffect;

  /// Items flip over in place.
  const factory CarouselEffect.flip({double perspective}) = FlipEffect;

  /// Neighbours tilt about an origin.
  const factory CarouselEffect.rotate({double angle, Alignment origin}) =
      RotateEffect;

  /// Whether the effect ignores the position, so items need not rebuild while
  /// the carousel scrolls.
  bool get isStatic => false;

  /// Wraps [child], the item at [position].
  Widget apply(
    BuildContext context,
    CarouselItemPosition position,
    Widget child,
  );

  /// This effect, then [next] around its result.
  CarouselEffect then(CarouselEffect next) {
    if (next.isStatic) return this;
    if (isStatic) return next;
    return _ChainEffect(this, next);
  }
}

class _NoEffect extends CarouselEffect {
  const _NoEffect();

  @override
  bool get isStatic => true;

  @override
  Widget apply(
    BuildContext context,
    CarouselItemPosition position,
    Widget child,
  ) => child;
}

class _BuilderEffect extends CarouselEffect {
  const _BuilderEffect(this.builder);

  final Widget Function(BuildContext, CarouselItemPosition, Widget) builder;

  @override
  Widget apply(
    BuildContext context,
    CarouselItemPosition position,
    Widget child,
  ) => builder(context, position, child);

  @override
  bool operator ==(Object other) =>
      other is _BuilderEffect && other.builder == builder;

  @override
  int get hashCode => builder.hashCode;
}

class _ChainEffect extends CarouselEffect {
  const _ChainEffect(this.first, this.second);

  final CarouselEffect first;
  final CarouselEffect second;

  @override
  Widget apply(
    BuildContext context,
    CarouselItemPosition position,
    Widget child,
  ) => second.apply(context, position, first.apply(context, position, child));

  @override
  bool operator ==(Object other) =>
      other is _ChainEffect && other.first == first && other.second == second;

  @override
  int get hashCode => Object.hash(first, second);
}
