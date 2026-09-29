import '../types.dart';

/// Remembers what started the move now running, so a page change can report
/// it. Each programmatic move gets a token, so a move that was interrupted and
/// finishes late cannot clear the reason of the move that replaced it.
class ReasonTracker {
  var _reason = CarouselPageChangedReason.manual;
  var _token = 0;

  /// The reason to report for a page change now.
  CarouselPageChangedReason get reason => _reason;

  /// Starts a programmatic move; pass the result to [end].
  int begin(CarouselPageChangedReason reason) {
    _reason = reason;
    return ++_token;
  }

  /// The user took over the scroll.
  void userScroll() {
    _reason = CarouselPageChangedReason.manual;
    _token++;
  }

  /// Ends the move [token] started, unless a newer one replaced it.
  void end(int token) {
    if (token == _token) _reason = CarouselPageChangedReason.manual;
  }
}
