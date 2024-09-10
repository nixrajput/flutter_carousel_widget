import 'package:flutter/material.dart';

import 'slide_indicator.dart';
import 'slide_indicator_options.dart';

/// The [CircularWaveSlideIndicator] class extends [SlideIndicator] to build slide indicators.
class CircularWaveSlideIndicator extends SlideIndicator {
  CircularWaveSlideIndicator({
    this.slideIndicatorOptions = const SlideIndicatorOptions(),
    this.key,
  });

  final SlideIndicatorOptions slideIndicatorOptions;
  final Key? key;

  @override
  Widget build(int currentPage, double pageDelta, int itemCount) {
    return Container(
      key: key,
      alignment: slideIndicatorOptions.alignment,
      padding: slideIndicatorOptions.padding,
      color: Colors.transparent,
      child: Container(
        decoration: slideIndicatorOptions.enableHalo
            ? slideIndicatorOptions.haloDecoration
            : null,
        padding: slideIndicatorOptions.enableHalo
            ? slideIndicatorOptions.haloPadding
            : null,
        child: SizedBox(
          width: itemCount * slideIndicatorOptions.itemSpacing,
          height: slideIndicatorOptions.indicatorRadius * 2,
          child: CustomPaint(
            painter: CircularWaveIndicatorPainter(
              currentIndicatorColor:
                  slideIndicatorOptions.currentIndicatorColor,
              indicatorBackgroundColor:
                  slideIndicatorOptions.indicatorBackgroundColor,
              currentPage: currentPage,
              pageDelta: pageDelta,
              itemCount: itemCount,
              radius: slideIndicatorOptions.indicatorRadius,
              indicatorBorderColor: slideIndicatorOptions.indicatorBorderColor,
              borderWidth: slideIndicatorOptions.indicatorBorderWidth,
            ),
          ),
        ),
      ),
    );
  }
}

class CircularWaveIndicatorPainter extends CustomPainter {
  CircularWaveIndicatorPainter({
    this.itemCount,
    this.currentPage,
    this.pageDelta,
    this.radius,
    required Color currentIndicatorColor,
    required Color indicatorBackgroundColor,
    this.indicatorBorderColor,
    double borderWidth = 2,
  }) {
    indicatorPaint.color = indicatorBackgroundColor;
    indicatorPaint.style = PaintingStyle.fill;
    indicatorPaint.isAntiAlias = true;
    currentIndicatorPaint.color = currentIndicatorColor;
    currentIndicatorPaint.style = PaintingStyle.fill;
    currentIndicatorPaint.isAntiAlias = true;

    if (indicatorBorderColor != null) {
      borderIndicatorPaint.color = indicatorBorderColor!;
      borderIndicatorPaint.style = PaintingStyle.stroke;
      borderIndicatorPaint.strokeWidth = borderWidth;
      borderIndicatorPaint.isAntiAlias = true;
    }
  }

  final Paint borderIndicatorPaint = Paint();
  final Paint currentIndicatorPaint = Paint();
  final int? currentPage;
  final Color? indicatorBorderColor;
  final Paint indicatorPaint = Paint();
  final int? itemCount;
  final double? pageDelta;
  final double? radius;

  @override
  void paint(Canvas canvas, Size size) {
    final dx = itemCount! < 2
        ? size.width
        : (size.width - 2 * radius!) / (itemCount! - 1);
    final y = size.height / 2;
    var x = radius;
    for (var i = 0; i < itemCount!; i++) {
      canvas.drawCircle(Offset(x!, y), radius!, indicatorPaint);
      x += dx;
    }
    var midX = radius! + dx * currentPage!;
    var midY = size.height / 2;
    var r = radius! * ((1.4 * pageDelta! - 0.7).abs() + 0.3);
    if (currentPage == itemCount! - 1) {
      canvas.save();
      final path = Path();
      path.addOval(
          Rect.fromLTRB(0, midY - radius!, 2 * radius!, midY + radius!));
      path.addOval(Rect.fromLTRB(size.width - 2 * radius!, midY - radius!,
          size.width, midY + radius!));
      canvas.clipPath(path);
      canvas.drawCircle(Offset(2 * radius! * pageDelta! - radius!, midY), r,
          currentIndicatorPaint);
      midX += 2 * radius! * pageDelta!;
    } else {
      midX += dx * pageDelta!;
    }
    canvas.drawCircle(Offset(midX, midY), r, currentIndicatorPaint);
    if (currentPage == itemCount! - 1) {
      canvas.restore();
    }
    if (indicatorBorderColor != null) {
      x = radius;
      for (var i = 0; i < itemCount!; i++) {
        canvas.drawCircle(Offset(x!, y), radius!, borderIndicatorPaint);
        x += dx;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
