import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter_carousel_widget/src/indicators/slide_indicator.dart';
import 'package:flutter_carousel_widget/src/indicators/slide_indicator_options.dart';

class SequentialFillIndicator extends SlideIndicator {
  SequentialFillIndicator({
    this.slideIndicatorOptions = const SlideIndicatorOptions(),
  });

  final SlideIndicatorOptions slideIndicatorOptions;

  @override
  Widget build(int currentPage, double pageDelta, int itemCount) {
    return Container(
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
            painter: SequentialFillIndicatorPainter(
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

class SequentialFillIndicatorPainter extends CustomPainter {
  SequentialFillIndicatorPainter({
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
    currentIndicatorPaint.strokeCap = StrokeCap.round;
    currentIndicatorPaint.strokeWidth = radius * 2;

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
    var currentPage = this.currentPage;
    if (this.currentPage + pageDelta > itemCount - 1) {
      currentPage = 0;
    }
    final dx = itemCount < 2
        ? size.width
        : (size.width - 2 * radius) / (itemCount - 1);
    final y = size.height / 2;
    var x = radius;
    for (var i = 0; i < itemCount; i++) {
      canvas.drawCircle(Offset(x, y), radius, indicatorPaint);
      x += dx;
    }
    canvas.save();
    x = radius;
    final path = Path();
    for (var i = 0; i < itemCount; i++) {
      path.addOval(Rect.fromCircle(center: Offset(x, y), radius: radius));
      x += dx;
    }
    canvas.clipPath(path);
    x = radius;
    if (this.currentPage + pageDelta > itemCount - 1) {
      canvas.drawLine(
          Offset(-radius, y),
          Offset(dx * currentPage + radius * 2 * pageDelta - radius, y),
          currentIndicatorPaint);
    } else {
      canvas.drawLine(
          Offset(-radius, y),
          Offset(dx * currentPage + dx * pageDelta + radius, y),
          currentIndicatorPaint);
    }
    canvas.restore();
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
