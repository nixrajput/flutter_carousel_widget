import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_carousel_widget/flutter_carousel_widget.dart';

import 'app_theme.dart';
import 'collapsible_section.dart';
import 'widgets.dart';

enum Effect {
  none,
  enlarge,
  fade,
  parallax,
  depth,
  zoomOut,
  stack,
  coverflow,
  cube,
  flip,
  rotate,
}

enum Painter { slide, still, wave, fill }

@immutable
class PlaygroundOptions {
  const PlaygroundOptions({
    this.expandable = false,
    this.effect = Effect.enlarge,
    this.strength = 1,
    this.viewportFraction = 0.8,
    this.infinite = true,
    this.padEnds = true,
    this.reverse = false,
    this.vertical = false,
    this.rtl = false,
    this.autoPlay = true,
    this.variedIntervals = false,
    this.painter = Painter.slide,
    this.below = false,
    this.flush = false,
    this.softSpring = false,
  });

  final bool expandable;
  final Effect effect;
  final double strength;
  final double viewportFraction;
  final bool infinite;
  final bool padEnds;
  final bool reverse;
  final bool vertical;
  final bool rtl;
  final bool autoPlay;
  final bool variedIntervals;
  final Painter painter;
  final bool below;
  final bool flush;
  final bool softSpring;

  PlaygroundOptions copyWith({
    bool? expandable,
    Effect? effect,
    double? strength,
    double? viewportFraction,
    bool? infinite,
    bool? padEnds,
    bool? reverse,
    bool? vertical,
    bool? rtl,
    bool? autoPlay,
    bool? variedIntervals,
    Painter? painter,
    bool? below,
    bool? flush,
    bool? softSpring,
  }) => PlaygroundOptions(
    expandable: expandable ?? this.expandable,
    effect: effect ?? this.effect,
    strength: strength ?? this.strength,
    viewportFraction: viewportFraction ?? this.viewportFraction,
    infinite: infinite ?? this.infinite,
    padEnds: padEnds ?? this.padEnds,
    reverse: reverse ?? this.reverse,
    vertical: vertical ?? this.vertical,
    rtl: rtl ?? this.rtl,
    autoPlay: autoPlay ?? this.autoPlay,
    variedIntervals: variedIntervals ?? this.variedIntervals,
    painter: painter ?? this.painter,
    below: below ?? this.below,
    flush: flush ?? this.flush,
    softSpring: softSpring ?? this.softSpring,
  );

  /// [k] runs from 0.5 to 1.5; 1 gives each preset's defaults (Task 9).
  static CarouselEffect effectFor(Effect effect, [double k = 1]) =>
      switch (effect) {
        Effect.none => CarouselEffect.none,
        Effect.enlarge => CarouselEffect.enlarge(factor: 0.25 * k),
        Effect.fade => CarouselEffect.fade(
          minOpacity: (1 - 0.7 * k).clamp(0.0, 1.0),
        ),
        Effect.parallax => CarouselEffect.parallax(depth: 0.3 * k),
        Effect.depth => CarouselEffect.depth(minScale: 1 - 0.25 * k),
        Effect.zoomOut => CarouselEffect.zoomOut(minScale: 1 - 0.15 * k),
        Effect.stack => CarouselEffect.stack(offset: 24 * k),
        Effect.coverflow => CarouselEffect.coverflow(angle: math.pi / 4 * k),
        Effect.cube => CarouselEffect.cube(perspective: 0.002 * k),
        Effect.flip => CarouselEffect.flip(perspective: 0.002 * k),
        Effect.rotate => CarouselEffect.rotate(angle: math.pi / 12 * k),
      };

  CarouselIndicator indicator(ColorScheme scheme) {
    final style = SlideIndicatorStyle(
      activeColor: scheme.primary,
      inactiveColor: scheme.outline,
      animated: true,
    );
    return CarouselIndicator(
      painter: switch (painter) {
        Painter.slide => CircularSlideIndicator(style: style),
        Painter.still => CircularStaticIndicator(style: style),
        Painter.wave => CircularWaveIndicator(style: style),
        Painter.fill => SequentialFillIndicator(style: style),
      },
      placement: below
          ? CarouselIndicatorPlacement.below
          : CarouselIndicatorPlacement.overlay,
    );
  }

  CarouselAutoPlay? get carouselAutoPlay => autoPlay
      ? CarouselAutoPlay(
          interval: const Duration(seconds: 3),
          intervalFor: variedIntervals
              ? (i) => Duration(seconds: i.isEven ? 2 : 5)
              : null,
        )
      : null;

  ScrollPhysics? get physics => softSpring
      ? CarouselSnapPhysics(
          snapSpring: SpringDescription.withDampingRatio(
            mass: 0.5,
            stiffness: 50,
            ratio: 1,
          ),
        )
      : null;
}

