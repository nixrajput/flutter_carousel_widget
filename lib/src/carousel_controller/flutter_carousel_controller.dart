import 'dart:async';

import 'package:flutter/animation.dart';

import '../carousel_state/flutter_carousel_state.dart';
import '../enums/carousel_page_changed_reason.dart';
import '../utils/flutter_carousel_utils.dart';

abstract class FlutterCarouselController {
  /// Factory constructor that returns an implementation of the controller.
  factory FlutterCarouselController() => FlutterCarouselControllerImpl();

  /// Indicates if the controller is ready.
  bool get ready;

  /// Future that completes when the controller is ready.
  Future<void> get onReady;

  /// Navigates to the next page in the carousel.
  void nextPage({Duration? duration, Curve? curve});

  /// Navigates to the previous page in the carousel.
  void previousPage({Duration? duration, Curve? curve});

  /// Jumps to a specific page in the carousel without animation.
  void jumpToPage(int page);

  /// Animates the carousel to a specific page.
  void animateToPage(int page, {Duration? duration, Curve? curve});

  /// Starts the auto-play functionality of the carousel.
  void startAutoPlay();

  /// Stops the auto-play functionality of the carousel.
  void stopAutoPlay();
}

class FlutterCarouselControllerImpl implements FlutterCarouselController {
  final Completer<void> _readyCompleter = Completer<void>();
  FlutterCarouselState? _state;

  /// Animates the controlled [FlutterCarousel] from the current page to the given page.
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  @override
  void animateToPage(
    int page, {
    Duration? duration = const Duration(milliseconds: 300),
    Curve? curve = Curves.linear,
  }) async {
    final isNeedResetTimer = _state!.options.pauseAutoPlayOnManualNavigate;

    if (isNeedResetTimer) {
      _state!.onResetTimer();
    }

    // Calculate the real index to animate to.
    final index = getRealIndex(_state!.pageController?.page!.toInt() ?? 0,
        _state!.realPage - _state!.initialPage, _state!.itemCount);

    _setModeController();

    // Animate to the target page.
    await _state!.pageController!.animateToPage(
        (_state!.pageController?.page!.toInt() ?? 0) + page - index,
        duration: duration!,
        curve: curve!);

    if (isNeedResetTimer) {
      _state!.onResumeTimer();
    }
  }

  /// Changes which page is displayed in the controlled [FlutterCarousel].
  /// Jumps the page position from its current value to the given value,
  /// without animation, and without checking if the new value is in range.
  @override
  void jumpToPage(int page) async {
    final index = getRealIndex(_state!.pageController?.page!.toInt() ?? 0,
        _state!.realPage - _state!.initialPage, _state!.itemCount);

    _setModeController();

    // Jump directly to the target page.
    return _state!.pageController?.jumpToPage(
        (_state!.pageController?.page!.toInt() ?? 0) + page - index);
  }

  /// Animates the controlled [FlutterCarousel] to the next page.
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  @override
  void nextPage({
    Duration? duration = const Duration(milliseconds: 300),
    Curve? curve = Curves.linear,
  }) async {
    final isNeedResetTimer = _state!.options.pauseAutoPlayOnManualNavigate;

    if (isNeedResetTimer) {
      _state!.onResetTimer();
    }

    _setModeController();

    // Navigate to the next page.
    await _state!.pageController?.nextPage(duration: duration!, curve: curve!);

    if (isNeedResetTimer) {
      _state!.onResumeTimer();
    }
  }

  /// Future that completes when the controller is ready.
  @override
  Future<void> get onReady => _readyCompleter.future;

  /// Animates the controlled [FlutterCarousel] to the previous page.
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  @override
  void previousPage({
    Duration? duration = const Duration(milliseconds: 300),
    Curve? curve = Curves.linear,
  }) async {
    final isNeedResetTimer = _state!.options.pauseAutoPlayOnManualNavigate;

    if (isNeedResetTimer) {
      _state!.onResetTimer();
    }

    _setModeController();

    // Navigate to the previous page.
    await _state!.pageController!
        .previousPage(duration: duration!, curve: curve!);

    if (isNeedResetTimer) {
      _state!.onResumeTimer();
    }
  }

  /// Checks if the controller is ready to interact with the carousel.
  @override
  bool get ready => _state != null;

  /// Starts the controlled [FlutterCarousel] autoplay.
  /// The carousel will only autoPlay if the [autoPlay] parameter
  /// in [FlutterCarouselOptions] is true.
  @override
  void startAutoPlay() {
    _state!.onResumeTimer();
  }

  /// Stops the controlled [FlutterCarousel] from autoplaying.
  /// This is a more on-demand way of doing this. Use the [autoPlay]
  /// parameter in [FlutterCarouselOptions] to specify the autoPlay behaviour of the carousel.
  @override
  void stopAutoPlay() {
    _state!.onResetTimer();
  }

  /// Sets the current state of the carousel.
  set state(FlutterCarouselState? state) {
    _state = state;
    if (!_readyCompleter.isCompleted) {
      _readyCompleter.complete();
    }
  }

  /// Sets the carousel change mode to controller-based.
  void _setModeController() =>
      _state!.changeMode(CarouselPageChangedReason.controller);
}
