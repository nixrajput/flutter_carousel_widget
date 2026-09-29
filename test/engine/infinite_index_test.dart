import 'package:flutter_carousel_widget/src/engine/infinite_index.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('startPage sits loopCycles copies in when infinite', () {
    expect(startPage(2, 5, infinite: false), 2);
    expect(startPage(2, 5, infinite: true), 5 * loopCycles + 2);
    expect(startPage(0, 0, infinite: true), 0);
  });

  test('itemAt wraps negative and large pages', () {
    expect(itemAt(7, 5), 2);
    expect(itemAt(-1, 5), 4);
    expect(itemAt(5 * loopCycles + 3, 5), 3);
    expect(itemAt(3, 0), 0);
  });

  test('positionAt wraps when infinite and clamps when not', () {
    expect(positionAt(10001.5, 5, infinite: true), closeTo(1.5, 1e-9));
    expect(positionAt(-0.25, 5, infinite: true), closeTo(4.75, 1e-9));
    // A bounce past either end of a finite carousel must not read as a wrap.
    expect(positionAt(-0.25, 5, infinite: false), 0);
    expect(positionAt(4.3, 5, infinite: false), 4);
    expect(positionAt(2.4, 0, infinite: false), 0);
  });

  test('pageFor takes the short way round an infinite carousel', () {
    const base = 5 * loopCycles; // item 0
    expect(pageFor(1, page: base, itemCount: 5, infinite: true), base + 1);
    expect(pageFor(4, page: base, itemCount: 5, infinite: true), base - 1);
    expect(pageFor(3, page: base + 1, itemCount: 5, infinite: true), base + 3);
    expect(pageFor(2, page: base, itemCount: 4, infinite: true), base + 2);
    expect(pageFor(0, page: base + 4, itemCount: 5, infinite: true), base + 5);
    expect(pageFor(3, page: 1, itemCount: 5, infinite: false), 3);
  });

  test('reachablePage stretches a short scroll to the last item', () {
    // padEnds false, viewportFraction 0.8, 5 items: the scroll stops at 3.75.
    expect(reachablePage(3.75, maxPage: 3.75, itemCount: 5), closeTo(4, 1e-9));
    expect(reachablePage(0, maxPage: 3.75, itemCount: 5), 0);
    expect(reachablePage(2, maxPage: 4, itemCount: 5), 2);
    expect(reachablePage(0.5, maxPage: 0, itemCount: 1), 0.5);
  });
}