/// The options as collapsible cards, grouped by what they change.
/// [generation] rebuilds the menus, which read their selection once, after a
/// reset.
List<DemoSection> optionSections({
  required PlaygroundOptions options,
  required ValueChanged<PlaygroundOptions> onChanged,
  required int generation,
}) {
  final o = options;
  Widget toggle(
    String label,
    bool value,
    PlaygroundOptions Function(bool) next,
  ) => FilterChip(
    label: Text(label),
    selected: value,
    onSelected: (v) => onChanged(next(v)),
  );
  Widget chips(List<Widget> children) =>
      Wrap(spacing: Gaps.s, runSpacing: Gaps.s, children: children);
  Widget column(List<Widget> children) => KeyedSubtree(
    key: ValueKey(generation),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    ),
  );
  return [
    DemoSection(
      title: 'Carousel',
      summary:
          '${o.expandable ? 'Expandable' : 'FlutterCarousel'} · '
          'viewport ${o.viewportFraction.toStringAsFixed(2)} · '
          '${o.infinite ? 'infinite' : 'finite'}',
      child: column([
        SegmentedButton<bool>(
          segments: [
            ButtonSegment(value: false, label: segmentLabel('FlutterCarousel')),
            ButtonSegment(value: true, label: segmentLabel('Expandable')),
          ],
          selected: {o.expandable},
          onSelectionChanged: (s) =>
              onChanged(o.copyWith(expandable: s.single)),
        ),
        const SizedBox(height: Gaps.m),
        Text('Viewport fraction ${o.viewportFraction.toStringAsFixed(2)}'),
        Slider(
          value: o.viewportFraction,
          min: 0.4,
          max: 1,
          divisions: 12,
          onChanged: (v) => onChanged(o.copyWith(viewportFraction: v)),
        ),
        chips([
          toggle('Infinite', o.infinite, (v) => o.copyWith(infinite: v)),
          toggle('Pad ends', o.padEnds, (v) => o.copyWith(padEnds: v)),
          toggle('Flush edges', o.flush, (v) => o.copyWith(flush: v)),
        ]),
      ]),
    ),
    DemoSection(
      title: 'Effect',
      summary: o.effect == Effect.none
          ? 'none'
          : '${o.effect.name} · strength ${o.strength.toStringAsFixed(2)}',
      child: column([
        DropdownMenu<Effect>(
          label: const Text('Effect'),
          expandedInsets: EdgeInsets.zero,
          initialSelection: o.effect,
          dropdownMenuEntries: [
            for (final e in Effect.values)
              DropdownMenuEntry(value: e, label: e.name),
          ],
          onSelected: (e) => onChanged(o.copyWith(effect: e)),
        ),
        const SizedBox(height: Gaps.m),
        Text('Strength ${o.strength.toStringAsFixed(2)}'),
        Slider(
          value: o.strength,
          min: 0.5,
          max: 1.5,
          divisions: 10,
          onChanged: o.effect == Effect.none
              ? null
              : (v) => onChanged(o.copyWith(strength: v)),
        ),
      ]),
    ),
    DemoSection(
      title: 'Indicator',
      summary: '${o.painter.name} · ${o.below ? 'below' : 'overlay'}',
      child: column([
        DropdownMenu<Painter>(
          label: const Text('Indicator'),
          expandedInsets: EdgeInsets.zero,
          initialSelection: o.painter,
          dropdownMenuEntries: [
            for (final p in Painter.values)
              DropdownMenuEntry(value: p, label: p.name),
          ],
          onSelected: (p) => onChanged(o.copyWith(painter: p)),
        ),
        const SizedBox(height: Gaps.m),
        chips([
          toggle('Indicator below', o.below, (v) => o.copyWith(below: v)),
        ]),
      ]),
    ),
    DemoSection(
      title: 'Motion',
      summary: [
        if (!o.autoPlay)
          'no autoplay'
        else if (o.variedIntervals)
          'autoplay, varied intervals'
        else
          'autoplay',
        if (o.softSpring) 'soft snap',
      ].join(' · '),
      child: chips([
        toggle('Autoplay', o.autoPlay, (v) => o.copyWith(autoPlay: v)),
        toggle(
          'Varied intervals',
          o.variedIntervals,
          (v) => o.copyWith(variedIntervals: v),
        ),
        toggle(
          'Soft snap spring',
          o.softSpring,
          (v) => o.copyWith(softSpring: v),
        ),
      ]),
    ),
    DemoSection(
      title: 'Direction',
      summary: [
        if (o.vertical) 'vertical' else 'horizontal',
        if (o.rtl) 'right to left' else 'left to right',
        if (o.reverse) 'reversed',
      ].join(' · '),
      child: chips([
        toggle('Vertical', o.vertical, (v) => o.copyWith(vertical: v)),
        toggle('Reverse', o.reverse, (v) => o.copyWith(reverse: v)),
        toggle('Right to left', o.rtl, (v) => o.copyWith(rtl: v)),
      ]),
    ),
  ];
}
