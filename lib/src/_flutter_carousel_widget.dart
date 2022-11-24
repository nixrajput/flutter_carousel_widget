library flutter_carousel_widget;

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/src/flutter_carousel_controller.dart';
import 'package:flutter_carousel_widget/src/flutter_carousel_options.dart';
import 'package:flutter_carousel_widget/src/flutter_carousel_state.dart';
import 'package:flutter_carousel_widget/src/flutter_carousel_utils.dart';

typedef ExtendedIndexedWidgetBuilder = Widget Function(
    BuildContext context, int index, int realIndex);

class FlutterCarousel extends StatefulWidget {
  /// [CarouselOptions] to create a [FlutterCarouselState] with
  final CarouselOptions options;

  /// The widgets to be shown in the carousel of default constructor
  final List<Widget>? items;

  /// The widget item builder that will be used to build item on demand
  /// The third argument is the PageView's real index, can be used to cooperate
  /// with Hero.
  final ExtendedIndexedWidgetBuilder? itemBuilder;

  /// The count of items to be shown in the carousel
  final int? itemCount;

  /// The default constructor
  const FlutterCarousel({
    required this.items,
    required this.options,
    Key? key,
  })  : itemBuilder = null,
        itemCount = items != null ? items.length : 0,
        super(key: key);

  /// The on demand item builder constructor
  const FlutterCarousel.builder({
    required this.itemCount,
    required this.itemBuilder,
    required this.options,
    Key? key,
  })  : items = null,
        super(key: key);

  @override
  FlutterCarouselState createState() => FlutterCarouselState();
}

