/// Copies of the items that sit before the start of an infinite carousel.
///
/// The offset lets an infinite carousel page backwards without negative pages.
/// 3.1.1 used the same value; no crash reproduced from 3 to 5000 items.
const loopCycles = 10000;

/// The page an unmoved carousel shows for [initialPage].
int startPage(int initialPage, int itemCount, {required bool infinite}) =>
    infinite && itemCount > 0
    ? itemCount * loopCycles + initialPage
    : initialPage;

/// The item on [page].
int itemAt(int page, int itemCount) => itemCount <= 0 ? 0 : page % itemCount;

/// The fractional item position at [page], in `[0, itemCount)`.
///
/// A finite carousel clamps, so a bounce past an end never reads as a wrap.
double positionAt(double page, int itemCount, {required bool infinite}) {
  if (itemCount <= 0) return 0;
  if (infinite) return page % itemCount;
  return page.clamp(0, itemCount - 1).toDouble();
}

/// The page to move to so that [target] is reached from [page], the short way
/// round when [infinite].
int pageFor(
  int target, {
  required int page,
  required int itemCount,
  required bool infinite,
}) {
  if (!infinite || itemCount <= 0) return target;
  var delta = target - itemAt(page, itemCount);
  if (delta * 2 > itemCount) {
    delta -= itemCount;
  } else if (delta * 2 < -itemCount) {
    delta += itemCount;
  }
  return page + delta;
}

/// [page] rescaled so the last item is reached where the scroll stops, when
/// the viewport cannot centre it (`padEnds: false`).
double reachablePage(
  double page, {
  required double maxPage,
  required int itemCount,
}) {
  final last = itemCount - 1;
  if (last <= 0 || maxPage <= 0 || maxPage >= last) return page;
  return page * last / maxPage;
}
