import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../auto_play/carousel_auto_play.dart';
import '../controller/flutter_carousel_controller.dart';
import '../effects/carousel_effect.dart';
import '../indicators/carousel_indicator.dart';
import '../types.dart';

/// Every parameter the two carousels share, handed to the engine in one
/// piece. The public widgets document each field.
@immutable
class CarouselConfig {
  /// Creates a config; only the public widgets call this.
  const CarouselConfig({
    required this.controller,
    required this.initialPage,
    required this.viewportFraction,
    required this.infinite,
    required this.reverse,
    required this.scrollDirection,
    required this.autoPlay,
    required this.effect,
    required this.indicator,
    required this.onPageChanged,
    required this.onScrolled,
    required this.itemAlignment,
    required this.keepAlive,
    required this.semanticLabel,
    required this.semanticSlideLabel,
    required this.keyboardNavigation,
    required this.focusNode,
    required this.autofocus,
    required this.physics,
    required this.pageSnapping,
    required this.padEnds,
    required this.edgeAlignment,
    required this.clipBehavior,
    required this.scrollBehavior,
    required this.dragStartBehavior,
    required this.allowImplicitScrolling,
    required this.restorationId,
    required this.keepPage,
    required this.pageViewKey,
  });

  /// See `FlutterCarousel.controller`.
  final FlutterCarouselController? controller;

  /// See `FlutterCarousel.initialPage`.
  final int initialPage;

  /// See `FlutterCarousel.viewportFraction`.
  final double viewportFraction;

  /// See `FlutterCarousel.infinite`.
  final bool infinite;

  /// See `FlutterCarousel.reverse`.
  final bool reverse;

  /// See `FlutterCarousel.scrollDirection`.
  final Axis scrollDirection;

  /// See `FlutterCarousel.autoPlay`.
  final CarouselAutoPlay? autoPlay;

  /// See `FlutterCarousel.effect`.
  final CarouselEffect effect;

  /// See `FlutterCarousel.indicator`.
  final CarouselIndicator? indicator;

  /// See `FlutterCarousel.onPageChanged`.
  final CarouselPageChanged? onPageChanged;

  /// See `FlutterCarousel.onScrolled`.
  final ValueChanged<double>? onScrolled;

  /// See `FlutterCarousel.itemAlignment`.
  final AlignmentGeometry? itemAlignment;

  /// See `FlutterCarousel.keepAlive`.
  final bool keepAlive;

  /// See `FlutterCarousel.semanticLabel`.
  final String? semanticLabel;

  /// See `FlutterCarousel.semanticSlideLabel`.
  final String Function(int index, int count)? semanticSlideLabel;

  /// See `FlutterCarousel.keyboardNavigation`.
  final bool keyboardNavigation;

  /// See `FlutterCarousel.focusNode`.
  final FocusNode? focusNode;

  /// See `FlutterCarousel.autofocus`.
  final bool autofocus;

  /// See `FlutterCarousel.physics`.
  final ScrollPhysics? physics;

  /// See `FlutterCarousel.pageSnapping`.
  final bool pageSnapping;

  /// See `FlutterCarousel.padEnds`.
  final bool padEnds;

  /// See `FlutterCarousel.edgeAlignment`.
  final CarouselEdgeAlignment edgeAlignment;

  /// See `FlutterCarousel.clipBehavior`.
  final Clip clipBehavior;

  /// See `FlutterCarousel.scrollBehavior`.
  final ScrollBehavior? scrollBehavior;

  /// See `FlutterCarousel.dragStartBehavior`.
  final DragStartBehavior dragStartBehavior;

  /// See `FlutterCarousel.allowImplicitScrolling`.
  final bool allowImplicitScrolling;

  /// See `FlutterCarousel.restorationId`.
  final String? restorationId;

  /// See `FlutterCarousel.keepPage`.
  final bool keepPage;

  /// See `FlutterCarousel.pageViewKey`.
  final PageStorageKey<Object?>? pageViewKey;
}
