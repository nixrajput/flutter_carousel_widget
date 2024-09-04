import 'package:flutter/material.dart' hide CarouselController;

/// A class that holds the options for the slide indicators.
class SlideIndicatorOptions {
  const SlideIndicatorOptions({
    this.alignment = Alignment.bottomCenter,
    this.currentIndicatorColor = const Color(0xFFFFFFFF),
    this.indicatorBackgroundColor = const Color(0x66FFFFFF),
    this.indicatorBorderColor,
    this.indicatorBorderWidth = 1,
    this.indicatorRadius = 6,
    this.itemSpacing = 20,
    this.padding,
    this.haloDecoration = const BoxDecoration(
      color: Color(0x33000000),
      borderRadius: BorderRadius.all(Radius.circular(15.0)),
    ),
    this.haloPadding = const EdgeInsets.all(8.0),
    this.enableHalo = false,
    this.enableAnimation = false,
  })  : assert(indicatorRadius > 0),
        assert(itemSpacing >= 0),
        assert(indicatorBorderWidth >= 0);

  /// The alignment of the indicator.
  final AlignmentGeometry alignment;

  /// The color of the currently active item indicator.
  final Color currentIndicatorColor;

  /// The background color of all inactive item indicators.
  final Color indicatorBackgroundColor;

  /// The border color of all item indicators.
  final Color? indicatorBorderColor;

  /// The border width of all item indicators.
  final double indicatorBorderWidth;

  /// The radius of all item indicators.
  final double indicatorRadius;

  /// The spacing between each item indicator.
  final double itemSpacing;

  /// The padding of the indicator.
  final EdgeInsets? padding;

  /// The decoration of the indicator halo.
  final BoxDecoration haloDecoration;

  /// The padding of the indicator halo.
  final EdgeInsets haloPadding;

  /// Whether to enable the indicator halo.
  final bool enableHalo;

  /// Whether to enable the animation. Only used in [CircularStaticIndicator] and [SequentialFillIndicator].
  final bool enableAnimation;

  /// Returns a copy of this [SlideIndicatorOptions] but with the given fields replaced with the new values.
  SlideIndicatorOptions copyWith({
    AlignmentGeometry? alignment,
    Color? currentIndicatorColor,
    Color? indicatorBackgroundColor,
    Color? indicatorBorderColor,
    double? indicatorBorderWidth,
    double? indicatorRadius,
    double? itemSpacing,
    EdgeInsets? padding,
    BoxDecoration? haloDecoration,
    EdgeInsets? haloPadding,
    bool? enableHalo,
  }) {
    return SlideIndicatorOptions(
      alignment: alignment ?? this.alignment,
      currentIndicatorColor:
          currentIndicatorColor ?? this.currentIndicatorColor,
      indicatorBackgroundColor:
          indicatorBackgroundColor ?? this.indicatorBackgroundColor,
      indicatorBorderColor: indicatorBorderColor ?? this.indicatorBorderColor,
      indicatorBorderWidth: indicatorBorderWidth ?? this.indicatorBorderWidth,
      indicatorRadius: indicatorRadius ?? this.indicatorRadius,
      itemSpacing: itemSpacing ?? this.itemSpacing,
      padding: padding ?? this.padding,
      haloDecoration: haloDecoration ?? this.haloDecoration,
      haloPadding: haloPadding ?? this.haloPadding,
      enableHalo: enableHalo ?? this.enableHalo,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is SlideIndicatorOptions &&
        other.alignment == alignment &&
        other.currentIndicatorColor == currentIndicatorColor &&
        other.indicatorBackgroundColor == indicatorBackgroundColor &&
        other.indicatorBorderColor == indicatorBorderColor &&
        other.indicatorBorderWidth == indicatorBorderWidth &&
        other.indicatorRadius == indicatorRadius &&
        other.itemSpacing == itemSpacing &&
        other.padding == padding &&
        other.haloDecoration == haloDecoration &&
        other.haloPadding == haloPadding &&
        other.enableHalo == enableHalo;
  }

  @override
  int get hashCode {
    return Object.hash(
      alignment,
      currentIndicatorColor,
      indicatorBackgroundColor,
      indicatorBorderColor,
      indicatorBorderWidth,
      indicatorRadius,
      itemSpacing,
      padding,
      haloDecoration,
      haloPadding,
      enableHalo,
    );
  }
}
