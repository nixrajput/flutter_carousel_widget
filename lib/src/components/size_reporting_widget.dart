import 'package:flutter/material.dart';

/// [SizeReportingWidget] is a widget that detects and reports changes in its child's size
/// using a callback (onSizeChange). This is useful when the size of the child affects layout.
class SizeReportingWidget extends StatefulWidget {
  const SizeReportingWidget({
    Key? key,
    required this.child, // The child widget whose size is being tracked.
    required this.onSizeChange, // Callback function to notify parent of size changes.
  }) : super(key: key);

  final Widget child;
  final ValueChanged<Size> onSizeChange;

  @override
  _SizeReportingWidgetState createState() => _SizeReportingWidgetState();
}

class _SizeReportingWidgetState extends State<SizeReportingWidget> {
  Size? _oldSize; // Tracks the previous size to detect changes.
  final _widgetKey = GlobalKey(); // Key to access the context of the widget.

  /// This method checks the current size of the widget and compares it to the previous size.
  /// If the size has changed, it triggers the onSizeChange callback.
  void _notifySize() {
    final context = _widgetKey.currentContext;
    if (context == null) return;
    final size = context.size;
    if (_oldSize != size) {
      _oldSize = size;
      widget.onSizeChange(size!); // Notify parent widget about the size change.
    }
  }

  @override
  Widget build(BuildContext context) {
    /// Schedules the size notification to occur after the frame has been drawn.
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifySize());

    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (_) {
        // After layout changes, recheck and notify about size changes.
        WidgetsBinding.instance.addPostFrameCallback((_) => _notifySize());
        return true;
      },
      child: SizeChangedLayoutNotifier(
        // Wraps the child widget with a SizeChangedLayoutNotifier to listen for size changes.
        child: Container(
          key: _widgetKey, // Assigns the key to track size.
          child:
              widget.child, // The child widget being tracked for size changes.
        ),
      ),
    );
  }
}
