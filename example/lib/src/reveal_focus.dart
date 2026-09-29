import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'collapsible_section.dart';

/// Keeps the focused widget in [controller]'s list fully in view, clear of
/// the pinned card header above it, after a Tab, a resize or the keyboard.
///
/// Flutter's own reveal undershoots here: a SliverMainAxisGroup takes its
/// pinned header off a child's scroll offset, so a field at the bottom edge
/// stayed cut off, and on a phone it stayed under the keyboard.
class RevealFocus extends StatefulWidget {
  const RevealFocus({super.key, required this.controller, required this.child});

  final ScrollController controller;
  final Widget child;

  @override
  State<RevealFocus> createState() => _RevealFocusState();
}

class _RevealFocusState extends State<RevealFocus> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    FocusManager.instance.addListener(_schedule);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_schedule);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() => _schedule();

  void _schedule() => WidgetsBinding.instance.addPostFrameCallback((_) {
    if (mounted) _reveal();
  });

  void _reveal() {
    final focused = FocusManager.instance.primaryFocus?.context;
    final view = context.findRenderObject();
    if (focused == null || !focused.mounted || view is! RenderBox) return;
    if (!widget.controller.hasClients) return;
    var inside = false;
    focused.visitAncestorElements((e) => !(inside = e == context));
    final target = focused.findRenderObject();
    if (!inside || target is! RenderBox || !target.attached) return;

    final area = view.localToGlobal(Offset.zero) & view.size;
    final rect = target.localToGlobal(Offset.zero) & target.size;
    final top = area.top + pinnedHeaderAbove(focused) + Gaps.s;
    final bottom = area.bottom - Gaps.s;
    final position = widget.controller.position;
    final double by;
    if (rect.top < top || rect.height > bottom - top) {
      by = rect.top - top;
    } else if (rect.bottom > bottom) {
      by = rect.bottom - bottom;
    } else {
      return;
    }
    final to = (position.pixels + by).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if (MediaQuery.disableAnimationsOf(context)) {
      position.jumpTo(to);
    } else {
      position.animateTo(
        to,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
