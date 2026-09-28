import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';

/// Moves a carousel on by itself, one item at a time.
///
/// Besides the pauses configured here, autoplay always holds while the route
/// is covered, the app is in the background, the carousel sits in an inactive
/// tab (`TickerMode` off), the platform asks for reduced motion, or the
/// controller has stopped it.
@immutable
class CarouselAutoPlay {
  /// Creates an autoplay configuration.
  const CarouselAutoPlay({
    this.interval = const Duration(seconds: 5),
    this.intervalFor,
    this.duration,
    this.curve,
    this.pauseOnTouch = true,
    this.pauseOnHover = true,
    this.pauseOnFocus = true,
    this.restartOnInteraction = true,
    this.stopAtEnd = false,
  });

  /// How long each item stays before the next, unless [intervalFor] says
  /// otherwise.
  final Duration interval;

  /// How long the item at an index stays. `null` uses [interval] for every
  /// item.
  final Duration Function(int index)? intervalFor;

  /// How long each move takes. `null` uses 500 ms.
  final Duration? duration;

  /// The curve of each move. `null` uses [Curves.easeInOutCubicEmphasized].
  final Curve? curve;

  /// Whether a finger or a pressed pointer on the carousel holds it.
  final bool pauseOnTouch;

  /// Whether a mouse over the carousel holds it.
  final bool pauseOnHover;

  /// Whether keyboard focus inside the carousel holds it.
  final bool pauseOnFocus;

  /// Whether a move by the user or the controller starts the interval again.
  final bool restartOnInteraction;

  /// Whether a finite carousel stops at its last item instead of rewinding
  /// to its first.
  final bool stopAtEnd;

  @override
  bool operator ==(Object other) =>
      other is CarouselAutoPlay &&
      other.interval == interval &&
      other.intervalFor == intervalFor &&
      other.duration == duration &&
      other.curve == curve &&
      other.pauseOnTouch == pauseOnTouch &&
      other.pauseOnHover == pauseOnHover &&
      other.pauseOnFocus == pauseOnFocus &&
      other.restartOnInteraction == restartOnInteraction &&
      other.stopAtEnd == stopAtEnd;

  @override
  int get hashCode => Object.hash(
    interval,
    intervalFor,
    duration,
    curve,
    pauseOnTouch,
    pauseOnHover,
    pauseOnFocus,
    restartOnInteraction,
    stopAtEnd,
  );
}
