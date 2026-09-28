import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:flutter_carousel_widget/src/controller/flutter_carousel_controller.dart';

/// A binding that records what the controller asked of it.
class FakeBinding implements CarouselBinding {
  final calls = <String>[];

  @override
  int index = 0;

  @override
  double position = 0;

  @override
  bool isAutoPlaying = false;

  @override
  Future<void> step(int delta, {Duration? duration, Curve? curve}) async =>
      calls.add('step $delta $duration $curve');

  @override
  Future<void> animateTo(int index, {Duration? duration, Curve? curve}) async =>
      calls.add('animateTo $index $duration $curve');

  @override
  void jumpTo(int index) => calls.add('jumpTo $index');

  @override
  set autoPlayStopped(bool value) => calls.add('stopped $value');
}

/// A canvas that records circles and clips, for asserting on painters.
class RecordingCanvas implements Canvas {
  final circles = <(Offset, double, Color, PaintingStyle)>[];
  final lines = <(Offset, Offset, double, Color)>[];
  var clips = 0;

  // Paint stores colours as floats, so 0x66 alpha comes back unequal to the
  // Color it was given; 8-bit ARGB compares the way the styles are written.
  static Color _argb(Paint paint) => Color(paint.color.toARGB32());

  @override
  void drawCircle(Offset c, double radius, Paint paint) =>
      circles.add((c, radius, _argb(paint), paint.style));

  @override
  void drawLine(Offset p1, Offset p2, Paint paint) =>
      lines.add((p1, p2, paint.strokeWidth, _argb(paint)));

  @override
  void clipRect(
    Rect rect, {
    ClipOp clipOp = ClipOp.intersect,
    bool doAntiAlias = true,
  }) => clips++;

  @override
  void clipPath(Path path, {bool doAntiAlias = true}) => clips++;

  @override
  void save() {}

  @override
  void restore() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

/// Hosts [child] the way an app would, [width] logical pixels wide.
Widget host(
  Widget child, {
  TextDirection textDirection = TextDirection.ltr,
  double width = 400,
  bool disableAnimations = false,
  bool accessibleNavigation = false,
}) => MediaQuery(
  data: MediaQueryData(
    size: Size(width, 800),
    disableAnimations: disableAnimations,
    accessibleNavigation: accessibleNavigation,
  ),
  child: Directionality(
    textDirection: textDirection,
    child: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(width: width, child: child),
    ),
  ),
);

/// [n] items labelled with their index; [keyed] gives each a `ValueKey`.
List<Widget> boxes(int n, {bool keyed = false}) => [
  for (var i = 0; i < n; i++)
    SizedBox.expand(key: keyed ? ValueKey(i) : null, child: Text('$i')),
];

/// A widget whose state a test can read, to prove state survived.
class Counter extends StatefulWidget {
  const Counter({super.key});

  @override
  State<Counter> createState() => CounterState();
}

class CounterState extends State<Counter> {
  var count = 0;

  @override
  Widget build(BuildContext context) => Text('count $count');
}
