import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../engine/carousel_engine.dart';
import '../types.dart';
import 'carousel_indicator.dart';
import 'slide_indicator.dart';

/// How tall, across the row, a dot's tap target is at least: the size
/// Android asks touch targets to be.
const double _minTapTarget = 48;

/// How far each dot's tap target reaches past what the dots paint: [along]
/// past the first and last dot, [before] and [after] across the row.
typedef _Band = ({double along, double before, double after});

/// A dot's target is one spacing wide and 48 pixels tall, however small it
/// is drawn. The margin counts towards the height first; what is still
/// missing grows towards the items, so none of it falls off the carousel's
/// edge, where no tap reaches it.
_Band _bandFor(
  CarouselIndicator indicator,
  CarouselView view,
  AlignmentGeometry alignment,
  TextDirection direction,
) {
  if (!indicator.tapToNavigate) return (along: 0, before: 0, after: 0);
  final style = indicator.painter.style;
  final horizontal = view.axis == Axis.horizontal;
  final paintSize = indicator.painter.size(view.itemCount, view.axis);
  final inset =
      indicator.margin.resolve(direction) +
      (style.halo == null
          ? EdgeInsets.zero
          : style.haloPadding.resolve(direction));
  final (marginBefore, marginAfter) = horizontal
      ? (inset.top, inset.bottom)
      : (inset.left, inset.right);
  final grow = math.max(
    0.0,
    _minTapTarget -
        marginBefore -
        marginAfter -
        (horizontal ? paintSize.height : paintSize.width),
  );
  // Below the items the dots always sit next to them, whatever the alignment
  // says across the row.
  final towards = indicator.placement == CarouselIndicatorPlacement.below
      ? (horizontal ? Alignment.bottomCenter : AlignmentDirectional.centerEnd)
      : alignment;
  final at = towards.resolve(direction);
  final growBefore = grow * (1 + (horizontal ? at.y : at.x)) / 2;
  return (
    along: math.max(0.0, style.spacing / 2 - style.radius),
    before: marginBefore + growBefore,
    after: marginAfter + grow - growBefore,
  );
}

/// Paints a carousel's indicator, repainting from the scroll position without
/// rebuilding widgets. Its dots are labelled for screen readers and, unless
/// [CarouselIndicator.tapToNavigate] is off, move to their item when tapped;
/// [IndicatorTapBand] around the placed carousel widens where a tap lands.
class IndicatorView extends StatelessWidget {
  /// Creates the view for [indicator] over [view], placed by [alignment].
  /// [dotsKey] marks the painted dots for the [IndicatorTapBand].
  const IndicatorView({
    super.key,
    required this.indicator,
    required this.view,
    required this.alignment,
    required this.dotsKey,
  });

  /// The indicator's configuration.
  final CarouselIndicator indicator;

  /// The carousel it follows.
  final CarouselView view;

  /// Where the dots sit in the carousel.
  final AlignmentGeometry alignment;

  /// Marks the painted dots.
  final GlobalKey dotsKey;

  @override
  Widget build(BuildContext context) {
    final painter = indicator.painter;
    final style = painter.style;
    final band = _bandFor(
      indicator,
      view,
      alignment,
      Directionality.maybeOf(context) ?? TextDirection.ltr,
    );
    // Rebuilding on the current item refreshes the dots' semantics; painting
    // follows the scroll by itself.
    Widget dots = ValueListenableBuilder<int>(
      valueListenable: view.current,
      builder: (context, _, _) => CustomPaint(
        key: dotsKey,
        size: painter.size(view.itemCount, view.axis),
        painter: _DotsPainter(
          painter,
          view,
          tappable: indicator.tapToNavigate,
          band: band,
        ),
      ),
    );
    if (indicator.tapToNavigate) {
      dots = GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTapUp: (details) => unawaited(
          view.goTo(
            _nearestDot(details.localPosition),
            CarouselPageChangedReason.manual,
          ),
        ),
        child: dots,
      );
    }
    final halo = style.halo;
    if (halo != null) {
      dots = DecoratedBox(
        decoration: halo,
        child: Padding(padding: style.haloPadding, child: dots),
      );
    }
    return Padding(padding: indicator.margin, child: dots);
  }

  int _nearestDot(Offset at) {
    final g = view.geometry;
    var best = 0;
    var bestDistance = double.infinity;
    for (var i = 0; i < g.itemCount; i++) {
      final d = (indicator.painter.dotCenter(i, g) - at).distance;
      if (d < bestDistance) {
        best = i;
        bestDistance = d;
      }
    }
    return best;
  }
}

