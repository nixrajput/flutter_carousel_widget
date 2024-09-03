import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/src/enums/carousel_page_changed_reason.dart';
import 'package:flutter_carousel_widget/src/enums/center_page_enlarge_strategy.dart';
import 'package:flutter_carousel_widget/src/helpers/flutter_carousel_controller.dart';
import 'package:flutter_carousel_widget/src/helpers/flutter_expandable_carousel_options.dart';
import 'package:flutter_carousel_widget/src/indicators/circular_slide_indicator.dart';
import 'package:flutter_carousel_widget/src/indicators/slide_indicator.dart';

class CarouselOptions extends ExpandableCarouselOptions{
  CarouselOptions({
    super.height,
    super.aspectRatio,
    super.viewportFraction = 0.9,
    super.initialPage = 0,
    this.enableInfiniteScroll = false,
    super.reverse = false,
    super.autoPlay = false,
    super.autoPlayInterval = const Duration(seconds: 5),
    super.autoPlayAnimationDuration = const Duration(milliseconds: 300),
    super.autoPlayCurve = Curves.easeInCubic,
    this.enlargeCenterPage = false,
    super.controller,
    super.onPageChanged,
    super.onScrolled,
    super.physics = const BouncingScrollPhysics(),
    super.scrollDirection = Axis.horizontal,
    super.pauseAutoPlayOnTouch = true,
    super.pauseAutoPlayOnManualNavigate = true,
    super.pauseAutoPlayInFiniteScroll = false,
    super.pageViewKey,
    super.keepPage = true,
    this.enlargeStrategy = CenterPageEnlargeStrategy.scale,
    this.disableCenter = false,
    super.showIndicator = true,
    super.floatingIndicator = true,
    super.indicatorMargin = 8.0,
    super.slideIndicator = const CircularSlideIndicator(),
    super.clipBehavior = Clip.antiAlias,
    super.scrollBehavior,
    super.pageSnapping = true,
    super.padEnds = true,
    super.dragStartBehavior = DragStartBehavior.start,
    super.allowImplicitScrolling = false,
    super.restorationId,
  }) : assert(showIndicator == true ? slideIndicator != null : true);

  /// Whether or not to disable the `Center` widget for each slide.
  final bool disableCenter;

  ///Determines if carousel should loop infinitely or be limited to item length.
  ///
  ///Defaults to true, i.e. infinite loop.
  final bool enableInfiniteScroll;

  /// Determines if current page should be larger then the side images,
  /// creating a feeling of depth in the carousel.
  ///
  /// Defaults to false.
  final bool? enlargeCenterPage;

  /// Use `enlargeStrategy` to determine which method to enlarge the center page.
  final CenterPageEnlargeStrategy enlargeStrategy;

  /// Copy With Constructor
  CarouselOptions copyWith({
    double? height,
    double? aspectRatio,
    double? viewportFraction,
    int? initialPage,
    bool? enableInfiniteScroll,
    bool? reverse,
    bool? autoPlay,
    Duration? autoPlayInterval,
    Duration? autoPlayAnimationDuration,
    Curve? autoPlayCurve,
    bool? enlargeCenterPage,
    Axis? scrollDirection,
    CarouselController? carouselController,
    Function(int index, CarouselPageChangedReason reason)? onPageChanged,
    ValueChanged<double?>? onScrolled,
    ScrollPhysics? physics,
    bool? pageSnapping,
    bool? pauseAutoPlayOnTouch,
    bool? pauseAutoPlayOnManualNavigate,
    bool? pauseAutoPlayInFiniteScroll,
    PageStorageKey<dynamic>? pageViewKey,
    CenterPageEnlargeStrategy? enlargeStrategy,
    bool? disableCenter,
    SlideIndicator? slideIndicator,
    bool? showIndicator,
    bool? floatingIndicator,
    double? indicatorMargin,
    bool? keepPage,
    bool? padEnds,
    Clip? clipBehavior,
    DragStartBehavior? dragStartBehavior,
    ScrollBehavior? scrollBehavior,
    bool? allowImplicitScrolling,
    String? restorationId,
  }) {
    return CarouselOptions(
      height: height ?? this.height,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      viewportFraction: viewportFraction ?? this.viewportFraction,
      initialPage: initialPage ?? this.initialPage,
      enableInfiniteScroll: enableInfiniteScroll ?? this.enableInfiniteScroll,
      reverse: reverse ?? this.reverse,
      autoPlay: autoPlay ?? this.autoPlay,
      autoPlayInterval: autoPlayInterval ?? this.autoPlayInterval,
      autoPlayAnimationDuration:
          autoPlayAnimationDuration ?? this.autoPlayAnimationDuration,
      autoPlayCurve: autoPlayCurve ?? this.autoPlayCurve,
      enlargeCenterPage: enlargeCenterPage ?? this.enlargeCenterPage,
      onPageChanged: onPageChanged ?? this.onPageChanged,
      onScrolled: onScrolled ?? this.onScrolled,
      physics: physics ?? this.physics,
      pageSnapping: pageSnapping ?? this.pageSnapping,
      scrollDirection: scrollDirection ?? this.scrollDirection,
      pauseAutoPlayOnTouch: pauseAutoPlayOnTouch ?? this.pauseAutoPlayOnTouch,
      pauseAutoPlayOnManualNavigate:
          pauseAutoPlayOnManualNavigate ?? this.pauseAutoPlayOnManualNavigate,
      pauseAutoPlayInFiniteScroll:
          pauseAutoPlayInFiniteScroll ?? this.pauseAutoPlayInFiniteScroll,
      pageViewKey: pageViewKey ?? this.pageViewKey,
      keepPage: keepPage ?? this.keepPage,
      enlargeStrategy: enlargeStrategy ?? this.enlargeStrategy,
      disableCenter: disableCenter ?? this.disableCenter,
      showIndicator: showIndicator ?? this.showIndicator,
      floatingIndicator: floatingIndicator ?? this.floatingIndicator,
      indicatorMargin: indicatorMargin ?? this.indicatorMargin,
      slideIndicator: slideIndicator ?? this.slideIndicator,
      padEnds: padEnds ?? this.padEnds,
      clipBehavior: clipBehavior ?? this.clipBehavior,
      dragStartBehavior: dragStartBehavior ?? this.dragStartBehavior,
      scrollBehavior: scrollBehavior ?? this.scrollBehavior,
      allowImplicitScrolling:
          allowImplicitScrolling ?? this.allowImplicitScrolling,
      restorationId: restorationId ?? this.restorationId,
    );
  }
}
