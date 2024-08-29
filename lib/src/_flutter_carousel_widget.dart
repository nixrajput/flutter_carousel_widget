library flutter_carousel_widget;

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter_carousel_widget/src/enums/carousel_page_changed_reason.dart';
import 'package:flutter_carousel_widget/src/enums/center_page_enlarge_strategy.dart';
import 'package:flutter_carousel_widget/src/helpers/flutter_carousel_controller.dart';
import 'package:flutter_carousel_widget/src/helpers/flutter_carousel_options.dart';
import 'package:flutter_carousel_widget/src/helpers/flutter_carousel_state.dart';
import 'package:flutter_carousel_widget/src/typedefs/widget_builder.dart';
import 'package:flutter_carousel_widget/src/utils/flutter_carousel_utils.dart';

/// Main carousel widget
/// There are two constructors - one for direct list of items and another for builder pattern (itemBuilder).
/// The options parameter controls various carousel behaviors such as auto-play, scroll direction, etc.
class FlutterCarousel extends StatefulWidget {
  /// The default constructor
  const FlutterCarousel({
    required this.items, // Items to display in the carousel
    required this.options, // Options for configuring the carousel
    Key? key,
  })  : itemBuilder = null, // itemBuilder is null when using direct items list
        itemCount =
            items != null ? items.length : 0, // Count is based on items length
        assert(items != null), // Ensure items list is not null
        super(key: key);

  /// Constructor for on-demand item builder pattern
  const FlutterCarousel.builder({
    required this.itemCount, // Number of items to display
    required this.itemBuilder, // Builder function to create items dynamically
    required this.options, // Options for configuring the carousel
    Key? key,
  })  : items = null, // Items list is null when using item builder
        assert(itemCount != null), // Ensure itemCount is provided
        assert(itemBuilder != null), // Ensure itemBuilder function is provided
        super(key: key);

  /// Widget item builder that builds items on-demand
  final ExtendedWidgetBuilder? itemBuilder;

  /// The count of items to be shown in the carousel
  final int? itemCount;

  /// List of widgets to be shown in the carousel for the default constructor
  final List<Widget>? items;

  /// Configuration options for the carousel
  final CarouselOptions options;

  @override
  FlutterCarouselState createState() => FlutterCarouselState();
}