/// Wraps the placed carousel, items and dots together, so a dot's target can
/// reach past its own box into the items: a tap in the band around the dots
/// marked by [dotsKey] hit-tests them at the nearest point inside, and keeps
/// its real position, so the nearest dot wins.
class IndicatorTapBand extends StatelessWidget {
  /// Creates the band for [indicator]'s dots over [view].
  const IndicatorTapBand({
    super.key,
    required this.indicator,
    required this.view,
    required this.alignment,
    required this.dotsKey,
    required this.child,
  });

  /// The indicator's configuration.
  final CarouselIndicator indicator;

  /// The carousel it follows.
  final CarouselView view;

  /// Where the dots sit in the carousel.
  final AlignmentGeometry alignment;

  /// Marks the painted dots.
  final GlobalKey dotsKey;

  /// The carousel with its indicator placed.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!indicator.tapToNavigate) return child;
    final band = _bandFor(
      indicator,
      view,
      alignment,
      Directionality.maybeOf(context) ?? TextDirection.ltr,
    );
    return _TapBand(
      dotsKey: dotsKey,
      axis: view.axis,
      band: band,
      child: child,
    );
  }
}

class _DotsPainter extends CustomPainter {
  _DotsPainter(
    this.indicator,
    this.view, {
    required this.tappable,
    required this.band,
  }) : _layout = (view.axis, view.infinite, view.geometry.flipped),
       super(repaint: view.scroll);

  final SlideIndicator indicator;
  final CarouselView view;
  final bool tappable;
  final _Band band;

  // The view is the same engine object across rebuilds, so a flip, a change
  // of axis or of looping is only visible in what it reported at creation.
  final (Axis, bool, bool) _layout;

  @override
  void paint(Canvas canvas, Size size) =>
      indicator.paint(canvas, size, view.geometry);

  @override
  bool shouldRepaint(_DotsPainter old) =>
      old.indicator != indicator || old.view != view || old._layout != _layout;

  @override
  SemanticsBuilderCallback get semanticsBuilder => (size) {
    final g = view.geometry;
    final style = indicator.style;
    final half = math.max(style.spacing, 2 * style.radius) / 2;
    final horizontal = g.axis == Axis.horizontal;
    return [
      for (var i = 0; i < g.itemCount; i++)
        CustomPainterSemantics(
          rect: switch (indicator.dotCenter(i, g)) {
            final c when horizontal => Rect.fromLTRB(
              c.dx - half,
              -band.before,
              c.dx + half,
              size.height + band.after,
            ),
            final c => Rect.fromLTRB(
              -band.before,
              c.dy - half,
              size.width + band.after,
              c.dy + half,
            ),
          },
          properties: SemanticsProperties(
            label: view.slideLabel(i),
            textDirection: view.textDirection,
            selected: i == g.nearest,
            button: tappable,
            onTap: tappable
                ? () =>
                      unawaited(view.goTo(i, CarouselPageChangedReason.manual))
                : null,
          ),
        ),
    ];
  };

  @override
  bool shouldRebuildSemantics(_DotsPainter old) => true;
}

class _TapBand extends SingleChildRenderObjectWidget {
  const _TapBand({
    required this.dotsKey,
    required this.axis,
    required this.band,
    required super.child,
  });

  final GlobalKey dotsKey;
  final Axis axis;
  final _Band band;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderTapBand(dotsKey, axis, band);

  @override
  void updateRenderObject(BuildContext context, _RenderTapBand renderObject) =>
      renderObject
        ..dotsKey = dotsKey
        ..axis = axis
        ..band = band;
}

class _RenderTapBand extends RenderProxyBox {
  _RenderTapBand(this.dotsKey, this.axis, this.band);

  GlobalKey dotsKey;
  Axis axis;
  _Band band;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    // Laid out whenever a hit test runs; the checks only keep a stray tap
    // during a rebuild from throwing.
    final painted = dotsKey.currentContext?.findRenderObject();
    final dots = painted is RenderBox && painted.attached && painted.hasSize
        ? MatrixUtils.transformRect(
            painted.getTransformTo(this),
            Offset.zero & painted.size,
          )
        : Rect.zero;
    final (along, before, after) = (band.along, band.before, band.after);
    final reach = axis == Axis.horizontal
        ? Rect.fromLTRB(
            dots.left - along,
            dots.top - before,
            dots.right + along,
            dots.bottom + after,
          )
        : Rect.fromLTRB(
            dots.left - before,
            dots.top - along,
            dots.right + after,
            dots.bottom + along,
          );
    if (dots.isEmpty || !reach.contains(position)) {
      return super.hitTest(result, position: position);
    }
    final inside = Offset(
      clampDouble(position.dx, dots.left, dots.right - 0.01),
      clampDouble(position.dy, dots.top, dots.bottom - 0.01),
    );
    if (!hitTestChildren(result, position: inside)) return false;
    result.add(BoxHitTestEntry(this, position));
    return true;
  }
}
