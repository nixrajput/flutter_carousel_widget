import 'package:flutter/widgets.dart';

import '../carousel_options/expandable_carousel_options.dart';
import '../enums/carousel_page_changed_reason.dart';

/// State class for the [ExpandableCarousel] widget, holding its configuration and state management.
class ExpandableCarouselState {
  ExpandableCarouselState(
    this.options,
    this.onResetTimer,
    this.onResumeTimer,
    this.changeMode,
  );

  /// The initial index of the [PageView] on [FlutterCarouselWidget] init.
  int initialPage = 0;

  /// The widgets count that should be shown at carousel
  int? itemCount;

  /// Will be called when using pageController to go to next page or
  /// previous page. It will clear the autoPlay timer.
  /// Internal use only
  Function onResetTimer;

  /// Will be called when using pageController to go to next page or
  /// previous page. It will restart the autoPlay timer.
  /// Internal use only
  Function onResumeTimer;

  /// The [ExpandableCarouselOptions] to create this state
  ExpandableCarouselOptions options;

  /// [pageController] is created using the properties passed to the constructor
  /// and can be used to control the [PageView] it is passed to.
  PageController? pageController;

  /// The actual index of the [PageView].
  /// This value can be ignored unless you know the carousel will be scrolled
  /// backwards more then 10000 pages.
  /// Defaults to 10000 to simulate infinite backwards scrolling.
  int realPage = 10000;

  /// Callback to set the reason why the carousel page changed.
  Function(CarouselPageChangedReason) changeMode;
}