/// State class for the carousel widget
/// This class handles the internal state of the carousel, including page transitions, autoplay, gestures, and more.
class FlutterCarouselState extends State<FlutterCarousel>
    with TickerProviderStateMixin {
  /// Enum to represent why the page is changing (e.g., user input, auto-play, etc.)
  CarouselPageChangedReason changeReasonMode =
      CarouselPageChangedReason.controller;

  /// Carousel state to manage internal state like page controller, item count, etc.
  CarouselState? _carouselState;

  /// Page controller to manage page views and transitions
  PageController? _pageController;

  /// Current page index (used for indicator sync)
  int _currentPage = 0;

  /// Delta for tracking page transition progress (used for smooth animations)
  double _pageDelta = 0.0;

  /// Timer to manage auto-play functionality
  Timer? _timer;

  /// Retrieve the carousel controller, or create a new one if not provided
  CarouselControllerImpl get carouselController =>
      widget.options.controller != null
          ? widget.options.controller as CarouselControllerImpl
          : CarouselController() as CarouselControllerImpl;

  /// Retrieve options for the carousel
  CarouselOptions get options => widget.options;

  /// Update the current page index and delta for smooth animations
  void _changeIndexPageDelta() {
    if (_carouselState!.pageController!.hasClients) {
      // Get current page index
      var pageIndex =
          _carouselState!.pageController!.page ?? _currentPage.toDouble();

      // Calculate the actual index in case of infinite scrolling
      var actualIndex = getRealIndex(
        pageIndex.floor() + _carouselState!.initialPage, // Floor the page index
        _carouselState!.realPage, // Initial real page
        widget.itemCount!, // Total number of items
      );

      // Update state with the new index and delta (for smooth animations)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _currentPage = actualIndex;
            _pageDelta = pageIndex - pageIndex.floor(); // Calculate delta
          });
        }
      });
    }
  }

  /// Initialize state when the widget is first created
  @override
  void initState() {
    // Initialize carousel state with options and callbacks for timer handling
    _carouselState = CarouselState(
      options,
      _clearTimer,
      _resumeTimer,
      changeMode,
    );

    _carouselState!.itemCount =
        widget.itemCount ?? widget.items!.length; // Set item count in state
    carouselController.state = _carouselState; // Set carousel controller state

    // Set initial page based on infinite scroll configuration
    _carouselState!.initialPage = widget.options.initialPage;
    _carouselState!.realPage = options.enableInfiniteScroll
        ? _carouselState!.initialPage +
            (_carouselState!.itemCount ?? 0) *
                10000 // Offset for infinite scroll
        : _carouselState!.initialPage;

    _currentPage = _carouselState!.initialPage; // Set current page

    // Initialize page controller with options
    _pageController = PageController(
      viewportFraction: options.viewportFraction, // Set viewport fraction
      keepPage: options.keepPage, // Keep page state
      initialPage: _carouselState!.realPage, // Set initial page
    );

    _carouselState!.pageController = _pageController; // Set page controller

    // Add listener to track index and page delta for smooth animations
    _pageController?.addListener(_changeIndexPageDelta);

    // Initialize auto-play
    _handleAutoPlay();

    super.initState();
  }

  /// Handle updates to the widget when it rebuilds
  @override
  void didUpdateWidget(covariant FlutterCarousel oldWidget) {
    _carouselState!.itemCount = widget.itemCount; // Update item count

    // Reinitialize the page controller with updated options
    _pageController = PageController(
      viewportFraction: options.viewportFraction, // Set viewport fraction
      keepPage: options.keepPage, // Keep page state after updates
      initialPage: _carouselState!.realPage, // Set initial page
    );

    _carouselState!.pageController = _pageController; // Update page controller

    // Add listener to track page delta for smooth animations
    _pageController!.addListener(_changeIndexPageDelta);

    // Handle auto-play when widget updates
    _handleAutoPlay();

    super.didUpdateWidget(oldWidget);
  }

  /// Dispose resources when widget is removed from the tree
  @override
  void dispose() {
    _pageController?.removeListener(_changeIndexPageDelta); // Remove listener
    _pageController?.dispose(); // Dispose page controller
    _clearTimer(); // Clear the timer for auto-play
    super.dispose();
  }

  /// Create a timer for auto-play functionality
  Timer? _getTimer() {
    if (!widget.options.autoPlay) {
      return null; // Return null if auto-play is disabled
    }

    // Periodic timer for auto-play
    return Timer.periodic(widget.options.autoPlayInterval, (_) {
      final route = ModalRoute.of(context);
      if (route?.isCurrent == false) {
        return; // Pause auto-play if the route is not active
      }

      // Temporarily store the previous change reason
      var previousReason = changeReasonMode;
      // Set change reason to timed
      changeMode(CarouselPageChangedReason.timed);

      // Calculate the next page index for auto-play
      var nextPage = _carouselState!.pageController!.page!.round() + 1;
      var itemCount = widget.itemCount ?? widget.items!.length;

      // Reset to the first page if at the end of the carousel and infinite scroll is disabled
      if (nextPage >= itemCount &&
          widget.options.enableInfiniteScroll == false) {
        if (widget.options.pauseAutoPlayInFiniteScroll) {
          _clearTimer(); // Pause auto-play if configured
          return;
        }
        nextPage = 0; // Reset to the first page
      }

      // Animate to the next page and restore the previous change reason
      _carouselState!.pageController!
          .animateToPage(
            nextPage,
            duration:
                widget.options.autoPlayAnimationDuration, // Animation duration
            curve: widget.options.autoPlayCurve, // Animation curve
          )
          .then((_) => changeMode(previousReason)); // Restore previous reason
    });
  }

  /// Change the page change reason mode
  void changeMode(CarouselPageChangedReason _mode) {
    changeReasonMode = _mode; // Update the change reason mode
  }

  /// Clear the timer to stop auto-play
  void _clearTimer() {
    _timer?.cancel(); // Cancel the existing timer
    _timer = null; // Reset the timer to null
  }

  /// Resume auto-play with a new timer
  void _resumeTimer() {
    _clearTimer(); // Clear any existing timer
    _timer = _getTimer(); // Create a new timer for auto-play
  }

  /// Handle auto-play by clearing or resuming the timer based on configuration
  void _handleAutoPlay() {
    var autoPlayEnabled = widget.options.autoPlay;

    if (!autoPlayEnabled && _timer != null) return;

    if (autoPlayEnabled) {
      // Start a new timer for auto-play if enabled
      _resumeTimer();
    }
  }

  /// Wrap gestures for touch events
  Widget _getGestureWrapper({required Widget child}) {
    Widget wrapper;
    if (widget.options.height != null) {
      wrapper = SizedBox(
        height: widget.options.height,
        child: child,
      );
    } else {
      wrapper = AspectRatio(
        aspectRatio: widget.options.aspectRatio ?? 1 / 1,
        child: child,
      );
    }

    return RawGestureDetector(
      gestures: {
        _MultipleGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<_MultipleGestureRecognizer>(
          _MultipleGestureRecognizer.new,
          (_MultipleGestureRecognizer instance) {
            // Set up gesture callbacks for pan gestures (dragging)
            instance
              ..onStart = (_) {
                _clearTimer(); // Pause auto-play when user interacts
                changeMode(CarouselPageChangedReason
                    .manual); // Change the page change reason mode
              }
              ..onDown = (_) {
                if (widget.options.pauseAutoPlayOnTouch) {
                  _clearTimer(); // Pause auto-play when user interacts
                }

                changeMode(CarouselPageChangedReason
                    .manual); // Change the page change reason mode
              }
              ..onCancel = () {
                if (widget.options.pauseAutoPlayOnTouch) {
                  // Resume auto-play when interaction ends
                  _resumeTimer();
                }
              }
              ..onEnd = (_) {
                if (widget.options.pauseAutoPlayOnTouch) {
                  // Resume auto-play when interaction ends
                  _resumeTimer();
                }
              };
          },
        ),
      },
      // Wrap the child widget with the gesture detector
      child: NotificationListener<ScrollEndNotification>(
        onNotification: (dynamic notification) {
          if (widget.options.onScrolled != null &&
              notification is ScrollUpdateNotification) {
            widget.options.onScrolled!(_carouselState!.pageController!.page);
          }
          return false;
        },
        child: wrapper, // The child widget (carousel)
      ),
    );
  }

  /// Wrap the carousel item with the center align strategy (optional)
  Widget _getCenterWrapper(Widget child) {
    if (widget.options.disableCenter) {
      return child;
    }
    return Center(child: child);
  }

  /// Wrap the carousel item with the enlarge strategy (optional)
  Widget _getEnlargeWrapper(Widget? child,
      {double? width, double? height, double? scale}) {
    // If [enlargeStrategy] is [CenterPageEnlargeStrategy.height]
    if (widget.options.enlargeStrategy == CenterPageEnlargeStrategy.height) {
      return SizedBox(
        width: width,
        height: height,
        child: child,
      );
    }

    return Transform.scale(
      scale: scale,
      child: SizedBox(
        width: width,
        height: height,
        child: child,
      ),
    );
  }

  /// Build the carousel widget using a PageView
  Widget _buildCarouselWidget(BuildContext context) {
    return PageView.builder(
      key: widget.options.pageViewKey,
      scrollBehavior: widget.options.scrollBehavior ??
          ScrollConfiguration.of(context).copyWith(
            scrollbars: false,
            overscroll: false,
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
            },
          ),
      clipBehavior: widget.options.clipBehavior,
      physics: widget.options.physics,
      scrollDirection: widget.options.scrollDirection,
      pageSnapping: widget.options.pageSnapping,
      controller: _carouselState!.pageController,
      reverse: widget.options.reverse,
      dragStartBehavior: widget.options.dragStartBehavior,
      allowImplicitScrolling: widget.options.allowImplicitScrolling,
      restorationId: widget.options.restorationId,
      padEnds: widget.options.padEnds,
      itemCount: widget.options.enableInfiniteScroll
          ? null // Infinite scroll mode does not need item count
          : widget.itemCount ?? widget.items!.length, // Use provided item count
      onPageChanged: (int index) {
        // Calculate the current page index in infinite scroll mode
        var currentPage = getRealIndex(
          index + _carouselState!.initialPage,
          _carouselState!.realPage,
          widget.itemCount!,
        );

        // Invoke the onPageChanged callback if provided
        if (widget.options.onPageChanged != null) {
          widget.options.onPageChanged!(currentPage, changeReasonMode);
        }
      },
      itemBuilder: (BuildContext context, int idx) {
        // Calculate the real index in infinite scroll mode
        final int actualIndex = getRealIndex(
          idx + _carouselState!.initialPage,
          _carouselState!.realPage,
          widget.itemCount,
        );

        return AnimatedBuilder(
          animation: _carouselState!.pageController!,
          builder: (BuildContext context, Widget? child) {
            var distortionValue = 1.0;

            // if `enlargeCenterPage` is true, we must calculate the carousel
            // item's height to display the visual effect
            if (widget.options.enlargeCenterPage != null &&
                widget.options.enlargeCenterPage == true) {
              // pageController.page can only be accessed after the first
              // build, so in the first build we calculate the item
              // offset manually
              var itemOffset = 0.0;
              var position = _carouselState?.pageController?.position;
              if (position != null &&
                  position.hasPixels &&
                  position.hasContentDimensions) {
                var page = _carouselState?.pageController?.page;
                if (page != null) {
                  itemOffset = page - idx;
                }
              } else {
                var storageContext = _carouselState!
                    .pageController!.position.context.storageContext;
                final previousSavedPosition = PageStorage.of(storageContext)
                    .readState(storageContext) as double?;
                if (previousSavedPosition != null) {
                  itemOffset = previousSavedPosition - idx.toDouble();
                } else {
                  itemOffset =
                      _carouselState!.realPage.toDouble() - idx.toDouble();
                }
              }

              // Calculate [distortionRatio]
              final distortionRatio =
                  1 - (itemOffset.abs() * 0.25).clamp(0.0, 1.0);
              distortionValue = Curves.easeOut.transform(distortionRatio);
            }

            // Calculate [height]
            final height = widget.options.height ??
                MediaQuery.of(context).size.width *
                    (1 / (widget.options.aspectRatio ?? 1 / 1));

            // If [scrollDirection] option is [Axis.horizontal]
            if (widget.options.scrollDirection == Axis.horizontal) {
              return _getCenterWrapper(
                _getEnlargeWrapper(
                  child,
                  height: distortionValue * height,
                  scale: distortionValue,
                ),
              );
            } else {
              return _getCenterWrapper(
                _getEnlargeWrapper(
                  child,
                  width: distortionValue * MediaQuery.of(context).size.width,
                  scale: distortionValue,
                ),
              );
            }
          },
          child: (widget.items != null)
              ? (widget.items!.isNotEmpty
                  ? widget.items![actualIndex]
                  : const SizedBox())
              : widget.itemBuilder!(context, actualIndex, idx),
        );
      },
    );
  }

  /// Build the slide indicator widget
  /// This widget is responsible for displaying the slide indicators (dots, bars, etc.)
  /// to show the current position within the carousel. It uses the [_currentPage] and
  /// [_pageDelta] values to determine the indicator's position and animation state.
  Widget _buildSlideIndicator() {
    return widget.options.slideIndicator!.build(
      _currentPage,
      _pageDelta,
      widget.itemCount!,
    );
  }

  /// Build the main carousel widget structure
  /// This method handles the logic for building the carousel and, if enabled,
  /// the slide indicator. The slide indicator can be positioned as floating
  /// or below the carousel depending on the [floatingIndicator] option.
  Widget _buildWidget(BuildContext context) {
    if (widget.options.showIndicator &&
        widget.options.slideIndicator != null &&
        widget.itemCount! > 1) {
      // If [floatingIndicator] option is [true]
      if (widget.options.floatingIndicator) {
        return _getGestureWrapper(
          child: Stack(
            children: [
              _buildCarouselWidget(context),
              Positioned(
                bottom: widget.options.indicatorMargin,
                left: 0.0,
                right: 0.0,
                child: _buildSlideIndicator(),
              ),
            ],
          ),
        );
      }

      /// If [floatingIndicator] option is [false]
      return _getGestureWrapper(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: _buildCarouselWidget(context),
            ),
            SizedBox(height: widget.options.indicatorMargin),
            Expanded(
              flex: 0,
              child: _buildSlideIndicator(),
            ),
          ],
        ),
      );
    }

    return _getGestureWrapper(child: _buildCarouselWidget(context));
  }

  /// The main build method for the carousel widget
  /// This method returns the widget tree that is displayed in the UI.
  /// It calls the [_buildWidget] method to handle the construction of the carousel
  /// and any optional slide indicators.
  @override
  Widget build(BuildContext context) {
    return _buildWidget(context);
  }
}

/// Custom gesture recognizer class for handling multiple gestures (e.g., pan)
/// This class extends [PanGestureRecognizer] to manage complex gesture detection
/// for interactions such as dragging and swiping in the carousel.
class _MultipleGestureRecognizer extends PanGestureRecognizer {}
