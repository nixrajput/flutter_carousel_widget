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

/// Paints a carousel's indicator, repainting from the scroll position without
/// rebuilding widgets. Its dots are labelled for screen readers and, unless
/// [CarouselIndicator.tapToNavigate] is off, move to their item when tapped.
///
/// A dot's target is one spacing wide and 48 pixels tall, however
/// small it is drawn. The extra height grows towards the inside of the
/// carousel, as [alignment] places the dots, so none of it falls off the
/// carousel's edge, where no tap reaches it.
class IndicatorView extends StatelessWidget {
  /// Creates the view for [indicator] over [view], placed by [alignment].
  const IndicatorView({
    super.key,
    required this.indicator,
    required this.view,
    required this.alignment,
  });

  /// The indicator's configuration.
  final CarouselIndicator indicator;

  /// The carousel it follows.
  final CarouselView view;

  /// Where the dots sit in the carousel.
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    final painter = indicator.painter;
    final style = painter.style;
    final direction = Directionality.maybeOf(context) ?? TextDirection.ltr;
    final horizontal = view.axis == Axis.horizontal;
    final paintSize = painter.size(view.itemCount, view.axis);
    final halo = style.halo;
    final inset =
        indicator.margin.resolve(direction) +
        (halo == null ? EdgeInsets.zero : style.haloPadding.resolve(direction));
    // The margin counts towards the target first; only what is still missing
    // grows, towards the inside: dots at the bottom (or the end) grow up.
    final (marginBefore, marginAfter) = horizontal
        ? (inset.top, inset.bottom)
        : (inset.left, inset.right);
    final grow = math.max(
      0.0,
      _minTapTarget -
          (marginBefore +
              marginAfter +
              (horizontal ? paintSize.height : paintSize.width)),
    );
    final at = alignment.resolve(direction);
    final growBefore = grow * (1 + (horizontal ? at.y : at.x)) / 2;
    final band = indicator.tapToNavigate
        ? (
            before: marginBefore + growBefore,
            after: marginAfter + grow - growBefore,
          )
        : (before: 0.0, after: 0.0);
    // Rebuilding on the current item refreshes the dots' semantics; painting
    // follows the scroll by itself.
    Widget dots = ValueListenableBuilder<int>(
      valueListenable: view.current,
      builder: (context, _, _) => CustomPaint(
        size: paintSize,
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
    if (halo != null) {
      dots = DecoratedBox(
        decoration: halo,
        child: Padding(padding: style.haloPadding, child: dots),
      );
    }
    dots = Padding(padding: indicator.margin, child: dots);
    if (!indicator.tapToNavigate) return dots;
    return _TapBand(
      inset: inset,
      axis: view.axis,
      along: math.max(0.0, style.spacing / 2 - style.radius),
      before: band.before,
      after: band.after,
      child: dots,
    );
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

  /// How far each dot's target reaches past the painted dots, across the row.
  final ({double before, double after}) band;

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
    final along = math.max(style.spacing, 2 * style.radius) / 2;
    final horizontal = g.axis == Axis.horizontal;
    return [
      for (var i = 0; i < g.itemCount; i++)
        CustomPainterSemantics(
          rect: switch (indicator.dotCenter(i, g)) {
            final c when horizontal => Rect.fromLTRB(
              c.dx - along,
              -band.before,
              c.dx + along,
              size.height + band.after,
            ),
            final c => Rect.fromLTRB(
              -band.before,
              c.dy - along,
              size.width + band.after,
              c.dy + along,
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

/// Widens the dots' tap target past what they paint, without moving them or
/// changing the layout. A tap in the band hit-tests the dots at the nearest
/// point inside them, and keeps its real position, so the nearest dot wins.
class _TapBand extends SingleChildRenderObjectWidget {
  const _TapBand({
    required this.inset,
    required this.axis,
    required this.along,
    required this.before,
    required this.after,
    required super.child,
  });

  /// From this box's edges to the painted dots.
  final EdgeInsets inset;
  final Axis axis;

  /// How far the band reaches past the first and last dots, along the row.
  final double along;

  /// How far it reaches past the dots across the row, before and after them.
  final double before;
  final double after;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderTapBand(inset, axis, along, before, after);

  @override
  void updateRenderObject(BuildContext context, _RenderTapBand renderObject) =>
      renderObject
        ..inset = inset
        ..axis = axis
        ..along = along
        ..before = before
        ..after = after;
}

class _RenderTapBand extends RenderProxyBox {
  _RenderTapBand(this.inset, this.axis, this.along, this.before, this.after);

  EdgeInsets inset;
  Axis axis;
  double along;
  double before;
  double after;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    final dots = inset.deflateRect(Offset.zero & size);
    final band = axis == Axis.horizontal
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
    if (dots.isEmpty || !band.contains(position)) {
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
