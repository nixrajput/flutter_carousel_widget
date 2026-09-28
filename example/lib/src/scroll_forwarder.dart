import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

/// Sends a mouse-wheel scroll over any still part of [child], such as the
/// pinned preview, to [controller], so the page scrolls wherever the pointer
/// is.
///
/// A scrollable under the pointer that can still move claims the event first:
/// it registers with the pointer-signal resolver before this outer listener.
class ScrollForwarder extends StatelessWidget {
  const ScrollForwarder({
    super.key,
    required this.controller,
    required this.child,
  });

  final ScrollController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) => Listener(
    onPointerSignal: (event) {
      if (event is! PointerScrollEvent || !controller.hasClients) return;
      GestureBinding.instance.pointerSignalResolver.register(
        event,
        (event) => controller.position.pointerScroll(
          (event as PointerScrollEvent).scrollDelta.dy,
        ),
      );
    },
    child: child,
  );
}
