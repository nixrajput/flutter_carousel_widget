import 'package:flutter/material.dart';

import 'slide_indicator.dart';

class CircularStaticIndicator extends SlideIndicator {
  final double itemSpacing;
  final double indicatorRadius;
  final EdgeInsets? padding;
  final AlignmentGeometry alignment;
  final Color currentIndicatorColor;
  final Color indicatorBackgroundColor;
  final bool enableAnimation;
  final double indicatorBorderWidth;
  final Color? indicatorBorderColor;

  CircularStaticIndicator({
    this.itemSpacing = 20,
    this.indicatorRadius = 6,
    this.padding,
    this.alignment = Alignment.bottomCenter,
    this.currentIndicatorColor = const Color(0xFFFFFFFF),
    this.indicatorBackgroundColor = const Color(0x66FFFFFF),
    this.enableAnimation = false,
    this.indicatorBorderWidth = 1,
    this.indicatorBorderColor,
  });

  @override
  Widget build(int currentPage, double pageDelta, int itemCount) {
    return Container(
      alignment: alignment,
      padding: padding,
      child: SizedBox(
        width: itemCount * itemSpacing,
        height: indicatorRadius * 2,
        child: CustomPaint(
          painter: CircularStaticIndicatorPainter(
            currentIndicatorColor: currentIndicatorColor,
            indicatorBackgroundColor: indicatorBackgroundColor,
            currentPage: currentPage,
            pageDelta: pageDelta,
            itemCount: itemCount,
            radius: indicatorRadius,
            enableAnimation: enableAnimation,
            indicatorBorderColor: indicatorBorderColor,
            borderWidth: indicatorBorderWidth,
          ),
        ),
      ),
    );
  }
}

class CircularStaticIndicatorPainter extends CustomPainter {
  final int itemCount;
  final double radius;
  final Paint indicatorPaint = Paint();
  final Paint currentIndicatorPaint = Paint();
  final int currentPage;
  final double pageDelta;
  final bool enableAnimation;

  final Paint borderIndicatorPaint = Paint();
  final Color? indicatorBorderColor;

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
