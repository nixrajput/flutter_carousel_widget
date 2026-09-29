import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';

import 'app_theme.dart';
import 'logo_mark.dart';
import 'playground.dart';
import 'scroll_forwarder.dart';
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
  final _list = ScrollController();
  final _controller = FlutterCarouselController();
  final _position = ValueNotifier<double>(0);
  final _focus = FocusNode();
  var _settings = const PlaygroundOptions();

  @override
  void dispose() {
    _list.dispose();
    _controller.dispose();
    _position.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    // Options and preview must both stay in view. With room or in landscape
    // both are pinned side by side above one list; on a portrait phone the
    // preview is pinned and the options lead the list under it.
    final twoPane = size.width >= Gaps.twoPane || size.width > size.height;
    final maxWidth = twoPane ? Gaps.maxWideWidth : Gaps.maxWidth;
    final side = math.max(Gaps.m, (size.width - maxWidth) / 2);
    final preview = _preview(
      compact: !twoPane || size.height < Gaps.tallEnough,
    );
    return Scaffold(
      appBar: AppBar(
        titleSpacing: side,
        // Scales down rather than overflowing beside the theme switch on a
        // narrow phone or with a large text size.
        title: const FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              LogoMark(size: 28),
              SizedBox(width: Gaps.s + Gaps.s / 2),
              Text('flutter_carousel_widget'),
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
      // An explicit ListView padding drops the device insets, so SafeArea
      // restores them; without it the last card sits under the home bar.
      body: SafeArea(
        top: false,
        // The wheel over the pinned preview scrolls the list too.
        child: ScrollForwarder(
          controller: _list,
          child: twoPane ? _twoPane(side, preview) : _onePane(side, preview),
        ),
      ),
    );
  }

  Widget _twoPane(double side, Widget preview) => Row(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Expanded(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final list = EdgeInsets.fromLTRB(side, Gaps.s, Gaps.s, Gaps.l);
            // Pinned like the preview only when the options fit whole and the
            // list keeps room; a half-hidden card reads as broken.
            final room =
                Gaps.pinOptions * MediaQuery.textScalerOf(context).scale(1);
            if (constraints.maxHeight < room) return _content(list);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(side, Gaps.s, Gaps.s, Gaps.s),
                  child: _options(),
                ),
                Expanded(child: _content(list, withOptions: false)),
              ],
            );
          },
        ),
      ),
      Expanded(
        // Scrolls only when the preview is taller than the screen.
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(Gaps.s, Gaps.s, side, Gaps.l),
          child: preview,
        ),
      ),
    ],
  );

  Widget _onePane(double side, Widget preview) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: EdgeInsets.fromLTRB(side, Gaps.s, side, Gaps.s),
        child: preview,
      ),
      Expanded(
        child: _content(EdgeInsets.fromLTRB(side, Gaps.s, side, Gaps.l)),
      ),
    ],
  );

  /// Everything that is not pinned, in the one list that scrolls.
  Widget _content(EdgeInsets padding, {bool withOptions = true}) => ListView(
    controller: _list,
    padding: padding,
    children: [
      if (withOptions) ...[_options(), const SizedBox(height: Gaps.m)],
      _controls(),
      const SizedBox(height: Gaps.m),
      _gallery(),
      const SizedBox(height: Gaps.m),
      _expandable(),
      const SizedBox(height: Gaps.m),
      _keyboard(),
    ],
  );

  Widget _preview({required bool compact}) {
    final scheme = Theme.of(context).colorScheme;
    final o = _settings;
    final axis = o.vertical ? Axis.vertical : Axis.horizontal;
    Widget carousel = o.expandable
        ? ExpandableCarousel.builder(
            itemCount: _count,
            // The measured axis varies: heights when horizontal, widths when
            // vertical, so the carousel's size visibly follows each slide.
            itemBuilder: (context, i, _) => o.vertical
                ? SizedBox(
                    width: 180.0 + 60 * i,
                    child: DemoSlide(index: i, axis: axis),
                  )
                : DemoSlide(index: i, lines: 1 + i * 2, axis: axis),
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
            height: compact ? 160 : 240,
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
      carousel = SizedBox(height: compact ? 200 : 300, child: carousel);
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
          ListenableBuilder(
            listenable: _controller,
            builder: (context, _) => Align(
              alignment: AlignmentDirectional.centerStart,
              child: IconButton(
                tooltip: _controller.isAutoPlaying ? 'Pause' : 'Play',
                onPressed: !_controller.isAttached || !o.autoPlay
                    ? null
                    : _controller.isAutoPlaying
                    ? _controller.stopAutoPlay
                    : _controller.startAutoPlay,
                icon: Icon(
                  _controller.isAutoPlaying ? Icons.pause : Icons.play_arrow,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _options() => Section(
    title: 'Options',
    child: OptionsPanel(
      options: _settings,
      onChanged: (o) => setState(() => _settings = o),
    ),
  );

  Widget _controls() => Section(
    title: 'Controller',
    subtitle: 'Drives the preview.',
    child: ListenableBuilder(
      listenable: Listenable.merge([_controller, _position]),
      builder: (context, _) {
        final ready = _controller.isAttached;
        return Wrap(
          spacing: Gaps.s,
          runSpacing: Gaps.s,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            OutlinedButton(
              onPressed: ready ? () => _controller.jumpToPage(0) : null,
              child: const Text('First'),
            ),
            OutlinedButton(
              onPressed: ready ? _controller.previousPage : null,
              child: const Text('Previous'),
            ),
            OutlinedButton(
              onPressed: ready ? _controller.nextPage : null,
              child: const Text('Next'),
            ),
            OutlinedButton(
              onPressed: ready
                  ? () => _controller.jumpToPage(_count - 1)
                  : null,
              child: const Text('Last'),
            ),
            Text(
              ready
                  ? 'Item ${_controller.index + 1} of $_count, '
                        'position ${_controller.position.toStringAsFixed(2)}'
                  : 'Not attached',
            ),
          ],
        );
      },
    ),
  );

  Widget _gallery() => Section(
    title: 'Effects',
    subtitle: 'Every preset, dragged or left to autoplay.',
    child: Wrap(
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
    ),
  );

  Widget _expandable() {
    final scheme = Theme.of(context).colorScheme;
    return Section(
      title: 'Expandable',
      subtitle: 'The height follows each slide, and the drag between them.',
      child: ExpandableCarousel.builder(
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
      ),
    );
  }

  Widget _keyboard() => const Section(
    title: 'Keyboard and screen readers',
    subtitle:
        'Focus the preview (Tab), then use the arrow keys, Home and End. '
        'Screen readers hear "Slide x of n" and can swipe through; autoplay '
        'pauses while the preview has focus and never speaks.',
    child: SizedBox.shrink(),
  );
}
