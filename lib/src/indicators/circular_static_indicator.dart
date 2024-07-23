import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';

class CircularStaticIndicator extends SlideIndicator {
  CircularStaticIndicator({
    this.slideIndicatorOptions = const SlideIndicatorOptions(),
  });

  final SlideIndicatorOptions slideIndicatorOptions;

  @override
  Widget build(int currentPage, double pageDelta, int itemCount) {
    return Container(
      alignment: slideIndicatorOptions.alignment,
      padding: slideIndicatorOptions.padding,
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
            painter: CircularStaticIndicatorPainter(
              currentIndicatorColor:
                  slideIndicatorOptions.currentIndicatorColor,
              indicatorBackgroundColor:
                  slideIndicatorOptions.indicatorBackgroundColor,
              currentPage: currentPage,
              pageDelta: pageDelta,
              itemCount: itemCount,
              radius: slideIndicatorOptions.indicatorRadius,
              enableAnimation: slideIndicatorOptions.enableAnimation,
              indicatorBorderColor: slideIndicatorOptions.indicatorBorderColor,
              borderWidth: slideIndicatorOptions.indicatorBorderWidth,
            ),
          ),
        ),
      ),
    );
  }
}

class CircularStaticIndicatorPainter extends CustomPainter {
  CircularStaticIndicatorPainter({
    required this.currentPage,
    required this.pageDelta,
    required this.itemCount,
    this.radius = 12,
    required Color currentIndicatorColor,
    required Color indicatorBackgroundColor,
    this.enableAnimation = false,
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
  final int currentPage;
  final bool enableAnimation;
  final Color? indicatorBorderColor;
  final Paint indicatorPaint = Paint();
  final int itemCount;
  final double pageDelta;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final dx = itemCount < 2
        ? size.width
        : (size.width - 2 * radius) / (itemCount - 1);
    final y = size.height / 2;
    var x = radius;
    for (var i = 0; i < itemCount; i++) {
      canvas.drawCircle(Offset(x, y), radius, indicatorPaint);
      if (i == currentPage) {
        canvas.drawCircle(
            Offset(x, y),
            enableAnimation ? radius - radius * pageDelta : radius,
            currentIndicatorPaint);
      }
      if (enableAnimation &&
          (i == currentPage + 1 || currentPage == itemCount - 1 && i == 0)) {
        canvas.drawCircle(
            Offset(x, y),
            enableAnimation ? radius * pageDelta : radius,
            currentIndicatorPaint);
      }
      x += dx;
    }
    if (indicatorBorderColor != null) {
      x = radius;
      for (var i = 0; i < itemCount; i++) {
        canvas.drawCircle(Offset(x, y), radius, borderIndicatorPaint);
        x += dx;
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
