import 'dart:async';

import 'package:flutter/animation.dart';

import '../carousel_state/expandable_carousel_state.dart';
import '../enums/carousel_page_changed_reason.dart';
import '../utils/flutter_carousel_utils.dart';

abstract class ExpandableCarouselController {
  factory ExpandableCarouselController() => ExpandableCarouselControllerImpl();

  bool get ready;

  Future<void> get onReady;

  void nextPage({Duration? duration, Curve? curve});

  void previousPage({Duration? duration, Curve? curve});

  void jumpToPage(int page);

  void animateToPage(int page, {Duration? duration, Curve? curve});

  void startAutoPlay();

  void stopAutoPlay();
}

class ExpandableCarouselControllerImpl implements ExpandableCarouselController {
  final Completer<void> _readyCompleter = Completer<void>();
  ExpandableCarouselState? _state;

  /// Animates the controlled [ExpandableCarousel] from the current page to the given page.
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  @override
  void animateToPage(int page,
      {Duration? duration = const Duration(milliseconds: 300),
      Curve? curve = Curves.linear}) async {
    final isNeedResetTimer = _state!.options.pauseAutoPlayOnManualNavigate;

    if (isNeedResetTimer) {
      _state!.onResetTimer();
    }

    final index = getRealIndex(_state!.pageController?.page!.toInt() ?? 0,
        _state!.realPage - _state!.initialPage, _state!.itemCount);
    _setModeController();

    await _state!.pageController!.animateToPage(
        (_state!.pageController?.page!.toInt() ?? 0) + page - index,
        duration: duration!,
        curve: curve!);

    if (isNeedResetTimer) {
      _state!.onResumeTimer();
    }
  }

  /// Changes which page is displayed in the controlled [ExpandableCarousel].
  /// Jumps the page position from its current value to the given value,
  /// without animation, and without checking if the new value is in range.
  @override
  void jumpToPage(int page) {
    final index = getRealIndex(_state!.pageController?.page!.toInt() ?? 0,
        _state!.realPage - _state!.initialPage, _state!.itemCount);

    _setModeController();

    return _state!.pageController?.jumpToPage(
        (_state!.pageController?.page!.toInt() ?? 0) + page - index);
  }

  /// Animates the controlled [ExpandableCarousel] to the next page.
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  @override
  void nextPage(
      {Duration? duration = const Duration(milliseconds: 300),
      Curve? curve = Curves.linear}) async {
    final isNeedResetTimer = _state!.options.pauseAutoPlayOnManualNavigate;

    if (isNeedResetTimer) {
      _state!.onResetTimer();
    }

    _setModeController();

    await _state!.pageController?.nextPage(duration: duration!, curve: curve!);

    if (isNeedResetTimer) {
      _state!.onResumeTimer();
    }
  }

  @override
  Future<void> get onReady => _readyCompleter.future;

  /// Animates the controlled [ExpandableCarousel] to the previous page.
  /// The animation lasts for the given duration and follows the given curve.
  /// The returned [Future] resolves when the animation completes.
  @override
  void previousPage(
      {Duration? duration = const Duration(milliseconds: 300),
      Curve? curve = Curves.linear}) async {
    final isNeedResetTimer = _state!.options.pauseAutoPlayOnManualNavigate;

    if (isNeedResetTimer) {
      _state!.onResetTimer();
    }

    _setModeController();

    await _state!.pageController
        ?.previousPage(duration: duration!, curve: curve!);

    if (isNeedResetTimer) {
      _state!.onResumeTimer();
    }
  }

  @override
  bool get ready => _state != null;

  /// Starts the controlled [ExpandableCarousel] autoplay.
  /// The carousel will only autoPlay if the [autoPlay] parameter
  /// in [ExpandableCarouselOptions] is true.
  @override
  void startAutoPlay() {
    _state!.onResumeTimer();
  }

  /// Stops the controlled [ExpandableCarousel] from autoplaying.
  /// This is a more on-demand way of doing this. Use the [autoPlay]
  /// parameter in [ExpandableCarouselOptions] to specify the autoPlay behaviour of the carousel.
  @override
  void stopAutoPlay() {
    _state!.onResetTimer();
  }

  set state(ExpandableCarouselState? state) {
    _state = state;
    if (!_readyCompleter.isCompleted) {
      _readyCompleter.complete();
    }
  }

  void _setModeController() =>
      _state!.changeMode(CarouselPageChangedReason.controller);
}
