import 'package:flutter/material.dart';

import 'size_reporting_widget.dart';

/// [OverflowPage] is a custom widget that uses OverflowBox to allow its child widget to overflow
/// its constraints. It also reports the size of the child widget using the [SizeReportingWidget].
class OverflowPage extends StatelessWidget {
  const OverflowPage({
    super.key,
    required this.onSizeChange, // Callback to report size changes of the child widget.
    required this.child, // The widget that is allowed to overflow.
    required this.alignment, // Alignment of the child within the OverflowBox.
    required this.scrollDirection, // Axis to determine which direction the OverflowBox applies constraints.
  });

  final Alignment alignment;
  final Widget child;
  final ValueChanged<Size> onSizeChange;
  final Axis scrollDirection;

  @override
  Widget build(BuildContext context) {
    return OverflowBox(
      // Set minimum and maximum height/width based on scroll direction.
      minHeight: scrollDirection == Axis.horizontal ? 0 : null,
      minWidth: scrollDirection == Axis.vertical ? 0 : null,
      maxHeight: scrollDirection == Axis.horizontal ? double.infinity : null,
      maxWidth: scrollDirection == Axis.vertical ? double.infinity : null,
      alignment: alignment,
      // Aligns the child widget within the overflow box.
      child: SizeReportingWidget(
        onSizeChange: onSizeChange, // Reports size changes of the child.
        child: child, // The actual child widget.
      ),
    );
  }
}
