import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import '../engine/carousel_engine.dart';
import '../types.dart';
import 'carousel_indicator.dart';
import 'slide_indicator.dart';

/// Paints a carousel's indicator, repainting from the scroll position without
/// rebuilding widgets. Its dots are labelled for screen readers and, unless
/// [CarouselIndicator.tapToNavigate] is off, move to their item when tapped.
class IndicatorView extends StatelessWidget {
  /// Creates the view for [indicator] over [view].
  const IndicatorView({super.key, required this.indicator, required this.view});

  /// The indicator's configuration.
  final CarouselIndicator indicator;

  /// The carousel it follows.
  final CarouselView view;

  @override
  Widget build(BuildContext context) {
    final painter = indicator.painter;
    // Rebuilding on the current item refreshes the dots' semantics; painting
    // follows the scroll by itself.
    Widget dots = ValueListenableBuilder<int>(
      valueListenable: view.current,
      builder: (context, _, _) => CustomPaint(
        size: painter.size(view.itemCount, view.axis),
        painter: _DotsPainter(painter, view, tappable: indicator.tapToNavigate),
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
    final halo = painter.style.halo;
    if (halo != null) {
      dots = DecoratedBox(
        decoration: halo,
        child: Padding(padding: painter.style.haloPadding, child: dots),
      );
    }
    return dots;
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
  _DotsPainter(this.indicator, this.view, {required this.tappable})
    : _layout = (view.axis, view.infinite, view.geometry.flipped),
      super(repaint: view.scroll);

  final SlideIndicator indicator;
  final CarouselView view;
  final bool tappable;

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
    final extent = math.max(style.spacing, 2 * style.radius);
    return [
      for (var i = 0; i < g.itemCount; i++)
        CustomPainterSemantics(
          rect: Rect.fromCenter(
            center: indicator.dotCenter(i, g),
            width: extent,
            height: extent,
          ),
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
