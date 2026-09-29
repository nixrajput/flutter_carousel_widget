import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'collapsible_section.dart';
import 'reveal_focus.dart';
import 'scroll_forwarder.dart';
import 'widgets.dart';

/// The page every example shares: a preview that never scrolls away, the
/// options that change it in collapsible cards, and more to explore.
///
/// The layout follows the window, not the device. A narrow window stacks the
/// preview over one list; from [Gaps.twoPane] wide, or on a short landscape
/// phone, the options get a panel of their own beside the preview.
class DemoLayout extends StatefulWidget {
  const DemoLayout({
    super.key,
    required this.title,
    required this.logo,
    required this.themeMode,
    required this.onThemeModeChanged,
    required this.preview,
    required this.options,
    required this.explore,
    required this.onReset,
  });

  final String title;
  final Widget logo;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  /// Builds the preview for the height it may take, which it should fit.
  final Widget Function(BuildContext context, double maxHeight) preview;

  final List<DemoSection> options;
  final List<DemoSection> explore;

  /// Puts every option back to its default.
  final VoidCallback onReset;

  @override
  State<DemoLayout> createState() => _DemoLayoutState();
}

class _DemoLayoutState extends State<DemoLayout> {
  // Keeps the preview's state, such as a carousel's page, when a resize
  // moves it to another pane.
  final _previewKey = GlobalKey();
  final _panel = ScrollController();
  final _main = ScrollController();
  Map<String, bool>? _open;

  @override
  void dispose() {
    _panel.dispose();
    _main.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final short = size.height < Gaps.shortHeight;
    final sideBySide =
        size.width >= Gaps.twoPane ||
        (size.width >= Gaps.shortTwoPane && short);
    final maxWidth = sideBySide ? Gaps.maxWideWidth : Gaps.maxWidth;
    final side = math.max(Gaps.m, (size.width - maxWidth) / 2);
    // Open where there is room to show them, closed on a phone, where the
    // headers and their summaries are the overview. Then the reader decides.
    final roomy = sideBySide && !short;
    _open ??= {
      for (final s in widget.options) s.title: roomy,
      for (final (i, s) in widget.explore.indexed) s.title: roomy && i == 0,
    };
    return Scaffold(
      appBar: AppBar(
        titleSpacing: side,
        // Scales down rather than overflowing beside the theme switch on a
        // narrow phone or with a large text size.
        title: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.logo,
              const SizedBox(width: Gaps.s + Gaps.s / 2),
              Text(widget.title),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: side),
            child: ThemeModeSwitch(
              mode: widget.themeMode,
              onChanged: widget.onThemeModeChanged,
            ),
          ),
        ],
      ),
      // The lists' own padding drops the device insets, so SafeArea restores
      // them; without it the last card sits under the home bar.
      body: SafeArea(
        top: false,
        child: LayoutBuilder(
          builder: (context, constraints) => sideBySide
              ? _sideBySide(side, constraints.maxHeight, short)
              : _stacked(side, constraints.maxHeight, short),
        ),
      ),
    );
  }

  Widget _stacked(double side, double height, bool short) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: EdgeInsets.fromLTRB(side, Gaps.s, side, Gaps.s),
        // A small phone or a short window gives the preview half, or it
        // cannot fit.
        child: _preview(
          height * (short || height < Gaps.smallBody ? 0.5 : 0.4) - Gaps.m,
          _main,
        ),
      ),
      Expanded(
        child: _list(_main, side, side, [
          ..._group('Options', widget.options, reset: true),
          ..._group('Explore', widget.explore),
        ]),
      ),
    ],
  );

  Widget _sideBySide(double side, double height, bool short) {
    final width = MediaQuery.sizeOf(context).width - 2 * side;
    final panel = (width * 0.3).clamp(Gaps.panelMin, Gaps.panelMax);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          width: side + panel,
          // On a short screen the preview takes the whole height beside the
          // panel, so the rest of the page joins the options.
          child: _list(_panel, side, Gaps.scrollbarGutter, [
            ..._group('Options', widget.options, reset: true),
            if (short) ..._group('Explore', widget.explore),
          ]),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(Gaps.s, Gaps.s, side, Gaps.s),
                child: _preview(
                  short ? height - Gaps.m : height * 0.6,
                  short ? _panel : _main,
                ),
              ),
              if (!short)
                Expanded(
                  child: _list(
                    _main,
                    Gaps.s,
                    side,
                    _group('Explore', widget.explore),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// The preview, kept to [maxHeight]. It scrolls itself only if it cannot
  /// fit even so, as at a very large text size, and the wheel over it
  /// scrolls [list] instead.
  Widget _preview(double maxHeight, ScrollController list) => ScrollForwarder(
    controller: list,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: SingleChildScrollView(
        child: KeyedSubtree(
          key: _previewKey,
          child: widget.preview(context, maxHeight),
        ),
      ),
    ),
  );

  /// One scroll area. Its scrollbar shows while it scrolls and fades after;
  /// [right] keeps the cards clear of it.
  Widget _list(
    ScrollController controller,
    double left,
    double right,
    List<Widget> slivers,
  ) => RevealFocus(
    controller: controller,
    child: Scrollbar(
      controller: controller,
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
        child: CustomScrollView(
          controller: controller,
          slivers: [
            for (final sliver in slivers)
              SliverPadding(
                padding: EdgeInsets.only(left: left, right: right),
                sliver: sliver,
              ),
            const SliverToBoxAdapter(child: SizedBox(height: Gaps.l)),
          ],
        ),
      ),
    ),
  );

  List<Widget> _group(
    String title,
    List<DemoSection> sections, {
    bool reset = false,
  }) {
    final open = _open!;
    final allOpen = sections.every((s) => open[s.title] ?? false);
    return [
      SliverToBoxAdapter(
        child: _GroupHeader(
          title: title,
          allOpen: allOpen,
          onToggleAll: () => setState(() {
            for (final s in sections) {
              open[s.title] = !allOpen;
            }
          }),
          onReset: reset ? widget.onReset : null,
        ),
      ),
      for (final s in sections)
        SliverPadding(
          padding: const EdgeInsets.only(bottom: Gaps.s),
          sliver: CollapsibleSection(
            section: s,
            open: open[s.title] ?? false,
            onToggle: () =>
                setState(() => open[s.title] = !(open[s.title] ?? false)),
          ),
        ),
    ];
  }
}

/// A group's name, with its actions: reset, and open or close every card.
class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    required this.title,
    required this.allOpen,
    required this.onToggleAll,
    this.onReset,
  });

  final String title;
  final bool allOpen;
  final VoidCallback onToggleAll;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: Gaps.s, bottom: Gaps.s / 2),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(title, style: theme.textTheme.titleMedium),
            ),
          ),
          if (onReset != null)
            IconButton(
              tooltip: 'Reset to defaults',
              onPressed: onReset,
              icon: const Icon(Icons.restart_alt),
            ),
          IconButton(
            tooltip: allOpen ? 'Collapse all' : 'Expand all',
            onPressed: onToggleAll,
            icon: Icon(allOpen ? Icons.unfold_less : Icons.unfold_more),
          ),
        ],
      ),
    );
  }
}
