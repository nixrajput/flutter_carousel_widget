import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

/// Reports its child's size from layout whenever it changes; no GlobalKey,
/// and no measuring on builds where nothing changed.
class SizeReporter extends SingleChildRenderObjectWidget {
  /// Creates a reporter calling [onSize].
  const SizeReporter({
    super.key,
    required this.slot,
    required this.onSize,
    super.child,
  });

  /// Where the size belongs. A new slot, such as a keyed item moving to
  /// another index, reports the size again even when it did not change.
  final Object? slot;

  /// Called after the frame in which the size changed.
  final ValueChanged<Size> onSize;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderSizeReporter(onSize, slot);

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) =>
      (renderObject as _RenderSizeReporter)
        ..onSize = onSize
        ..slot = slot;
}

class _RenderSizeReporter extends RenderProxyBox {
  _RenderSizeReporter(this.onSize, this._slot);

  ValueChanged<Size> onSize;
  Size? _reported;

  Object? _slot;
  set slot(Object? value) {
    if (value == _slot) return;
    _slot = value;
    _reported = null;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    super.performLayout();
    final measured = size;
    if (measured == _reported) return;
    _reported = measured;
    // Reporting rebuilds the carousel, which cannot happen during layout.
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (attached) onSize(measured);
    });
  }
}
