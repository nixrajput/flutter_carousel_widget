library flutter_carousel_widget;

import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:flutter_carousel_widget/src/components/overflow_page.dart';
import 'package:flutter_carousel_widget/src/enums/carousel_page_changed_reason.dart';
import 'package:flutter_carousel_widget/src/enums/center_page_enlarge_strategy.dart';
import 'package:flutter_carousel_widget/src/helpers/flutter_expandable_carousel_controller.dart';
import 'package:flutter_carousel_widget/src/helpers/flutter_expandable_carousel_options.dart';
import 'package:flutter_carousel_widget/src/helpers/flutter_expandable_carousel_state.dart';
import 'package:flutter_carousel_widget/src/typedefs/widget_builder.dart';
import 'package:flutter_carousel_widget/src/utils/flutter_carousel_utils.dart';

/// Main carousel widget
/// There are two constructors - one for direct list of items and another for builder pattern (itemBuilder).
/// The options parameter controls various carousel behaviors such as auto-play, scroll direction, etc.
class ExpandableCarousel extends StatefulWidget {
  /// The default constructor
  const ExpandableCarousel({
    required this.items,
    required this.options,
    Key? key,
  })  : itemBuilder = null,
        // itemBuilder is null when using direct items list
        itemCount = items != null ? items.length : 0,
        // Count is based on items length
        assert(items != null),
        // Ensure items list is not null
        super(key: key);

  /// The on demand item builder constructor
  const ExpandableCarousel.builder({
    required this.itemCount,
    required this.itemBuilder,
    required this.options,
    Key? key,
  })  : items = null,
        // Items list is null when using item builder
        assert(itemCount != null),
        // Ensure itemCount is provided
        assert(itemBuilder != null),
        // Ensure itemBuilder function is provided
        super(key: key);

  /// The widget item builder that will be used to build item on demand
  /// The third argument is the PageView's real index, can be used to cooperate
  /// with Hero.
  final ExtendedWidgetBuilder? itemBuilder;

  /// The count of items to be shown in the carousel
  final int? itemCount;

  /// The widgets to be shown in the carousel of default constructor
  final List<Widget>? items;

  /// [ExpandableCarouselOptions] to create a [ExpandableCarouselState] with
  final ExpandableCarouselOptions options;

  @override
  ExpandableCarouselWidgetState createState() =>
      ExpandableCarouselWidgetState();
}

