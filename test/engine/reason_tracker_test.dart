import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';
import 'package:flutter_carousel_widget/src/engine/reason_tracker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('starts manual, and a begun move reports its reason until it ends', () {
    final t = ReasonTracker();
    expect(t.reason, CarouselPageChangedReason.manual);
    final token = t.begin(CarouselPageChangedReason.timed);
    expect(t.reason, CarouselPageChangedReason.timed);
    t.end(token);
    expect(t.reason, CarouselPageChangedReason.manual);
  });

  test('a stale end does not clear a newer move', () {
    final t = ReasonTracker();
    final first = t.begin(CarouselPageChangedReason.controller);
    t.begin(CarouselPageChangedReason.timed);
    t.end(first);
    expect(t.reason, CarouselPageChangedReason.timed);
  });

  test('a user scroll takes over from a running move', () {
    final t = ReasonTracker();
    final token = t.begin(CarouselPageChangedReason.keyboard);
    t.userScroll();
    expect(t.reason, CarouselPageChangedReason.manual);
    t.end(token);
    expect(t.reason, CarouselPageChangedReason.manual);
  });
}
