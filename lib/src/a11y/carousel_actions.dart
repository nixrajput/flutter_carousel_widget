import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Moves the carousel by [delta] items.
class CarouselStepIntent extends Intent {
  /// Creates the intent.
  const CarouselStepIntent(this.delta);

  /// How many items to move, negative for back.
  final int delta;
}

/// Moves to the first item, or the last when [last].
class CarouselEdgeIntent extends Intent {
  /// Creates the intent.
  const CarouselEdgeIntent({required this.last});

  /// Whether to go to the last item.
  final bool last;
}

/// The keys that move a carousel, mirrored so the arrow pointing at the next
/// item moves to it: [flipped] means item 0 sits at the right or bottom.
Map<ShortcutActivator, Intent> carouselShortcuts({
  required Axis axis,
  required bool flipped,
}) {
  final back = CarouselStepIntent(flipped ? 1 : -1);
  final on = CarouselStepIntent(flipped ? -1 : 1);
  return {
    if (axis == Axis.horizontal) ...{
      const SingleActivator(LogicalKeyboardKey.arrowLeft): back,
      const SingleActivator(LogicalKeyboardKey.arrowRight): on,
    } else ...{
      const SingleActivator(LogicalKeyboardKey.arrowUp): back,
      const SingleActivator(LogicalKeyboardKey.arrowDown): on,
    },
    const SingleActivator(LogicalKeyboardKey.home): const CarouselEdgeIntent(
      last: false,
    ),
    const SingleActivator(LogicalKeyboardKey.end): const CarouselEdgeIntent(
      last: true,
    ),
  };
}

/// Runs [onInvoke] only while [node] itself has primary focus. A disabled
/// action lets the key through, so keys typed into a field inside a slide
/// reach the field.
class CarouselKeyAction<T extends Intent> extends Action<T> {
  /// Creates the action.
  CarouselKeyAction(this.node, this.onInvoke);

  /// The carousel's own focus node.
  final FocusNode node;

  /// What the key does.
  final Object? Function(T intent) onInvoke;

  @override
  bool isEnabled(T intent) => node.hasPrimaryFocus;

  @override
  Object? invoke(T intent) => onInvoke(intent);
}