class ExpandableCarouselWidgetState extends State<ExpandableCarousel>
    with TickerProviderStateMixin {
  /// mode is related to why the page is being changed
  CarouselPageChangedReason changeReasonMode =
      CarouselPageChangedReason.controller;

  /// Carousel state to manage internal state like page controller, item count, etc.
  ExpandableCarouselState? _carouselState;

  /// Page controller to manage page views and transitions
  PageController? _pageController;

  /// Current page index (used for indicator sync too)
  int _currentPage = 0;

  /// Delta for tracking page transition progress (used for smooth animations)
  double _pageDelta = 0.0;

  /// Current page index (used for indicator sync too)
  int _previousPage = 0;

  /// Flag for the first page load
  bool _firstPageLoaded = false;

  /// Flag to manage controller disposal
  bool _shouldDisposePageController = false;

  /// List to store sizes of carousel items
  late List<double> _sizes;

  /// Timer to manage auto-play functionality
  Timer? _timer;

  /// Retrieve options for the carousel
  ExpandableCarouselOptions get options => widget.options;

  /// Check if using builder
  bool get isBuilder => widget.itemBuilder != null;

  /// Get size of current item
  double get _currentSize => _sizes[_currentPage];

  /// Get size of previous item
  double get _previousSize => _sizes[_previousPage];

  /// Check scroll direction
  bool get _isHorizontalScroll =>
      widget.options.scrollDirection == Axis.horizontal;

  /// Retrieve the carousel controller, or create a new one if not provided
  ExpandableCarouselControllerImpl get carouselController =>
      widget.options.controller != null
          ? widget.options.controller as ExpandableCarouselControllerImpl
          : ExpandableCarouselController() as ExpandableCarouselControllerImpl;

  /// Initialize state when the widget is first created
  @override
  void initState() {
    _initCarouselState(); // Initialize the state
    _sizes = _prepareSizes(); // Prepare sizes for items
    _pageController = _createPageController(); // Create page controller
    _carouselState!.pageController = _pageController; // Set page controller

    _pageController!
        .addListener(_changeIndexPageDelta); // Listen for page changes

    // Initialize auto-play
    _handleAutoPlay();

    super.initState();
  }

  /// Handle updates to the widget when it rebuilds
  @override
  void didUpdateWidget(covariant ExpandableCarousel oldWidget) {
    _carouselState!.options = options; // Update carousel options
    _carouselState!.itemCount =
        widget.itemCount ?? widget.items?.length; // Update item count

    _pageController = _createPageController(); // Recreate page controller
    _carouselState!.pageController = _pageController; // Update page controller
    _shouldDisposePageController = widget.options.controller == null;

    _pageController
        ?.addListener(_changeIndexPageDelta); // Listen for page changes

    if (_shouldReinitializeHeights(oldWidget)) {
      _reinitializeSizes(); // Reinitialize item sizes if needed
    }

    // Handle auto-play when widget updates
    _handleAutoPlay();

    super.didUpdateWidget(oldWidget);
  }

  /// Dispose resources when widget is removed from the tree
  @override
  void dispose() {
    _clearTimer(); // Clear the auto-play timer
    _pageController
        ?.removeListener(_changeIndexPageDelta); // Remove page change listener
    if (_shouldDisposePageController) {
      _pageController?.dispose(); // Dispose of the page controller if needed
    }
    super.dispose();
  }

  /// Initialize the carousel state
  void _initCarouselState() {
    // Initialize carousel state with options and callbacks for timer handling
    _carouselState = ExpandableCarouselState(
      options,
      _clearTimer,
      _resumeTimer,
      _changeMode,
    );

    _carouselState!.itemCount =
        widget.itemCount ?? widget.items?.length; // Set item count
    carouselController.state = _carouselState; // Assign state to controller
    _carouselState!.initialPage =
        widget.options.initialPage; // Set initial page
    _carouselState!.realPage = options.enableInfiniteScroll
        ? _carouselState!.initialPage +
            (_carouselState!.itemCount ?? widget.items?.length ?? 0) *
                10000 // Arbitrary large multiplier
        : _carouselState!.initialPage;

    _currentPage = _carouselState!.initialPage; // Set current page
    _previousPage =
        _currentPage - 1 < 0 ? 0 : _currentPage - 1; // Set previous page
    _shouldDisposePageController = widget.options.controller ==
        null; // Determine if the controller should be disposed
  }

  /// Create a page controller for the carousel
  PageController _createPageController() {
    return PageController(
      viewportFraction: options.viewportFraction, // Set viewport fraction
      keepPage: options.keepPage, // Keep page position
      initialPage: _carouselState!.realPage, // Set initial page for controller
    );
  }

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
            _firstPageLoaded = true; // Set first page loaded flag
            _previousPage = _currentPage; // Update previous page
            _currentPage = actualIndex; // Update current page
            _pageDelta = pageIndex - pageIndex.floor(); // Calculate delta
          });
        }
      });
    }
  }

  /// Change the page change reason mode
  void _changeMode(CarouselPageChangedReason _mode) {
    changeReasonMode = _mode; // Update the change reason mode
  }

  /// Create a timer for auto-play functionality
  Timer? _getTimer() {
    if (!widget.options.autoPlay) {
      return null; // Return null if auto-play is disabled
    }

    return Timer.periodic(widget.options.autoPlayInterval, (_) {
      final route = ModalRoute.of(context);
      if (route?.isCurrent == false) {
        return;
      }

      var previousReason = changeReasonMode;
      _changeMode(CarouselPageChangedReason.timed);

      var nextPage = _carouselState!.pageController!.page!.round() + 1;
      var itemCount = widget.itemCount ?? widget.items?.length ?? 0;

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
          .then((_) => _changeMode(previousReason)); // Restore previous reason
    });
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

  /// Prepare the sizes for items in the carousel
  List<double> _prepareSizes() {
    return isBuilder
        ? List.filled(widget.itemCount!, widget.options.estimatedPageSize)
        : widget.items!.map((_) => widget.options.estimatedPageSize).toList();
  }

  /// Check if sizes need to be reinitialized when the widget is updated
  bool _shouldReinitializeHeights(ExpandableCarousel oldWidget) {
    if (oldWidget.itemBuilder != null && isBuilder) {
      return oldWidget.itemCount != widget.itemCount;
    }
    return oldWidget.items?.length != widget.items?.length;
  }

  /// Reinitialize the sizes of items in the carousel
  void _reinitializeSizes() {
    final currentPageSize = _sizes[_currentPage];
    _sizes = _prepareSizes();

    if (_currentPage >= _sizes.length) {
      final differenceFromPreviousToCurrent = _previousPage - _currentPage;
      _currentPage = _sizes.length - 1;
      var previousReason = changeReasonMode;
      _changeMode(CarouselPageChangedReason.timed);
      widget.options.onPageChanged?.call(_currentPage, previousReason);

      _previousPage = (_currentPage + differenceFromPreviousToCurrent)
          .clamp(0, _sizes.length - 1);
    }

    _previousPage = _previousPage.clamp(0, _sizes.length - 1);
    _sizes[_currentPage] = currentPageSize;
  }

  /// Retrieve the duration for animation
  Duration _getDuration() {
    if (_firstPageLoaded) {
      return widget.options.autoPlayAnimationDuration;
    }
    return Duration.zero;
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
    // If `enlargeStrategy` is `CenterPageEnlargeStrategy.height`
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

  /// Wrap gestures for touch events
  Widget _getGestureWrapper({required Widget child}) {
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
                _changeMode(CarouselPageChangedReason
                    .manual); // Change the page change reason mode
              }
              ..onDown = (_) {
                if (widget.options.pauseAutoPlayOnTouch) {
                  _clearTimer(); // Pause auto-play when user interacts
                }

                _changeMode(CarouselPageChangedReason
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
        child: child, // The child widget (carousel)
      ),
    );
  }

  /// The method that builds the carousel
  Widget _buildCarouselWidget(BuildContext context) {
    return PageView.builder(
      key: widget.options.pageViewKey,
      scrollBehavior: widget.options.scrollBehavior ??
          ScrollConfiguration.of(context).copyWith(
            scrollbars: false,
            overscroll: false,
            dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
          ),
      controller: _carouselState!.pageController,
      reverse: widget.options.reverse,
      physics: widget.options.physics,
      pageSnapping: widget.options.pageSnapping,
      clipBehavior: widget.options.clipBehavior,
      scrollDirection: widget.options.scrollDirection,
      dragStartBehavior: widget.options.dragStartBehavior,
      allowImplicitScrolling: widget.options.allowImplicitScrolling,
      restorationId: widget.options.restorationId,
      padEnds: widget.options.padEnds,
      itemCount: widget.options.enableInfiniteScroll
          ? null // Infinite scroll mode does not need item count
          : widget.itemCount ?? widget.items!.length,
      onPageChanged: (int index) {
        var currentPage = getRealIndex(
          index + _carouselState!.initialPage,
          _carouselState!.realPage,
          widget.itemCount,
        );

        if (widget.options.onPageChanged != null) {
          widget.options.onPageChanged!(currentPage, changeReasonMode);
        }
      },
      itemBuilder: (BuildContext context, int idx) {
        // Calculate the real index in infinite scroll mode
        final int index = getRealIndex(
          idx + _carouselState!.initialPage,
          _carouselState!.realPage,
          widget.itemCount,
        );

        return AnimatedBuilder(
          animation: _carouselState!.pageController!,
          builder: (BuildContext context, Widget? child) {
            var distortionValue = 1.0;

            // Calculate distortion for enlargeCenterPage option
            if (widget.options.enlargeCenterPage != null &&
                widget.options.enlargeCenterPage == true) {
              double? itemOffset = 0.0;

              // Check if the page controller has dimensions
              final pageControllerPosition =
                  _carouselState?.pageController?.position;
              if (pageControllerPosition != null &&
                  pageControllerPosition.hasPixels &&
                  pageControllerPosition.hasContentDimensions) {
                // Calculate item offset
                final page = _carouselState?.pageController?.page;
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

              // Calculate distortion ratio for center page enlargement
              final distortionRatio =
                  1 - (itemOffset.abs() * widget.options.enlargeFactor!);

              // Transform the distortion value for smooth enlargement
              distortionValue =
                  Curves.easeOut.transform(distortionRatio.clamp(0.0, 1.0));
            }

            // Calculate the dimension
            final dimen = MediaQuery.of(context).size.width *
                (1 / (widget.options.aspectRatio ?? 1.0));

            // Apply horizontal scrolling transformations
            if (widget.options.scrollDirection == Axis.horizontal) {
              return _getCenterWrapper(
                _getEnlargeWrapper(
                  child,
                  height: distortionValue * dimen,
                  width: distortionValue * dimen,
                  scale: distortionValue,
                ),
              );
            } else {
              return _getCenterWrapper(
                _getEnlargeWrapper(
                  child,
                  width: distortionValue * dimen,
                  height: distortionValue * dimen,
                  scale: distortionValue,
                ),
              );
            }
          },
          child: OverflowPage(
            onSizeChange: (size) => setState(
              () => _sizes[index] =
                  _isHorizontalScroll ? size.height : size.width,
            ),
            alignment: Alignment.topCenter,
            scrollDirection: widget.options.scrollDirection,
            child: widget.items != null
                ? widget.items!.isNotEmpty
                    ? widget.items![index]
                    : const SizedBox()
                : widget.itemBuilder!(context, index, idx),
          ),
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
    // If `showIndicator` option is true
    if (widget.options.showIndicator &&
        widget.options.slideIndicator != null &&
        widget.itemCount! > 1) {
      // If `floatingIndicator` option is true
      if (widget.options.floatingIndicator) {
        return _getGestureWrapper(
          child: TweenAnimationBuilder<double>(
            curve: widget.options.autoPlayCurve,
            duration: _getDuration(),
            tween: Tween<double>(begin: _previousSize, end: _currentSize),
            builder: (context, value, child) => SizedBox(
              height: _isHorizontalScroll ? value : null,
              width: !_isHorizontalScroll ? value : null,
              child: child,
            ),
            child: Stack(children: [
              _buildCarouselWidget(context),
              Positioned(
                bottom: 8.0,
                left: 0.0,
                right: 0.0,
                child: _buildSlideIndicator(),
              ),
            ]),
          ),
        );
      }

      // If `floatingIndicator` option is false
      return _getGestureWrapper(
        child: TweenAnimationBuilder<double>(
          curve: widget.options.autoPlayCurve,
          duration: _getDuration(),
          tween: Tween<double>(begin: _previousSize, end: _currentSize),
          builder: (context, value, child) => SizedBox(
            height: _isHorizontalScroll ? value : null,
            width: !_isHorizontalScroll ? value : null,
            child: child,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(child: _buildCarouselWidget(context)),
              const SizedBox(height: 8.0),
              Expanded(
                flex: 0,
                child: _buildSlideIndicator(),
              ),
            ],
          ),
        ),
      );
    }

    // If `showIndicator` option is false
    return _getGestureWrapper(
      child: TweenAnimationBuilder<double>(
        curve: widget.options.autoPlayCurve,
        duration: _getDuration(),
        tween: Tween<double>(begin: _previousSize, end: _currentSize),
        builder: (context, value, child) => SizedBox(
          height: _isHorizontalScroll ? value : null,
          width: !_isHorizontalScroll ? value : null,
          child: child,
        ),
        child: _buildCarouselWidget(context),
      ),
    );
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
