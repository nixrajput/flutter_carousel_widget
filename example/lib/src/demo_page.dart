import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';

import 'app_theme.dart';
import 'collapsible_section.dart';
import 'demo_layout.dart';
import 'logo_mark.dart';
import 'playground.dart';
import 'slides.dart';
import 'widgets.dart';

class DemoPage extends StatefulWidget {
  const DemoPage({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  @override
  State<DemoPage> createState() => _DemoPageState();
}

class _DemoPageState extends State<DemoPage> {
  static const _count = 5;

  /// What the preview card needs around the carousel: its title, the
  /// toolbar and the padding.
  static const _previewChrome = 152.0;

  /// A slide's padding, which keeps it clear of the dots, plus room for its
  /// number.
  static const _shortestSlide = Gaps.m + Gaps.l + Gaps.s + 24;

  final _controller = FlutterCarouselController();
  final _position = ValueNotifier<double>(0);
  final _focus = FocusNode();
  var _settings = const PlaygroundOptions();

  /// Bumped by a reset, so the menus rebuild with the defaults selected.
  var _generation = 0;

  @override
  void dispose() {
    _controller.dispose();
    _position.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => DemoLayout(
    title: 'flutter_carousel_widget',
    logo: const LogoMark(size: 28),
    themeMode: widget.themeMode,
    onThemeModeChanged: widget.onThemeModeChanged,
    preview: (context, maxHeight) =>
        _preview((maxHeight - _previewChrome).clamp(64.0, 240.0)),
    onReset: () => setState(() {
      _settings = const PlaygroundOptions();
      _generation++;
    }),
    options: optionSections(
      options: _settings,
      onChanged: (o) => setState(() => _settings = o),
      generation: _generation,
    ),
    explore: [
      DemoSection(
        title: 'Effects',
        summary: 'Every preset, side by side',
        subtitle: 'Every preset, dragged or left to autoplay.',
        child: _gallery(),
      ),
      DemoSection(
        title: 'Expandable',
        summary: 'The height follows each slide',
        subtitle: 'The height follows each slide, and the drag between them.',
        child: _expandable(),
      ),
      const DemoSection(
        title: 'Keyboard and screen readers',
        summary: 'Arrow keys, Home and End',
        child: Text(
          'Focus the preview (Tab), then use the arrow keys, Home and End. '
          'Screen readers hear "Slide x of n" and can swipe through; autoplay '
          'pauses while the preview has focus and never speaks.',
        ),
      ),
    ],
  );

  /// The carousel at [height], with the controls that drive it under it.
  Widget _preview(double height) {
    final scheme = Theme.of(context).colorScheme;
    final o = _settings;
    final axis = o.vertical ? Axis.vertical : Axis.horizontal;
    final shortest = _shortestSlide.clamp(0.0, height);
    Widget carousel = o.expandable
        ? ExpandableCarousel.builder(
            itemCount: _count,
            // The measured axis varies: heights when horizontal, from one just
            // tall enough for its number to the whole preview, widths when
            // vertical, so the size follows each slide inside the pinned area.
            itemBuilder: (context, i, _) => o.vertical
                ? SizedBox(
                    width: 180.0 + 60 * i,
                    child: DemoSlide(index: i, axis: axis),
                  )
                : SizedBox(
                    height: shortest + (height - shortest) * i / (_count - 1),
                    child: DemoSlide(index: i, axis: axis),
                  ),
            controller: _controller,
            focusNode: _focus,
            viewportFraction: o.viewportFraction,
            infinite: o.infinite,
            reverse: o.reverse,
            scrollDirection: axis,
            autoPlay: o.carouselAutoPlay,
            effect: PlaygroundOptions.effectFor(o.effect, o.strength),
            indicator: o.indicator(scheme),
            physics: o.physics,
            padEnds: o.padEnds,
            onScrolled: (p) => _position.value = p,
            edgeAlignment: o.flush
                ? CarouselEdgeAlignment.flush
                : CarouselEdgeAlignment.center,
          )
        : FlutterCarousel.builder(
            itemCount: _count,
            itemBuilder: (context, i, _) => DemoSlide(index: i, axis: axis),
            height: height,
            itemAlignment: null,
            controller: _controller,
            focusNode: _focus,
            viewportFraction: o.viewportFraction,
            infinite: o.infinite,
            reverse: o.reverse,
            scrollDirection: axis,
            autoPlay: o.carouselAutoPlay,
            effect: PlaygroundOptions.effectFor(o.effect, o.strength),
            indicator: o.indicator(scheme),
            physics: o.physics,
            padEnds: o.padEnds,
            onScrolled: (p) => _position.value = p,
            edgeAlignment: o.flush
                ? CarouselEdgeAlignment.flush
                : CarouselEdgeAlignment.center,
          );
    // A vertical ExpandableCarousel sizes its width to the slides and scrolls
    // along its height, so it needs one.
    if (o.expandable && o.vertical) {
      carousel = SizedBox(height: height, child: carousel);
    }
    carousel = Directionality(
      textDirection: o.rtl ? TextDirection.rtl : TextDirection.ltr,
      child: carousel,
    );
    // A visible focus ring, which the carousel leaves to the app.
    carousel = ListenableBuilder(
      listenable: _focus,
      builder: (context, child) => DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Gaps.m),
          border: _focus.hasFocus
              ? Border.all(color: scheme.primary, width: 2)
              : null,
        ),
        child: child,
      ),
      child: carousel,
    );
    return Section(
      title: 'Preview',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          carousel,
          const SizedBox(height: Gaps.s),
          _toolbar(),
        ],
      ),
    );
  }

  /// The controller's actions, beside the carousel they move. A narrow
  /// preview drops the readout, then First and Last, which Home and End
  /// still reach.
  Widget _toolbar() => ListenableBuilder(
    listenable: Listenable.merge([_controller, _position]),
    builder: (context, _) {
      final ready = _controller.isAttached;
      final o = _settings;
      Widget button(String tooltip, IconData icon, VoidCallback? onPressed) =>
          IconButton(
            tooltip: tooltip,
            onPressed: ready ? onPressed : null,
            icon: Icon(icon),
          );
      final playing = _controller.isAutoPlaying;
      return LayoutBuilder(
        builder: (context, constraints) {
          const target = 48.0;
          final edges = constraints.maxWidth >= 5 * target;
          final readout = constraints.maxWidth >= 5 * target + 72;
          return Row(
            children: [
              if (edges)
                button(
                  'First',
                  Icons.first_page,
                  () => _controller.jumpToPage(0),
                ),
              button('Previous', Icons.chevron_left, _controller.previousPage),
              button(
                playing ? 'Pause' : 'Play',
                playing ? Icons.pause : Icons.play_arrow,
                !o.autoPlay
                    ? null
                    : playing
                    ? _controller.stopAutoPlay
                    : _controller.startAutoPlay,
              ),
              button('Next', Icons.chevron_right, _controller.nextPage),
              if (edges)
                button(
                  'Last',
                  Icons.last_page,
                  () => _controller.jumpToPage(_count - 1),
                ),
              if (readout)
                Expanded(
                  child: Text(
                    ready
                        ? 'Item ${_controller.index + 1} of $_count · '
                              '${_controller.position.toStringAsFixed(2)}'
                        : 'Not attached',
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
            ],
          );
        },
      );
    },
  );

  Widget _gallery() => Wrap(
    spacing: Gaps.m,
    runSpacing: Gaps.m,
    children: [
      for (final e in Effect.values.skip(1))
        SizedBox(
          width: 200,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(e.name, style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: Gaps.s),
              FlutterCarousel.builder(
                itemCount: 4,
                itemBuilder: (context, i, _) => DemoSlide(index: i),
                height: 120,
                itemAlignment: null,
                infinite: true,
                viewportFraction: 0.7,
                effect: PlaygroundOptions.effectFor(e),
                autoPlay: const CarouselAutoPlay(
                  interval: Duration(seconds: 2),
                ),
                indicator: null,
                semanticLabel: '${e.name} effect',
              ),
            ],
          ),
        ),
    ],
  );

  Widget _expandable() {
    final scheme = Theme.of(context).colorScheme;
    return ExpandableCarousel.builder(
      itemCount: 4,
      itemBuilder: (context, i, _) => DemoSlide(index: i, lines: 1 + i * 2),
      viewportFraction: 0.9,
      indicator: CarouselIndicator(
        placement: CarouselIndicatorPlacement.below,
        painter: SequentialFillIndicator(
          style: SlideIndicatorStyle(
            activeColor: scheme.primary,
            inactiveColor: scheme.outline,
          ),
        ),
      ),
    );
  }
}