class FlutterCarouselState extends State<FlutterCarousel>
    with TickerProviderStateMixin {
  CarouselControllerImpl get carouselController =>
      widget.options.carouselController != null
          ? widget.options.carouselController as CarouselControllerImpl
          : CarouselController() as CarouselControllerImpl;

  Timer? _timer;

  CarouselOptions get options => widget.options;

  CarouselState? _carouselState;

  PageController? _pageController;

  /// mode is related to why the page is being changed
  CarouselPageChangedReason mode = CarouselPageChangedReason.controller;

  int? _currentPage;
  double _pageDelta = 0;

  void changeMode(CarouselPageChangedReason mode) {
    mode = mode;
  }

  @override
  void initState() {
    super.initState();

    _carouselState = CarouselState(
      options,
      clearTimer,
      resumeTimer,
      changeMode,
    );

    _carouselState!.itemCount = widget.itemCount;
    carouselController.state = _carouselState;
    _carouselState!.initialPage = widget.options.initialPage;
    _carouselState!.realPage = options.enableInfiniteScroll
        ? _carouselState!.realPage + _carouselState!.initialPage
        : _carouselState!.initialPage;

    /// For Indicator
    _currentPage = widget.options.initialPage;

    handleAutoPlay();

    _pageController = PageController(
      viewportFraction: options.viewportFraction,
      keepPage: options.keepPage,
      initialPage: _carouselState!.realPage,
    );

    _carouselState!.pageController = _pageController;

    _pageController!.addListener(() {
      setState(() {
        _currentPage = _pageController!.page!.floor();
        _pageDelta = _pageController!.page! - _pageController!.page!.floor();
      });
    });
  }

  @override
  void didUpdateWidget(FlutterCarousel oldWidget) {
    _carouselState!.options = options;
    _carouselState!.itemCount = widget.itemCount;

    /// [_pageController] needs to be re-initialized to respond
    /// to state changes
    _pageController = PageController(
      viewportFraction: options.viewportFraction,
      keepPage: options.keepPage,
      initialPage: _carouselState!.realPage,
    );

    _carouselState!.pageController = _pageController;

    /// handle autoplay when state changes
    handleAutoPlay();

    _pageController!.addListener(() {
      setState(() {
        _currentPage = _pageController!.page!.floor();
        _pageDelta = _pageController!.page! - _pageController!.page!.floor();
      });
    });

    super.didUpdateWidget(oldWidget);
  }

  /// Timer
  Timer? getTimer() {
    if (widget.options.autoPlay == true) {
      return Timer.periodic(widget.options.autoPlayInterval, (_) {
        final route = ModalRoute.of(context);
        if (route?.isCurrent == false) {
          return;
        }

        var previousReason = mode;
        changeMode(CarouselPageChangedReason.timed);
        var nextPage = _carouselState!.pageController!.page!.round() + 1;
        var itemCount = widget.itemCount ?? widget.items!.length;

        if (nextPage >= itemCount &&
            widget.options.enableInfiniteScroll == false) {
          if (widget.options.pauseAutoPlayInFiniteScroll) {
            clearTimer();
            return;
          }
          nextPage = 0;
        }

        _carouselState!.pageController!
            .animateToPage(nextPage,
                duration: widget.options.autoPlayAnimationDuration,
                curve: widget.options.autoPlayCurve)
            .then((_) => changeMode(previousReason));
      });
    }

    return null;
  }

  /// Clear Timer
  void clearTimer() {
    if (_timer != null) {
      _timer?.cancel();
      _timer = null;
    }
  }

  /// Resume Timer
  void resumeTimer() {
    _timer ??= getTimer();
  }

  /// Autoplay
  void handleAutoPlay() {
    var autoPlayEnabled = widget.options.autoPlay;

    if (autoPlayEnabled && _timer != null) return;

    clearTimer();
    if (autoPlayEnabled) {
      resumeTimer();
    }
  }

  void onStart() {
    changeMode(CarouselPageChangedReason.manual);
  }

  void onPanDown() {
    if (widget.options.pauseAutoPlayOnTouch) {
      clearTimer();
    }

    changeMode(CarouselPageChangedReason.manual);
  }

  void onPanUp() {
    if (widget.options.pauseAutoPlayOnTouch) {
      resumeTimer();
    }
  }

  @override
  void dispose() {
    clearTimer();
    super.dispose();
  }

  Widget getGestureWrapper({required Widget child}) {
    Widget wrapper;
    if (widget.options.height != null) {
      wrapper = SizedBox(
        height: widget.options.height,
        child: child,
      );
    } else {
      wrapper = AspectRatio(
        aspectRatio: widget.options.aspectRatio!,
        child: child,
      );
    }

    return RawGestureDetector(
      gestures: {
        _MultipleGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<_MultipleGestureRecognizer>(
                _MultipleGestureRecognizer.new,
                (_MultipleGestureRecognizer instance) {
          instance.onStart = (_) {
            onStart();
          };
          instance.onDown = (_) {
            onPanDown();
          };
          instance.onEnd = (_) {
            onPanUp();
          };
          instance.onCancel = onPanUp;
        }),
      },
      child: NotificationListener(
        onNotification: (dynamic notification) {
          if (widget.options.onScrolled != null &&
              notification is ScrollUpdateNotification) {
            widget.options.onScrolled!(_carouselState!.pageController!.page);
          }
          return false;
        },
        child: wrapper,
      ),
    );
  }

  Widget getCenterWrapper(Widget child) {
    if (widget.options.disableCenter) {
      return Container(
        child: child,
      );
    }
    return Center(child: child);
  }

  Widget getEnlargeWrapper(Widget? child,
      {double? width, double? height, double? scale}) {
    /// If [enlargeStrategy] is [CenterPageEnlargeStrategy.height]
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

  /// The method that builds the carousel
  Widget _buildCarouselWidget(BuildContext context) {
    return PageView.builder(
      padEnds: widget.options.padEnds,
      scrollBehavior: ScrollConfiguration.of(context).copyWith(
        scrollbars: false,
        overscroll: false,
        dragDevices: {PointerDeviceKind.touch, PointerDeviceKind.mouse},
      ),
      clipBehavior: widget.options.clipBehavior,
      physics: widget.options.scrollPhysics,
      scrollDirection: widget.options.scrollDirection,
      pageSnapping: widget.options.pageSnapping,
      controller: _carouselState!.pageController,
      reverse: widget.options.reverse,
      itemCount: widget.options.enableInfiniteScroll ? null : widget.itemCount,
      key: widget.options.pageViewKey,
      onPageChanged: (int index) {
        var currentPage = getRealIndex(index + _carouselState!.initialPage,
            _carouselState!.realPage, widget.itemCount);
        if (widget.options.onPageChanged != null) {
          widget.options.onPageChanged!(currentPage, mode);
        }
      },
      itemBuilder: (BuildContext context, int idx) {
        final index = getRealIndex(
          idx + _carouselState!.initialPage,
          _carouselState!.realPage,
          widget.itemCount,
        );

        return AnimatedBuilder(
          animation: _carouselState!.pageController!,
          child: (widget.items != null)
              ? (widget.items!.isNotEmpty
                  ? widget.items![index]
                  : const SizedBox())
              : widget.itemBuilder!(context, index, idx),
          builder: (BuildContext context, Widget? child) {
            var distortionValue = 1.0;

            /// if `enlargeCenterPage` is true, we must calculate the carousel
            /// item's height to display the visual effect
            if (widget.options.enlargeCenterPage != null &&
                widget.options.enlargeCenterPage == true) {
              /// pageController.page can only be accessed after the first
              /// build, so in the first build we calculate the item
              /// offset manually
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
                    ?.readState(storageContext) as double?;
                if (previousSavedPosition != null) {
                  itemOffset = previousSavedPosition - idx.toDouble();
                } else {
                  itemOffset =
                      _carouselState!.realPage.toDouble() - idx.toDouble();
                }
              }

              /// Calculate [distortionRatio]
              final distortionRatio =
                  1 - (itemOffset.abs() * 0.25).clamp(0.0, 1.0);
              distortionValue = Curves.easeOut.transform(distortionRatio);
            }

            /// Calculate [height]
            final height = widget.options.height ??
                MediaQuery.of(context).size.width *
                    (1 / widget.options.aspectRatio!);

            /// If [scrollDirection] option is [Axis.horizontal]
            if (widget.options.scrollDirection == Axis.horizontal) {
              return getCenterWrapper(
                getEnlargeWrapper(
                  child,
                  height: distortionValue * height,
                  scale: distortionValue,
                ),
              );
            } else {
              return getCenterWrapper(
                getEnlargeWrapper(
                  child,
                  width: distortionValue * MediaQuery.of(context).size.width,
                  scale: distortionValue,
                ),
              );
            }
          },
        );
      },
    );
  }

  /// The method to build the slide indicator
  Widget _buildSlideIndicator() {
    return widget.options.slideIndicator!.build(
      _currentPage! % widget.itemCount!,
      _pageDelta,
      widget.itemCount!,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.options.showIndicator &&
        widget.options.slideIndicator != null &&
        widget.itemCount! > 1) {
      /// If [floatingIndicator] option is [true]
      if (widget.options.floatingIndicator) {
        return getGestureWrapper(
          child: Stack(
            children: [
              _buildCarouselWidget(context),
              Positioned(
                bottom: 8.0,
                left: 0.0,
                right: 0.0,
                child: _buildSlideIndicator(),
              ),
            ],
          ),
        );
      }

      /// If [floatingIndicator] option is [false]
      return getGestureWrapper(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(child: _buildCarouselWidget(context)),
            const SizedBox(height: 8.0),
            _buildSlideIndicator()
          ],
        ),
      );
    }

    return getGestureWrapper(child: _buildCarouselWidget(context));
  }
}

class _MultipleGestureRecognizer extends PanGestureRecognizer {}
