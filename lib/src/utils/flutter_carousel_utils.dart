

/// Calculates the actual index within a collection of items, considering the current
/// position in an infinitely scrolling carousel.
///
/// The carousel simulates infinite scrolling by having a large number of pages (e.g., 10000),
/// while the actual number of items in the carousel is much smaller (e.g., 6).
/// This method maps the current page position in the large range to the corresponding index
/// in the smaller collection of items, effectively creating the illusion of infinite scrolling.
///
/// The [position] parameter represents the current page index in the large carousel (e.g., 10000 pages).
/// The [realPage] parameter represents the starting page index of the carousel.
/// The [itemCount] parameter represents the total number of actual items in the carousel (e.g., 6).
/// The optional [caller] parameter can be used to identify the source of the call for debugging purposes.
///
/// This function calculates the actual index by taking the difference between [position] and [realPage],
/// then applying a modulo operation with [itemCount] to ensure the index wraps around within the valid range
/// of item indices (0 to [itemCount] - 1).
///
/// If the calculated index is negative, it adjusts the index to be within the valid range by adding [itemCount].
///
/// Example:
/// - We have a carousel with 10000 pages, but only 6 unique items.
/// - When [position] is 10005 and [realPage] is 10000, this function will return an index of 5.
/// - When [position] is 9998 and [realPage] is 10000, this function will return an index of 4.
///
/// Returns the calculated index within the valid range of [itemCount].
int getRealIndex(int position, int realPage, int? itemCount) {
  if (itemCount == null || itemCount <= 0) return 0;

  var actualIndex = (position - realPage) % itemCount;
  if (actualIndex < 0) {
    actualIndex += itemCount;
  }

  return actualIndex;
}
