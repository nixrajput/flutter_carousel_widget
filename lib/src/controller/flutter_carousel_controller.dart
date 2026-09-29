import 'package:flutter/animation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';

/// What a carousel offers the controller that drives it. The carousel engine
/// implements it; apps never do.
abstract interface class CarouselBinding {
  /// The current item.
  int get index;

  /// The fractional item position.
  double get position;

  /// Whether autoplay is running now.
  bool get isAutoPlaying;

  /// Moves by [delta] items.
  Future<void> step(int delta, {Duration? duration, Curve? curve});

  /// Moves to item [index].
  Future<void> animateTo(int index, {Duration? duration, Curve? curve});

  /// Jumps to item [index].
  void jumpTo(int index);

  /// Stops autoplay until set back to false.
  set autoPlayStopped(bool value);
}

/// Drives a `FlutterCarousel` or an `ExpandableCarousel`, and reports its
/// state.
///
/// Listen to it to follow the current item and whether autoplay is running.
/// It attaches when its carousel is first built. Until then, and after the
/// carousel is disposed, reading [index] or calling a method throws a
/// [StateError].
class FlutterCarouselController extends ChangeNotifier {
  /// Creates a controller. Pass it to one carousel, and dispose it when that
  /// carousel's owner is disposed.
  FlutterCarouselController();

  CarouselBinding? _binding;
  var _disposed = false;

  /// Whether a carousel is using this controller.
  bool get isAttached => _binding != null;

  CarouselBinding get _carousel =>
      _binding ??
      (throw StateError(
        'FlutterCarouselController is not attached to a carousel. Pass it to '
        'a FlutterCarousel or ExpandableCarousel and use it after that '
        'carousel is built.',
      ));

  /// The current item, rounded the way `PageView` rounds.
  int get index => _carousel.index;

  /// The fractional item position, in `[0, itemCount)`: `2.5` is halfway
  /// between the third and fourth items.
  double get position => _carousel.position;

  /// Whether autoplay is running now. False when detached.
  bool get isAutoPlaying => _binding?.isAutoPlaying ?? false;

  /// Moves to the next item. `null` [duration] or [curve] uses the carousel's
  /// default motion.
  Future<void> nextPage({Duration? duration, Curve? curve}) =>
      _carousel.step(1, duration: duration, curve: curve);

  /// Moves to the previous item.
  Future<void> previousPage({Duration? duration, Curve? curve}) =>
      _carousel.step(-1, duration: duration, curve: curve);

  /// Moves to item [index], the short way round in an infinite carousel.
  ///
  /// Throws a [RangeError] when [index] is outside `[0, itemCount)`.
  Future<void> animateToPage(int index, {Duration? duration, Curve? curve}) =>
      _carousel.animateTo(index, duration: duration, curve: curve);

  /// Jumps to item [index] without animating.
  void jumpToPage(int index) => _carousel.jumpTo(index);

  /// Resumes autoplay after [stopAutoPlay].
  void startAutoPlay() => _carousel.autoPlayStopped = false;

  /// Stops autoplay until [startAutoPlay], through touches and rebuilds: the
  /// pause control WCAG 2.2.2 asks for.
  void stopAutoPlay() => _carousel.autoPlayStopped = true;

  void _changed() {
    if (!_disposed) notifyListeners();
  }

  // A carousel attaches while it builds and detaches while the tree is
  // locked; listeners that call setState must hear about it after the frame.
  void _changedAfterFrame() {
    SchedulerBinding.instance
      ..addPostFrameCallback((_) => _changed())
      ..ensureVisualUpdate();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

/// Binds [controller] to [binding]. The most recently built carousel wins, so
/// a key change that builds the new carousel before disposing the old one
/// hands the controller over instead of failing.
void attachController(
  FlutterCarouselController controller,
  CarouselBinding binding,
) {
  controller
    .._binding = binding
    .._changedAfterFrame();
}

/// Unbinds [binding], unless another carousel has taken [controller] over.
void detachController(
  FlutterCarouselController controller,
  CarouselBinding binding,
) {
  if (!identical(controller._binding, binding)) return;
  controller
    .._binding = null
    .._changedAfterFrame();
}

/// Tells [controller]'s listeners that the index or autoplay state changed.
void notifyController(FlutterCarouselController controller) =>
    controller._changed();
