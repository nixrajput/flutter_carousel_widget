library flutter_carousel_widget;

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'flutter_carousel_controller.dart';
import 'flutter_carousel_options.dart';
import 'flutter_carousel_state.dart';
import 'flutter_carousel_utils.dart';

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

  final int? itemCount;

  /// A [MapController], used to control the map.
  final CarouselControllerImpl _carouselController;

  FlutterCarousel({
    required this.items,
    required this.options,
    carouselController,
    Key? key,
  })  : itemBuilder = null,
        itemCount = items != null ? items.length : 0,
        _carouselController = carouselController ??
            CarouselController() as CarouselControllerImpl,
        super(key: key);

  /// The on demand item builder constructor
  FlutterCarousel.builder(
      {required this.itemCount,
      required this.itemBuilder,
      required this.options,
      carouselController,
      Key? key})
      : items = null,
        _carouselController = carouselController ??
            CarouselController() as CarouselControllerImpl,
        super(key: key);

  @override
  FlutterCarouselState createState() =>
      FlutterCarouselState(_carouselController);
}

class FlutterCarouselState extends State<FlutterCarousel>
    with TickerProviderStateMixin {
  final CarouselControllerImpl carouselController;

  Timer? _timer;

  FlutterCarouselState(this.carouselController);

  CarouselOptions get options => widget.options;

  CarouselState? _carouselState;

  PageController? _pageController;

  /// mode is related to why the page is being changed
  CarouselPageChangedReason mode = CarouselPageChangedReason.controller;

  int? _currentPage;
  double _pageDelta = 0;

  void changeMode(CarouselPageChangedReason _mode) {
    mode = _mode;
  }

  @override
  void didUpdateWidget(FlutterCarousel oldWidget) {
    _carouselState!.options = options;
    _carouselState!.itemCount = widget.itemCount;

    // pageController needs to be re-initialized to respond to state changes
    if (oldWidget.itemCount != widget.itemCount) {
      _initPageController();
    }

    // handle autoplay when state changes
    handleAutoPlay();

    super.didUpdateWidget(oldWidget);
  }

  @override
  void initState() {
    super.initState();

    _carouselState =
        CarouselState(options, clearTimer, resumeTimer, changeMode);

    _currentPage = widget.options.initialPage;

    _carouselState!.itemCount = widget.itemCount;
    carouselController.state = _carouselState;
    _carouselState!.initialPage = widget.options.initialPage;
    _carouselState!.realPage = options.enableInfiniteScroll
        ? _carouselState!.realPage + _carouselState!.initialPage
        : _carouselState!.initialPage;

    _initPageController();

    handleAutoPlay();
  }

  void _initPageController() {
    _pageController?.dispose();
    _pageController = PageController(
      viewportFraction: options.viewportFraction,
      initialPage: _currentPage!,
    );
    _pageController!.addListener(() {
      setState(() {
        _currentPage = _pageController!.page!.floor();
        _pageDelta = _pageController!.page! - _pageController!.page!.floor();
      });
    });

    _carouselState!.pageController = _pageController;
  }

  Timer? getTimer() {
    return widget.options.autoPlay
        ? Timer.periodic(widget.options.autoPlayInterval, (_) {
            final route = ModalRoute.of(context);
            if (route?.isCurrent == false) {
              return;
            }

            CarouselPageChangedReason previousReason = mode;
            changeMode(CarouselPageChangedReason.timed);
            int nextPage = _carouselState!.pageController!.page!.round() + 1;
            int itemCount = widget.itemCount ?? widget.items!.length;

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
          })
        : null;
  }

  void clearTimer() {
    if (_timer != null) {
      _timer?.cancel();
      _timer = null;
    }
  }

  void resumeTimer() {
    _timer ??= getTimer();
  }

  void handleAutoPlay() {
    bool autoPlayEnabled = widget.options.autoPlay;

    if (autoPlayEnabled && _timer != null) return;

    clearTimer();
    if (autoPlayEnabled) {
      resumeTimer();
    }
  }

  Widget getGestureWrapper(Widget child) {
    Widget wrapper;
    if (widget.options.height != null) {
      wrapper = SizedBox(
        height: widget.options.height,
        child: child,
      );
    } else if (widget.options.height == null &&
        widget.options.aspectRatio != null) {
      wrapper = AspectRatio(
        aspectRatio: widget.options.aspectRatio!,
        child: child,
      );
    } else {
      wrapper = SizedBox(
        child: child,
      );
    }

    return RawGestureDetector(
      gestures: {
        _MultipleGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<_MultipleGestureRecognizer>(
                () => _MultipleGestureRecognizer(),
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
          instance.onCancel = () {
            onPanUp();
          };
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
    if (widget.options.enlargeStrategy == CenterPageEnlargeStrategy.height) {
      return SizedBox(
        child: child,
        width: width,
        height: height,
      );
    }
    return SizedBox(
      child: child,
    );
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
    super.dispose();
    clearTimer();
  }

  @override
  Widget build(BuildContext context) {
    return getGestureWrapper(
      Stack(
        children: [
          PageView.builder(
            physics: widget.options.scrollPhysics,
            scrollDirection: widget.options.scrollDirection,
            pageSnapping: widget.options.pageSnapping,
            controller: _carouselState!.pageController,
            reverse: widget.options.reverse,
            itemCount:
                widget.options.enableInfiniteScroll ? null : widget.itemCount,
            key: widget.options.pageViewKey,
            onPageChanged: (int index) {
              int currentPage = getRealIndex(
                  index + _carouselState!.initialPage,
                  _carouselState!.realPage,
                  widget.itemCount);
              if (widget.options.onPageChanged != null) {
                widget.options.onPageChanged!(currentPage, mode);
              }
            },
            itemBuilder: (BuildContext context, int idx) {
              final int index = getRealIndex(idx + _carouselState!.initialPage,
                  _carouselState!.realPage, widget.itemCount);

              return AnimatedBuilder(
                animation: _carouselState!.pageController!,
                child: (widget.items != null)
                    ? (widget.items!.isNotEmpty
                        ? widget.items![index]
                        : Container())
                    : widget.itemBuilder!(context, index, idx),
                builder: (BuildContext context, child) {
                  double distortionValue = 1.0;
                  // if `enlargeCenterPage` is true, we must calculate the carousel item's height
                  // to display the visual effect
                  if (widget.options.enlargeCenterPage != null &&
                      widget.options.enlargeCenterPage == true) {
                    double itemOffset;
                    // pageController.page can only be accessed after the first build,
                    // so in the first build we calculate the item offset manually
                    try {
                      itemOffset = _carouselState!.pageController!.page! - idx;
                    } catch (e) {
                      BuildContext storageContext = _carouselState!
                          .pageController!.position.context.storageContext;
                      final double? previousSavedPosition =
                          PageStorage.of(storageContext)
                              ?.readState(storageContext) as double?;
                      if (previousSavedPosition != null) {
                        itemOffset = previousSavedPosition - idx.toDouble();
                      } else {
                        itemOffset = _carouselState!.realPage.toDouble() -
                            idx.toDouble();
                      }
                    }
                    final num distortionRatio =
                        (1 - (itemOffset.abs() * 0.3)).clamp(0.0, 1.0);
                    distortionValue =
                        Curves.easeOut.transform(distortionRatio as double);
                  }

                  final double height = widget.options.height ??
                      MediaQuery.of(context).size.width *
                          (1 / (widget.options.aspectRatio ?? 16 / 9));

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
                      ),
                    );
                  }
                },
              );
            },
          ),
          if (widget.options.showIndicator &&
              widget.options.slideIndicator != null &&
              widget.itemCount! > 0)
            Positioned(
              bottom: 8.0,
              left: 0.0,
              right: 0.0,
              child: widget.options.slideIndicator!.build(
                  _currentPage! % widget.itemCount!,
                  _pageDelta,
                  widget.itemCount!),
            )
        ],
      ),
    );
  }
}

class _MultipleGestureRecognizer extends PanGestureRecognizer {}
