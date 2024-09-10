import 'package:flutter/widgets.dart';

/// Typedef for building custom widgets in the carousel.
/// Takes context, index, and realIndex.
typedef ExtendedWidgetBuilder = Widget Function(
    BuildContext context, int index, int realIndex);
