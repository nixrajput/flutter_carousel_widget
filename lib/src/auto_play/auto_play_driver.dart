import 'dart:async';

import 'carousel_auto_play.dart';

/// Why autoplay is holding. It runs only while none applies.
enum AutoPlayPause {
  /// A pointer is down on the carousel.
  touch,

  /// A mouse is over the carousel.
  hover,

  /// Keyboard focus is inside the carousel.
  focus,

  /// The carousel's route is not the top one.
  route,

  /// The app is not in the foreground.
  lifecycle,

  /// `TickerMode` is off, as in an inactive tab.
  ticker,

  /// The platform asks for reduced motion.
  reducedMotion,

  /// The controller stopped autoplay.
  stopped,

  /// A finite carousel with `stopAtEnd` reached its end.
  ended,

  /// The carousel has fewer than two items, so there is nowhere to move.
  items,
}

/// Schedules autoplay ticks. It keeps one timer for the current item's
/// interval, set again on every settle instead of running periodically, which
/// is what lets each item have its own interval.
class AutoPlayDriver {
  /// Creates a driver calling [onTick] when an interval ends.
  AutoPlayDriver({required this.onTick, required this.onRunningChanged});

  /// Moves the carousel on.
  final void Function() onTick;

  /// Called when [isRunning] changes.
  final void Function() onRunningChanged;

  CarouselAutoPlay? _config;
  final _pauses = <AutoPlayPause>{};
  Timer? _timer;
  var _index = 0;

  /// Whether autoplay is configured and nothing holds it.
  bool get isRunning => _config != null && _pauses.isEmpty;

  /// Applies [config]. A running timer keeps going while autoplay stays on,
  /// so a parent rebuild never restarts the interval.
  void configure(CarouselAutoPlay? config) {
    final wasRunning = isRunning;
    final wasOn = _config != null;
    _config = config;
    if (wasOn != (config != null)) _schedule();
    if (wasRunning != isRunning) onRunningChanged();
  }

  /// Holds autoplay for [reason].
  void pause(AutoPlayPause reason) => _change(() => _pauses.add(reason));

  /// Releases the hold for [reason].
  void resume(AutoPlayPause reason) => _change(() => _pauses.remove(reason));

  void _change(bool Function() mutate) {
    final wasRunning = isRunning;
    if (!mutate() || wasRunning == isRunning) return;
    _schedule();
    onRunningChanged();
  }

  /// The carousel settled on [index]; [restart] starts its interval over.
  void settled(int index, {required bool restart}) {
    _index = index;
    if (restart || _timer == null) _schedule();
  }

  void _schedule() {
    _timer?.cancel();
    _timer = null;
    final config = _config;
    if (config == null || _pauses.isNotEmpty) return;
    _timer = Timer(config.intervalFor?.call(_index) ?? config.interval, () {
      _timer = null;
      onTick();
    });
  }

  /// Cancels the timer.
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
